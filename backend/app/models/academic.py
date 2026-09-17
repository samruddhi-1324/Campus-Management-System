from enum import Enum
from typing import Optional
from datetime import datetime, timezone
from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Text, Enum as SQLEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin


class AcademicConcernType(str, Enum):
    EXAM_GRIEVANCE = "exam_grievance"
    GRADE_DISPUTE = "grade_dispute"
    COURSE_SCHEDULING = "course_scheduling"
    FACULTY_ADVISING = "faculty_advising"
    OTHER = "other"


class AcademicConcern(Base, TimestampMixin):
    """Academic Concern entity with strict confidentiality & isolated routing (FR-2.1..2.3, NFR-SEC-01)."""
    __tablename__ = "academic_concerns"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    issue_id: Mapped[str] = mapped_column(String(36), ForeignKey("issues.id", ondelete="CASCADE"), unique=True, index=True, nullable=False)
    concern_type: Mapped[AcademicConcernType] = mapped_column(
        SQLEnum(AcademicConcernType, name="academic_concern_type_enum"),
        nullable=False,
    )
    course_code: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    academic_term: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    assigned_academic_officer_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey("users.id"), nullable=True)
    is_confidential: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)


class ConfidentialAccessLog(Base, TimestampMixin):
    """Audit trail for viewing confidential academic concerns (FR-2.2, NFR-AUDIT-01)."""
    __tablename__ = "confidential_access_logs"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    academic_concern_id: Mapped[str] = mapped_column(String(36), ForeignKey("academic_concerns.id", ondelete="CASCADE"), index=True, nullable=False)
    accessed_by: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), index=True, nullable=False)
    access_reason: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    accessed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
