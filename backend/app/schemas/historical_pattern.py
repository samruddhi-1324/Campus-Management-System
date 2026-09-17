
from app.schemas.base import CoreModel


class MultiYearTrendRecordRead(CoreModel):
    year: int
    quarter: int | None = None
    month: int | None = None
    category_id: str | None = None
    total_volume: int
    avg_resolution_hours: float
    seasonal_spike_flag: bool
    pattern_summary: str | None = None


class HistoricalPatternAnalyticsResponse(CoreModel):
    records: list[MultiYearTrendRecordRead]
    identified_seasonal_patterns: list[str]
    long_term_recommendations: list[str]
