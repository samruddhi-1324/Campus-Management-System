from typing import Any

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user_id
from app.core.database import get_db
from app.schemas.historical_pattern import HistoricalPatternAnalyticsResponse
from app.services.historical_analytics_service import get_historical_analytics_service

router = APIRouter()


@router.get("/multi-year", response_model=HistoricalPatternAnalyticsResponse)
async def get_multi_year_patterns(
    institution_id: str | None = Query(None),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> Any:
    """Ops Head views multi-year pattern mining & seasonal spike metrics (FR-3.5)."""
    service = get_historical_analytics_service(db)
    return await service.get_multi_year_trends(institution_id=institution_id)
