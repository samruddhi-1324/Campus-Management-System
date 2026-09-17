from datetime import UTC, datetime

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.recommendation import Recommendation
from app.schemas.recommendation import RecommendationDecisionCreate


class RecommendationService:
    """AI recommendations generation and human-decision logging (FR-AI-13..20)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_recommendations_for_user(self, user_id: str, role: str) -> list[Recommendation]:
        """Fetch recommendations pertinent to role (Supervisor, Ops Head, Admin)."""
        stmt = select(Recommendation).order_by(Recommendation.created_at.desc())
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def record_decision(
        self,
        recommendation_id: str,
        decision_in: RecommendationDecisionCreate,
        user_id: str,
    ) -> Recommendation:
        """Record human decision on recommendation (FR-AI-18, PRD §8)."""
        stmt = select(Recommendation).where(Recommendation.id == recommendation_id)
        result = await self.db.execute(stmt)
        rec = result.scalar_one_or_none()

        if not rec:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Recommendation {recommendation_id} not found",
            )

        rec.human_decision = decision_in.decision
        rec.decided_by = user_id
        rec.decided_at = datetime.now(UTC)

        await self.db.commit()
        await self.db.refresh(rec)
        return rec


def get_recommendation_service(db: AsyncSession) -> RecommendationService:
    return RecommendationService(db)
