from datetime import datetime
from enum import StrEnum

from sqlalchemy import BigInteger, DateTime, ForeignKey, String, Text
from sqlalchemy import Enum as SQLEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin


class IssueStatus(StrEnum):
    REPORTED = "reported"
    UNDERSTOOD = "understood"
    ASSIGNED = "assigned"
    INVESTIGATING = "investigating"
    ACTION_TAKEN = "action_taken"
    RESOLVED = "resolved"
    CONFIRMED = "confirmed"
    CLOSED = "closed"
    # Sub-states
    WAITING_FOR_INFO = "waiting_for_info"
    ESCALATED = "escalated"
    REOPENED = "reopened"


class IssueUrgency(StrEnum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class Issue(Base, TimestampMixin):
    """Core Issue entity (SRS Sections 5, 12.1 & 16)."""

    __tablename__ = "issues"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    reference_number: Mapped[str] = mapped_column(String(30), unique=True, nullable=False)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)

    # Classification & Location
    category_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("categories.id"), index=True, nullable=True)
    building_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("buildings.id"), index=True, nullable=True)
    room_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("rooms.id"), nullable=True)
    location_details: Mapped[str | None] = mapped_column(String(255), nullable=True)

    # State Machine & Urgency
    status: Mapped[IssueStatus] = mapped_column(
        SQLEnum(IssueStatus, name="issue_status_enum"),
        default=IssueStatus.REPORTED,
        index=True,
        nullable=False,
    )
    urgency: Mapped[IssueUrgency] = mapped_column(
        SQLEnum(IssueUrgency, name="issue_urgency_enum"),
        default=IssueUrgency.MEDIUM,
        index=True,
        nullable=False,
    )
    ai_suggested_urgency: Mapped[str | None] = mapped_column(String(20), nullable=True)
    ai_urgency_rationale: Mapped[str | None] = mapped_column(Text, nullable=True)

    # Ownership & Assignments
    reporter_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), index=True, nullable=False)
    assigned_coordinator_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("users.id"), index=True, nullable=True
    )
    assigned_team_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("teams.id"), nullable=True)

    # SLA Tracking
    expected_resolution_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), index=True, nullable=True)
    resolved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    confirmed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    closed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    # Relationships
    attachments: Mapped[list["IssueAttachment"]] = relationship(
        "IssueAttachment", back_populates="issue", cascade="all, delete-orphan"
    )
    updates: Mapped[list["IssueUpdate"]] = relationship(
        "IssueUpdate", back_populates="issue", cascade="all, delete-orphan"
    )
    state_history: Mapped[list["IssueStateHistory"]] = relationship(
        "IssueStateHistory", back_populates="issue", cascade="all, delete-orphan"
    )


class IssueAttachment(Base, TimestampMixin):
    """Attachment metadata for files stored in Supabase Storage private buckets (FR-DATA-18..24)."""

    __tablename__ = "issue_attachments"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    issue_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("issues.id", ondelete="CASCADE"), index=True, nullable=False
    )
    attachment_type: Mapped[str] = mapped_column(
        String(20), default="photo", nullable=False
    )  # photo (Phase 1), voice (Phase 3)
    storage_bucket: Mapped[str] = mapped_column(String(100), nullable=False)
    storage_path: Mapped[str] = mapped_column(String(512), nullable=False)
    mime_type: Mapped[str] = mapped_column(String(100), nullable=False)
    size_bytes: Mapped[int] = mapped_column(BigInteger, nullable=False)
    uploaded_by: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), nullable=False)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    issue: Mapped["Issue"] = relationship("Issue", back_populates="attachments")


class IssueUpdate(Base, TimestampMixin):
    """Communication thread updates (internal staff notes vs. external public updates) (FR-1.13)."""

    __tablename__ = "issue_updates"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    issue_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("issues.id", ondelete="CASCADE"), index=True, nullable=False
    )
    author_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), nullable=False)
    visibility: Mapped[str] = mapped_column(
        String(20), default="external", nullable=False
    )  # external (public) | internal (staff-only)
    message: Mapped[str] = mapped_column(Text, nullable=False)

    issue: Mapped["Issue"] = relationship("Issue", back_populates="updates")


class IssueStateHistory(Base, TimestampMixin):
    """Immutable state transition audit trail (FR-1.29, NFR-AUDIT-01)."""

    __tablename__ = "issue_state_history"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    issue_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("issues.id", ondelete="CASCADE"), index=True, nullable=False
    )
    from_state: Mapped[str] = mapped_column(String(30), nullable=False)
    to_state: Mapped[str] = mapped_column(String(30), nullable=False)
    changed_by: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), nullable=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)

    issue: Mapped["Issue"] = relationship("Issue", back_populates="state_history")


class IssueGroup(Base, TimestampMixin):
    """Deduplication groups confirmed by human action (FR-1.28, FR-1.30, FR-AI-03)."""

    __tablename__ = "issue_groups"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    primary_issue_id: Mapped[str] = mapped_column(String(36), ForeignKey("issues.id"), nullable=False)
    created_by: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), nullable=False)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
