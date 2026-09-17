from fastapi import APIRouter, Depends, Query
from fastapi.responses import PlainTextResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user_id
from app.core.database import get_db
from app.schemas.analytics import OpsHeadAnalyticsResponse
from app.schemas.issue import IssueRead
from app.services.analytics_service import get_analytics_service

router = APIRouter()


@router.get("/overview", response_model=OpsHeadAnalyticsResponse)
async def get_analytics_overview(
    building_id: str | None = Query(None),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Ops Head views campus-wide metrics & resolution performance (FR-1.21..23)."""
    analytics_service = get_analytics_service(db)
    return await analytics_service.get_campus_analytics(building_id=building_id)


@router.get("/drilldown", response_model=list[IssueRead])
async def drilldown_analytics_metric(
    filter_type: str = Query("open", description="open | resolved | breached | escalated"),
    category_id: str | None = Query(None),
    building_id: str | None = Query(None),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Drill down from KPI metric card into underlying list of issues (FR-2.8)."""
    analytics_service = get_analytics_service(db)
    return await analytics_service.drilldown_issues(
        filter_type=filter_type,
        category_id=category_id,
        building_id=building_id,
    )


@router.get("/export", response_class=PlainTextResponse)
async def export_analytics_csv(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Export operational metrics and issues data as CSV for institutional reporting (FR-2.10)."""
    analytics_service = get_analytics_service(db)
    csv_data = await analytics_service.export_analytics_csv()
    return PlainTextResponse(
        content=csv_data,
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=campus_care_analytics.csv"},
    )
