from typing import List, Optional
from app.schemas.base import CoreModel


class MultiYearTrendRecordRead(CoreModel):
    year: int
    quarter: Optional[int] = None
    month: Optional[int] = None
    category_id: Optional[str] = None
    total_volume: int
    avg_resolution_hours: float
    seasonal_spike_flag: bool
    pattern_summary: Optional[str] = None


class HistoricalPatternAnalyticsResponse(CoreModel):
    records: List[MultiYearTrendRecordRead]
    identified_seasonal_patterns: List[str]
    long_term_recommendations: List[str]
