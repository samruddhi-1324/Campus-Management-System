from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.api.deps import get_current_user_id
from app.schemas.analytics import OpsHeadAnalyticsResponse

router = APIRouter()


@router.get("/overview", response_model=OpsHeadAnalyticsResponse)
async def get_analytics_overview(
    building_id: Optional[str] = Query(None),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Ops Head views campus-wide metrics & resolution performance (FR-1.21..23)."""
    pass
