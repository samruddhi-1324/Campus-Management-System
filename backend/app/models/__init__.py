"""SQLAlchemy ORM Models package.

Entities defined per SRS Section 12 will be populated phase-wise:
- Base, TimestampMixin
- User, Role (Phase 1)
- Issue, IssueAttachment, IssueUpdate, IssueStateHistory, IssueGroup (Phase 1)
- Building, Room, Department, Category, Team (Phase 1)
- AuditLogEntry, AIInsight (Phase 1)
- UserContactChannel, NotificationPreference, NotificationLog, UserDevice (Phase 1)
- Recommendation (Phase 2)
- RecurrencePattern (Phase 2)
"""
from app.models.base import Base, TimestampMixin

__all__ = ["Base", "TimestampMixin"]
