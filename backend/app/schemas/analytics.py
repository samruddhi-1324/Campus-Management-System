from app.schemas.base import CoreModel


class CampusVolumeMetrics(CoreModel):
    total_issues: int
    open_issues: int
    resolved_issues: int
    closed_issues: int
    escalated_issues: int
    sla_breached_issues: int


class CategoryVolumeMetric(CoreModel):
    category_name: str
    count: int
    percentage: float


class BuildingVolumeMetric(CoreModel):
    building_name: str
    count: int
    open_count: int


class OpsHeadAnalyticsResponse(CoreModel):
    volume: CampusVolumeMetrics
    by_category: list[CategoryVolumeMetric]
    by_building: list[BuildingVolumeMetric]
    avg_resolution_hours: float
    median_resolution_hours: float
    ai_weekly_summary: str | None = None
