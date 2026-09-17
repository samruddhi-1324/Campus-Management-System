from datetime import datetime
from enum import StrEnum

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text
from sqlalchemy import Enum as SQLEnum
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base, TimestampMixin


class AuditAction(StrEnum):
    CREATE = "create"
    UPDATE = "update"
    ASSIGN = "assign"
    REASSIGN = "reassign"
    STATUS_CHANGE = "status_change"
    PRIORITY_CHANGE = "priority_change"
    RESOLVE = "resolve"
    CLOSE = "close"
    REOPEN = "reopen"
    MERGE = "merge"


class AuditLogEntry(Base, TimestampMixin):
    """System-wide immutable audit trail for security and traceability (FR-1.27, NFR-AUDIT-01)."""
    __tablename__ = "audit_log_entries"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    actor_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), index=True, nullable=False)
    action: Mapped[AuditAction] = mapped_column(SQLEnum(AuditAction, name="audit_action_enum"), nullable=False)
    target_entity: Mapped[str] = mapped_column(String(50), nullable=False)  # issue, user, team, category
    target_id: Mapped[str] = mapped_column(String(36), index=True, nullable=False)
    before_state: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    after_state: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    ip_address: Mapped[str | None] = mapped_column(String(45), nullable=True)
    user_agent: Mapped[str | None] = mapped_column(String(255), nullable=True)


class AIInsight(Base, TimestampMixin):
    """Advisory AI insights record with human decision tracking (FR-AI-01..12, Section 12.1)."""
    __tablename__ = "ai_insights"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    issue_id: Mapped[str] = mapped_column(String(36), ForeignKey("issues.id", ondelete="CASCADE"), index=True, nullable=False)
    insight_type: Mapped[str] = mapped_column(String(50), nullable=False)  # classification | urgency | dedup | recurrence | summary
    payload: Mapped[dict] = mapped_column(JSONB, nullable=False)
    confidence: Mapped[float] = mapped_column(default=0.0, nullable=False)
    human_decision: Mapped[str | None] = mapped_column(String(20), nullable=True)  # accepted | overridden | dismissed
    decided_by: Mapped[str | None] = mapped_column(String(36), ForeignKey("users.id"), nullable=True)
    decided_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class NotificationLog(Base, TimestampMixin):
    """Delivery log entry for every outbound communication attempt (FR-NOTIF-04, FR-NOTIF-05)."""
    __tablename__ = "notification_logs"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    channel: Mapped[str] = mapped_column(String(20), nullable=False)  # in_app | email | sms | whatsapp | push
    template: Mapped[str] = mapped_column(String(100), nullable=False)
    provider: Mapped[str] = mapped_column(String(50), nullable=False)  # internal | smtp | brevo | resend | twilio | meta | fcm | websocket
    provider_message_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    related_issue_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("issues.id", ondelete="SET NULL"), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="queued", nullable=False)  # queued | sent | delivered | failed | suppressed
    attempt_count: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    idempotency_key: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    error_detail: Mapped[str | None] = mapped_column(Text, nullable=True)
    sent_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
