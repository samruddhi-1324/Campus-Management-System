
from sqlalchemy import Boolean, String
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base, TimestampMixin


class Institution(Base, TimestampMixin):
    """Multi-institution tenancy entity (FR-3.4, NFR-SCAL-01)."""
    __tablename__ = "institutions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    name: Mapped[str] = mapped_column(String(150), unique=True, nullable=False)
    slug: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    domain: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)  # e.g., institution.edu
    logo_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    settings: Mapped[dict] = mapped_column(JSONB, default=dict, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
