from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.api.deps import get_current_user_id
from app.schemas.recommendation import RecommendationRead, RecommendationDecisionCreate

router = APIRouter()


@router.get("/", response_model=List[RecommendationRead])
async def list_recommendations(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Supervisor/Ops Head retrieves AI resolution and preventive maintenance recommendations (FR-AI-13..20)."""
    pass


@router.post("/{recommendation_id}/decision", response_model=RecommendationRead)
async def record_recommendation_decision(
    recommendation_id: str,
    decision_in: RecommendationDecisionCreate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Record human decision on recommendation (FR-AI-18)."""
    pass
