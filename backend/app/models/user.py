from datetime import UTC, datetime
from enum import StrEnum

from sqlalchemy import Boolean, DateTime, ForeignKey, String
from sqlalchemy import Enum as SQLEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin


class UserRole(StrEnum):
    REPORTER = "reporter"
    COORDINATOR = "coordinator"
    SUPERVISOR = "supervisor"
    OPS_HEAD = "ops_head"
    ADMIN = "admin"


class ChannelType(StrEnum):
    EMAIL = "email"
    SMS = "sms"
    WHATSAPP = "whatsapp"
    IN_APP = "in_app"


class User(Base, TimestampMixin):
    """User entity supporting 5 actor roles (SRS Section 3 & 12.1)."""
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    full_name: Mapped[str] = mapped_column(String(150), nullable=False)
    role: Mapped[UserRole] = mapped_column(
        SQLEnum(UserRole, name="user_role_enum"),
        default=UserRole.REPORTER,
        index=True,
        nullable=False,
    )
    department_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("departments.id"), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    # Relationships
    contact_channels: Mapped[list["UserContactChannel"]] = relationship("UserContactChannel", back_populates="user", cascade="all, delete-orphan")
    devices: Mapped[list["UserDevice"]] = relationship("UserDevice", back_populates="user", cascade="all, delete-orphan")
    notification_preferences: Mapped[list["NotificationPreference"]] = relationship("NotificationPreference", back_populates="user", cascade="all, delete-orphan")


class UserContactChannel(Base, TimestampMixin):
    """Registered contact channels per user for multi-channel notifications (FR-NOTIF-02)."""
    __tablename__ = "user_contact_channels"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    channel_type: Mapped[ChannelType] = mapped_column(SQLEnum(ChannelType, name="contact_channel_type_enum"), nullable=False)
    address_or_number: Mapped[str] = mapped_column(String(255), nullable=False)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    user: Mapped["User"] = relationship("User", back_populates="contact_channels")


class UserDevice(Base, TimestampMixin):
    """Active user devices for push notifications (FR-NOTIF-21..34)."""
    __tablename__ = "user_devices"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    fcm_token: Mapped[str | None] = mapped_column(String(512), nullable=True)  # Nullable for WebSocket devices (FR-NOTIF-31)
    transport_type: Mapped[str] = mapped_column(String(20), default="fcm", nullable=False)  # fcm | websocket
    platform: Mapped[str] = mapped_column(String(20), nullable=False)  # android | ios | web | windows | macos | linux
    app_version: Mapped[str] = mapped_column(String(20), nullable=False)
    device_model: Mapped[str | None] = mapped_column(String(100), nullable=True)
    locale: Mapped[str] = mapped_column(String(10), default="en", nullable=False)
    timezone: Mapped[str] = mapped_column(String(50), default="UTC", nullable=False)
    last_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(UTC))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    user: Mapped["User"] = relationship("User", back_populates="devices")


class NotificationPreference(Base, TimestampMixin):
    """User channel preferences for non-critical notifications (FR-NOTIF-11)."""
    __tablename__ = "notification_preferences"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    event_category: Mapped[str] = mapped_column(String(50), nullable=False)  # issue_assigned | issue_updated | issue_resolved
    channel_type: Mapped[ChannelType] = mapped_column(SQLEnum(ChannelType, name="pref_channel_type_enum"), nullable=False)
    enabled: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    user: Mapped["User"] = relationship("User", back_populates="notification_preferences")
