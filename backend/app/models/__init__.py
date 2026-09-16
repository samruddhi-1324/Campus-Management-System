"""SQLAlchemy ORM Models Registry."""
from app.models.base import Base, TimestampMixin
from app.models.user import User, UserRole, UserContactChannel, UserDevice, NotificationPreference, ChannelType
from app.models.master_data import Department, Building, Room, Category, Team
from app.models.issue import Issue, IssueStatus, IssueUrgency, IssueAttachment, IssueUpdate, IssueStateHistory, IssueGroup
from app.models.audit import AuditLogEntry, AuditAction, AIInsight, NotificationLog
from app.models.academic import AcademicConcern, AcademicConcernType, ConfidentialAccessLog
from app.models.recommendation import Recommendation, RecommendationType, RecurrencePattern
from app.models.sla import CategorySLAConfig

__all__ = [
    "Base",
    "TimestampMixin",
    "User",
    "UserRole",
    "UserContactChannel",
    "UserDevice",
    "NotificationPreference",
    "ChannelType",
    "Department",
    "Building",
    "Room",
    "Category",
    "Team",
    "Issue",
    "IssueStatus",
    "IssueUrgency",
    "IssueAttachment",
    "IssueUpdate",
    "IssueStateHistory",
    "IssueGroup",
    "AuditLogEntry",
    "AuditAction",
    "AIInsight",
    "NotificationLog",
    "AcademicConcern",
    "AcademicConcernType",
    "ConfidentialAccessLog",
    "Recommendation",
    "RecommendationType",
    "RecurrencePattern",
    "CategorySLAConfig",
]
