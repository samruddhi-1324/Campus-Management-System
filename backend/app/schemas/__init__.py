"""Pydantic v2 validation schemas registry."""
from app.schemas.base import ApiResponse, CoreModel
from app.schemas.auth import LoginRequest, TokenResponse
from app.schemas.user import UserCreate, UserUpdate, UserRead
from app.schemas.issue import (
    IssueCreate,
    IssueStatusUpdate,
    IssueAssignmentUpdate,
    IssueUrgencyUpdate,
    IssueResolutionConfirm,
    IssueRead,
)
from app.schemas.attachment import (
    PresignedUploadRequest,
    PresignedUploadResponse,
    PresignedDownloadResponse,
    AttachmentRead,
)
from app.schemas.master_data import (
    BuildingCreate,
    BuildingRead,
    RoomCreate,
    RoomRead,
    CategoryCreate,
    CategoryRead,
    TeamCreate,
    TeamRead,
)
from app.schemas.audit import AuditLogRead, AIInsightRead
from app.schemas.notification import (
    DeviceRegistrationCreate,
    NotificationPreferenceUpdate,
    NotificationLogRead,
)
from app.schemas.analytics import OpsHeadAnalyticsResponse, CampusVolumeMetrics
from app.schemas.ai import (
    AIClassificationRequest,
    AIClassificationResponse,
    AIDedupCheckRequest,
    AIDedupCheckResponse,
    AIStatusDraftRequest,
    AIStatusDraftResponse,
)

__all__ = [
    "ApiResponse",
    "CoreModel",
    "LoginRequest",
    "TokenResponse",
    "UserCreate",
    "UserUpdate",
    "UserRead",
    "IssueCreate",
    "IssueStatusUpdate",
    "IssueAssignmentUpdate",
    "IssueUrgencyUpdate",
    "IssueResolutionConfirm",
    "IssueRead",
    "PresignedUploadRequest",
    "PresignedUploadResponse",
    "PresignedDownloadResponse",
    "AttachmentRead",
    "BuildingCreate",
    "BuildingRead",
    "RoomCreate",
    "RoomRead",
    "CategoryCreate",
    "CategoryRead",
    "TeamCreate",
    "TeamRead",
    "AuditLogRead",
    "AIInsightRead",
    "DeviceRegistrationCreate",
    "NotificationPreferenceUpdate",
    "NotificationLogRead",
    "OpsHeadAnalyticsResponse",
    "CampusVolumeMetrics",
    "AIClassificationRequest",
    "AIClassificationResponse",
    "AIDedupCheckRequest",
    "AIDedupCheckResponse",
    "AIStatusDraftRequest",
    "AIStatusDraftResponse",
]
