"""SQLAlchemy ORM Models Registry."""
from app.models.academic import (
    AcademicConcern,
    AcademicConcernType,
    ConfidentialAccessLog,
)
from app.models.audit import AIInsight, AuditAction, AuditLogEntry, NotificationLog
from app.models.base import Base, TimestampMixin
from app.models.historical_pattern import HistoricalTrendRecord
from app.models.issue import (
    Issue,
    IssueAttachment,
    IssueGroup,
    IssueStateHistory,
    IssueStatus,
    IssueUpdate,
    IssueUrgency,
)
from app.models.master_data import Building, Category, Department, Room, Team
from app.models.recommendation import (
    Recommendation,
    RecommendationType,
    RecurrencePattern,
)
from app.models.sla import CategorySLAConfig
from app.models.tenant import Institution
from app.models.user import (
    ChannelType,
    NotificationPreference,
    User,
    UserContactChannel,
    UserDevice,
    UserRole,
)

__all__ = [
    "AIInsight",
    "AcademicConcern",
    "AcademicConcernType",
    "AuditAction",
    "AuditLogEntry",
    "Base",
    "Building",
    "Category",
    "CategorySLAConfig",
    "ChannelType",
    "ConfidentialAccessLog",
    "Department",
    "HistoricalTrendRecord",
    "Institution",
    "Issue",
    "IssueAttachment",
    "IssueGroup",
    "IssueStateHistory",
    "IssueStatus",
    "IssueUpdate",
    "IssueUrgency",
    "NotificationLog",
    "NotificationPreference",
    "Recommendation",
    "RecommendationType",
    "RecurrencePattern",
    "Room",
    "Team",
    "TimestampMixin",
    "User",
    "UserContactChannel",
    "UserDevice",
    "UserRole",
]
