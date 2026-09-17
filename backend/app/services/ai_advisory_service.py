from typing import List
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.issue import Issue, IssueStatus
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

    async def get_classification_advice(
        self, request: AIClassificationRequest
    ) -> AIClassificationResponse:
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
        stmt = select(Category).where(Category.is_active == True)
        result = await self.db.execute(stmt)
        categories = result.scalars().all()

        suggested_category_id = None
        for cat in categories:
            if cat.name.lower() in text or cat.slug in text:
                suggested_category_id = cat.id
                break

        # Missing information detector
        missing_info: List[str] = []
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

    async def check_duplicate_issues(
        self, request: AIDedupCheckRequest
    ) -> AIDedupCheckResponse:
        """Find open issues in same location/building with similar titles (FR-AI-03)."""
        stmt = select(Issue).where(
            Issue.status.notin_([IssueStatus.CLOSED, IssueStatus.CONFIRMED])
        )
        if request.building_id:
            stmt = stmt.where(Issue.building_id == request.building_id)
        if request.room_id:
            stmt = stmt.where(Issue.room_id == request.room_id)

        result = await self.db.execute(stmt)
        existing_issues = result.scalars().all()

        duplicates: List[PotentialDuplicateItem] = []
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

    async def draft_status_message(
        self, request: AIStatusDraftRequest
    ) -> AIStatusDraftResponse:
        """Draft polite, transparent communication update for reporters (FR-AI-08)."""
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


def get_ai_advisory_service(db: AsyncSession) -> AIAdvisoryService:
    return AIAdvisoryService(db)
