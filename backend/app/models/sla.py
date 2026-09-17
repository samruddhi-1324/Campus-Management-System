from typing import Optional
from sqlalchemy import Boolean, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base, TimestampMixin


class CategorySLAConfig(Base, TimestampMixin):
    """Category and Building specific SLA resolution target windows (FR-2.9)."""
    __tablename__ = "category_sla_configs"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    category_id: Mapped[str] = mapped_column(String(36), ForeignKey("categories.id", ondelete="CASCADE"), index=True, nullable=False)
    building_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey("buildings.id", ondelete="CASCADE"), nullable=True)
    urgency_level: Mapped[str] = mapped_column(String(20), nullable=False)  # low, medium, high, critical
    expected_response_hours: Mapped[int] = mapped_column(Integer, default=2, nullable=False)
    expected_resolution_hours: Mapped[int] = mapped_column(Integer, default=24, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
