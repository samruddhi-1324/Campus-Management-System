import uuid
from datetime import UTC, datetime, timedelta

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.issue import Issue
from app.models.recommendation import Recommendation, RecommendationType, RecurrencePattern


class RecurrenceService:
    """Equipment and Location failure recurrence detection over rolling windows (FR-2.6, FR-2.7, FR-AI-04)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def detect_recurring_patterns(self, window_days: int = 30) -> list[RecurrencePattern]:
        """Scans issues submitted within the rolling window to detect repeated asset/location failures."""
        cutoff_date = datetime.now(UTC) - timedelta(days=window_days)

        # 1. Find location/asset clusters with >= 2 issues in window
        stmt = (
            select(
                Issue.location_details,
                func.count(Issue.id).label("issue_count"),
            )
            .where(Issue.created_at >= cutoff_date, Issue.location_details.isnot(None))
            .group_by(Issue.location_details)
            .having(func.count(Issue.id) >= 2)
        )

        result = await self.db.execute(stmt)
        clusters = result.all()

        patterns: list[RecurrencePattern] = []
        for location_ref, count in clusters:
            if not location_ref:
                continue

            # Fetch specific issue IDs for this location cluster
            ids_stmt = select(Issue.id).where(
                Issue.location_details == location_ref,
                Issue.created_at >= cutoff_date,
            )
            issue_ids = list((await self.db.execute(ids_stmt)).scalars().all())

            # Check if pattern already tracked
            pattern_stmt = select(RecurrencePattern).where(
                RecurrencePattern.asset_or_location_ref == location_ref,
                RecurrencePattern.status == "flagged",
            )
            existing = (await self.db.execute(pattern_stmt)).scalar_one_or_none()

            if existing:
                existing.failure_count = count
                existing.related_issue_ids = issue_ids
                existing.observation_window_days = window_days
                patterns.append(existing)
            else:
                new_pattern = RecurrencePattern(
                    id=str(uuid.uuid4()),
                    asset_or_location_ref=location_ref,
                    failure_count=count,
                    observation_window_days=window_days,
                    related_issue_ids=issue_ids,
                    status="flagged",
                )
                self.db.add(new_pattern)
                patterns.append(new_pattern)

        await self.db.commit()
        return patterns

    async def convert_to_replacement_recommendation(self, pattern_id: str, actor_id: str) -> RecurrencePattern:
        """Allows Coordinator/Supervisor to convert flagged pattern into formal replacement recommendation (FR-2.7)."""
        stmt = select(RecurrencePattern).where(RecurrencePattern.id == pattern_id)
        result = await self.db.execute(stmt)
        pattern = result.scalar_one_or_none()

        if not pattern:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Recurrence pattern {pattern_id} not found",
            )

        # Create formal replacement recommendation for Ops Head (FR-AI-13..20)
        recommendation_id = str(uuid.uuid4())
        rec = Recommendation(
            id=recommendation_id,
            recommendation_type=RecommendationType.PREVENTIVE,
            scope_reference=f"asset:{pattern.asset_or_location_ref}",
            title=f"Replace / Overhaul Asset at {pattern.asset_or_location_ref}",
            body=(
                f"Asset/location '{pattern.asset_or_location_ref}' has experienced "
                f"{pattern.failure_count} recurrent failures within a {pattern.observation_window_days}-day "
                f"observation window. A permanent replacement is recommended to prevent repeated downtime."
            ),
            suggested_action="Schedule vendor procurement and complete physical unit replacement.",
            evidence_snapshot={
                "failure_count": pattern.failure_count,
                "observation_window_days": pattern.observation_window_days,
                "related_issue_ids": pattern.related_issue_ids,
            },
            confidence=0.92,
            model_version="campus-care-recurrence-v2",
            decided_by=actor_id,
        )
        self.db.add(rec)

        pattern.status = "converted_to_replacement"
        pattern.converted_recommendation_id = recommendation_id

        await self.db.commit()
        await self.db.refresh(pattern)
        return pattern


def get_recurrence_service(db: AsyncSession) -> RecurrenceService:
    return RecurrenceService(db)
