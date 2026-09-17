from typing import Optional
from sqlalchemy import BigInteger, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base, TimestampMixin


class HistoricalTrendRecord(Base, TimestampMixin):
    """Multi-year pattern analysis & seasonal trend metrics (FR-3.5)."""
    __tablename__ = "historical_trend_records"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    institution_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey("institutions.id"), index=True, nullable=True)
    category_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey("categories.id"), index=True, nullable=True)
    year: Mapped[int] = mapped_column(Integer, index=True, nullable=False)
    quarter: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    month: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    total_volume: Mapped[int] = mapped_column(Integer, nullable=False)
    avg_resolution_hours: Mapped[float] = mapped_column(nullable=False)
    seasonal_spike_flag: Mapped[bool] = mapped_column(default=False, nullable=False)
    pattern_summary: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    aggregated_metrics: Mapped[dict] = mapped_column(JSONB, default=dict, nullable=False)
