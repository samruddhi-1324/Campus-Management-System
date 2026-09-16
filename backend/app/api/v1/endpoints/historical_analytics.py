from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.api.deps import get_current_user_id
from app.schemas.historical_pattern import HistoricalPatternAnalyticsResponse

router = APIRouter()


@router.get("/multi-year", response_model=HistoricalPatternAnalyticsResponse)
async def get_multi_year_patterns(
    institution_id: Optional[str] = Query(None),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Ops Head views multi-year pattern mining & seasonal spike metrics (FR-3.5)."""
    pass
