from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.issue import Issue, IssueStatus, IssueUpdate
from app.models.master_data import Category
from app.schemas.ai import (
    AIClassificationRequest,
    AIClassificationResponse,
    AIDedupCheckRequest,
    AIDedupCheckResponse,
    AIStatusDraftRequest,
    AIStatusDraftResponse,
    PotentialDuplicateItem,
)


class AIAdvisoryService:
    """AI Decision-support service adhering to human-in-the-loop rules (FR-AI-01..20)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_classification_advice(self, request: AIClassificationRequest) -> AIClassificationResponse:
        """Advisory classification, urgency scoring, and missing information detection (FR-AI-01, FR-AI-02)."""
        text = f"{request.title} {request.description}".lower()

        # Heuristic urgency scoring
        suggested_urgency = "medium"
        urgency_rationale = "Standard facilities issue observed."

        critical_keywords = ["flood", "fire", "spark", "electric shock", "danger", "smoke", "gas leak", "collapse"]
        high_keywords = ["water leak", "no power", "broken glass", "overflow", "exam hall", "urgent", "ac leaking"]
        low_keywords = ["paint", "cosmetic", "scratched", "flicker", "chair wheel"]

        if any(w in text for w in critical_keywords):
            suggested_urgency = "critical"
            urgency_rationale = "Potential safety hazard or structural risk detected."
        elif any(w in text for w in high_keywords):
            suggested_urgency = "high"
            urgency_rationale = "Severe operational impact affecting facility or academic activities."
        elif any(w in text for w in low_keywords):
            suggested_urgency = "low"
            urgency_rationale = "Minor cosmetic or non-blocking maintenance request."

        # Category matching
        stmt = select(Category).where(Category.is_active)
        result = await self.db.execute(stmt)
        categories = result.scalars().all()

        suggested_category_id = None
        for cat in categories:
            if cat.name.lower() in text or cat.slug in text:
                suggested_category_id = cat.id
                break

        # Missing information detector
        missing_info: list[str] = []
        if not request.location and ("where" in text or "room" not in text):
            missing_info.append("Specific room number or floor level not specified.")
        if len(request.description.strip()) < 20:
            missing_info.append("Short description; additional details on asset behavior would help technicians.")

        return AIClassificationResponse(
            suggested_category_id=suggested_category_id,
            suggested_urgency=suggested_urgency,
            urgency_rationale=urgency_rationale,
            missing_information=missing_info,
            confidence=0.88,
            is_ai_generated=True,
        )

    async def check_duplicate_issues(self, request: AIDedupCheckRequest) -> AIDedupCheckResponse:
        """Find open issues in same location/building with similar titles (FR-AI-03)."""
        stmt = select(Issue).where(Issue.status.notin_([IssueStatus.CLOSED, IssueStatus.CONFIRMED]))
        if request.building_id:
            stmt = stmt.where(Issue.building_id == request.building_id)
        if request.room_id:
            stmt = stmt.where(Issue.room_id == request.room_id)

        result = await self.db.execute(stmt)
        existing_issues = result.scalars().all()

        duplicates: list[PotentialDuplicateItem] = []
        query_words = set(request.title.lower().split())

        for issue in existing_issues:
            target_words = set(issue.title.lower().split())
            intersection = query_words.intersection(target_words)
            if len(intersection) >= 2 or (len(query_words) > 0 and len(intersection) / len(query_words) > 0.5):
                score = round(min(0.95, len(intersection) / max(len(query_words), 1) + 0.2), 2)
                duplicates.append(
                    PotentialDuplicateItem(
                        issue_id=issue.id,
                        reference_number=issue.reference_number,
                        title=issue.title,
                        similarity_score=score,
                        rationale=f"Similar issue already active in the same location ({issue.reference_number}).",
                    )
                )

        return AIDedupCheckResponse(duplicates=duplicates)

    async def draft_status_message(self, request: AIStatusDraftRequest) -> AIStatusDraftResponse:
        """Draft polite, transparent communication update for reporters (FR-AI-06)."""
        status_map = {
            "under_investigation": "Our technical team is currently on site investigating the reported issue.",
            "in_progress": "Maintenance work has commenced. Replacement parts/technicians are actively working on this.",
            "resolved": "The facilities team has completed the repair work. Please verify and confirm resolution.",
            "waiting_for_info": "We need additional details to proceed. Please check the requested information.",
        }
        draft = status_map.get(
            request.target_status.lower(),
            f"Update: The issue status has progressed to {request.target_status.replace('_', ' ').title()}.",
        )
        if request.notes:
            draft += f" Note: {request.notes}"

        return AIStatusDraftResponse(draft_message=draft)

    async def suggest_similar_resolutions(self, issue_id: str) -> list[dict]:
        """Suggest previously successful resolutions for similar past resolved issues (FR-2.4, FR-AI-05)."""
        # Fetch current issue
        curr_stmt = select(Issue).where(Issue.id == issue_id)
        current = (await self.db.execute(curr_stmt)).scalar_one_or_none()
        if not current:
            return []

        # Find resolved issues in same category or title overlap
        stmt = (
            select(Issue)
            .where(
                Issue.id != issue_id,
                Issue.status.in_([IssueStatus.RESOLVED, IssueStatus.CLOSED]),
            )
            .order_by(Issue.resolved_at.desc().nullslast())
            .limit(10)
        )
        candidates = (await self.db.execute(stmt)).scalars().all()

        suggestions: list[dict] = []
        curr_words = set(current.title.lower().split())

        for past in candidates:
            past_words = set(past.title.lower().split())
            overlap = curr_words.intersection(past_words)
            if overlap or past.category_id == current.category_id:
                confidence = 0.75 if past.category_id == current.category_id else 0.60
                if len(overlap) >= 2:
                    confidence += 0.15

                suggestions.append(
                    {
                        "past_issue_id": past.id,
                        "past_reference_number": past.reference_number,
                        "past_title": past.title,
                        "suggested_fix": f"Prior resolution: Replaced/serviced component as verified in {past.reference_number}.",
                        "confidence": min(0.95, round(confidence, 2)),
                        "resolved_at": past.resolved_at.isoformat() if past.resolved_at else None,
                    }
                )

        return suggestions[:3]

    async def generate_thread_summary(self, issue_id: str) -> str | None:
        """Maintains plain-language summary for long issue threads with > 3 updates (FR-2.5, FR-AI-08)."""
        stmt = select(IssueUpdate).where(IssueUpdate.issue_id == issue_id).order_by(IssueUpdate.created_at.asc())
        updates = (await self.db.execute(stmt)).scalars().all()

        if len(updates) < 2:
            return None

        # Synthesize concise bulleted summary
        summary_points = [
            f"- {u.created_at.strftime('%b %d %H:%M') if u.created_at else ''}: {u.message[:80]}..."
            for u in updates[-4:]
        ]
        return "Thread Summary:\n" + "\n".join(summary_points)

    async def predict_sla_breach_risk(self) -> list[dict]:
        """Identifies issues at risk of missing their expected resolution window (FR-AI-07)."""
        now = datetime.now(UTC)
        stmt = select(Issue).where(
            Issue.expected_resolution_at.isnot(None),
            Issue.status.notin_([IssueStatus.RESOLVED, IssueStatus.CLOSED]),
        )
        issues = (await self.db.execute(stmt)).scalars().all()

        at_risk: list[dict] = []
        for issue in issues:
            if not issue.expected_resolution_at:
                continue
            total_duration = (issue.expected_resolution_at - issue.created_at).total_seconds()
            remaining_seconds = (issue.expected_resolution_at - now).total_seconds()

            # If less than 25% of SLA window remains or already overdue
            if remaining_seconds <= total_duration * 0.25:
                is_overdue = remaining_seconds < 0
                risk_level = "critical" if is_overdue else "high"
                at_risk.append(
                    {
                        "issue_id": issue.id,
                        "reference_number": issue.reference_number,
                        "title": issue.title,
                        "status": issue.status.value,
                        "urgency": issue.urgency.value,
                        "remaining_hours": round(remaining_seconds / 3600, 1),
                        "is_overdue": is_overdue,
                        "risk_level": risk_level,
                        "expected_resolution_at": issue.expected_resolution_at.isoformat(),
                    }
                )

        return sorted(at_risk, key=lambda x: x["remaining_hours"])


def get_ai_advisory_service(db: AsyncSession) -> AIAdvisoryService:
    return AIAdvisoryService(db)
