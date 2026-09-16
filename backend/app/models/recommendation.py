from enum import Enum
from typing import Optional
from datetime import datetime, timezone
from sqlalchemy import BigInteger, Boolean, DateTime, ForeignKey, Integer, String, Text, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base, TimestampMixin


class RecommendationType(str, Enum):
    RESOLUTION = "resolution"
    PREVENTIVE = "preventive"
    RESOURCING = "resourcing"


class Recommendation(Base, TimestampMixin):
    """Aggregate AI Recommendations for Supervisors, Ops Head and Admins (FR-AI-13..20)."""
    __tablename__ = "recommendations"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    recommendation_type: Mapped[RecommendationType] = mapped_column(
        SQLEnum(RecommendationType, name="recommendation_type_enum"),
        nullable=False,
    )
    scope_reference: Mapped[str] = mapped_column(String(100), nullable=False)  # issue:123, asset:AC-204, category:wifi
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    suggested_action: Mapped[str] = mapped_column(Text, nullable=False)
    evidence_snapshot: Mapped[dict] = mapped_column(JSONB, nullable=False)  # Pre-computed deterministic evidence
    confidence: Mapped[float] = mapped_column(default=0.0, nullable=False)
    model_version: Mapped[str] = mapped_column(String(50), nullable=False)
    human_decision: Optional[Mapped[str]] = mapped_column(String(20), nullable=True)  # accepted | dismissed | acted
    decided_by: Optional[Mapped[str]] = mapped_column(String(36), ForeignKey("users.id"), nullable=True)
    decided_at: Optional[Mapped[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)


class RecurrencePattern(Base, TimestampMixin):
    """Detected recurring equipment/location failures over rolling windows (FR-2.6, FR-2.7, FR-AI-04)."""
    __tablename__ = "recurrence_patterns"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    asset_or_location_ref: Mapped[str] = mapped_column(String(100), index=True, nullable=False)
    failure_count: Mapped[int] = mapped_column(Integer, nullable=False)
    observation_window_days: Mapped[int] = mapped_column(Integer, default=30, nullable=False)
    related_issue_ids: Mapped[list] = mapped_column(JSONB, nullable=False)
    status: Mapped[str] = mapped_column(String(30), default="flagged", nullable=False)  # flagged | confirmed | converted_to_replacement | dismissed
    converted_recommendation_id: Optional[Mapped[str]] = mapped_column(String(36), ForeignKey("recommendations.id"), nullable=True)
