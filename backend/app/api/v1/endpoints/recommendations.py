from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user_id
from app.core.database import get_db
from app.schemas.recommendation import RecommendationDecisionCreate, RecommendationRead
from app.services.recommendation_service import get_recommendation_service

router = APIRouter()


@router.get("/", response_model=list[RecommendationRead])
async def list_recommendations(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Supervisor/Ops Head retrieves AI resolution and preventive maintenance recommendations (FR-AI-13..20)."""
    recommendation_service = get_recommendation_service(db)
    return await recommendation_service.get_recommendations_for_user(user_id=user_id, role="ops_head")


@router.post("/{recommendation_id}/decision", response_model=RecommendationRead)
async def record_recommendation_decision(
    recommendation_id: str,
    decision_in: RecommendationDecisionCreate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Record human decision on recommendation (FR-AI-18)."""
    recommendation_service = get_recommendation_service(db)
    return await recommendation_service.record_decision(
        recommendation_id=recommendation_id,
        decision_in=decision_in,
        user_id=user_id,
    )
