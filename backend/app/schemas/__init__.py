"""Pydantic v2 validation schemas registry."""
from app.schemas.academic import AcademicConcernCreate, AcademicConcernRead
from app.schemas.ai import (
    AIClassificationRequest,
    AIClassificationResponse,
    AIDedupCheckRequest,
    AIDedupCheckResponse,
    AIStatusDraftRequest,
    AIStatusDraftResponse,
)
from app.schemas.analytics import CampusVolumeMetrics, OpsHeadAnalyticsResponse
from app.schemas.attachment import (
    AttachmentRead,
    PresignedDownloadResponse,
    PresignedUploadRequest,
    PresignedUploadResponse,
)
from app.schemas.audit import AIInsightRead, AuditLogRead
from app.schemas.auth import LoginRequest, TokenResponse
from app.schemas.base import ApiResponse, CoreModel
from app.schemas.historical_pattern import (
    HistoricalPatternAnalyticsResponse,
    MultiYearTrendRecordRead,
)
from app.schemas.issue import (
    IssueAssignmentUpdate,
    IssueCreate,
    IssueRead,
    IssueResolutionConfirm,
    IssueStatusUpdate,
    IssueUrgencyUpdate,
)
from app.schemas.master_data import (
    BuildingCreate,
    BuildingRead,
    CategoryCreate,
    CategoryRead,
    RoomCreate,
    RoomRead,
    TeamCreate,
    TeamRead,
)
from app.schemas.notification import (
    DeviceRegistrationCreate,
    NotificationLogRead,
    NotificationPreferenceUpdate,
)
from app.schemas.recommendation import (
    RecommendationDecisionCreate,
    RecommendationRead,
    RecurrencePatternRead,
)
from app.schemas.search import NLSearchRequest, NLSearchResponse, ParsedSearchFilters
from app.schemas.sla import CategorySLAConfigCreate, CategorySLAConfigRead
from app.schemas.tenant import InstitutionCreate, InstitutionRead
from app.schemas.user import UserCreate, UserRead, UserUpdate
from app.schemas.voice import VoiceTranscriptionRequest, VoiceTranscriptionResponse

__all__ = [
    "AIClassificationRequest",
    "AIClassificationResponse",
    "AIDedupCheckRequest",
    "AIDedupCheckResponse",
    "AIInsightRead",
    "AIStatusDraftRequest",
    "AIStatusDraftResponse",
    "AcademicConcernCreate",
    "AcademicConcernRead",
    "ApiResponse",
    "AttachmentRead",
    "AuditLogRead",
    "BuildingCreate",
    "BuildingRead",
    "CampusVolumeMetrics",
    "CategoryCreate",
    "CategoryRead",
    "CategorySLAConfigCreate",
    "CategorySLAConfigRead",
    "CoreModel",
    "DeviceRegistrationCreate",
    "HistoricalPatternAnalyticsResponse",
    "InstitutionCreate",
    "InstitutionRead",
    "IssueAssignmentUpdate",
    "IssueCreate",
    "IssueRead",
    "IssueResolutionConfirm",
    "IssueStatusUpdate",
    "IssueUrgencyUpdate",
    "LoginRequest",
    "MultiYearTrendRecordRead",
    "NLSearchRequest",
    "NLSearchResponse",
    "NotificationLogRead",
    "NotificationPreferenceUpdate",
    "OpsHeadAnalyticsResponse",
    "ParsedSearchFilters",
    "PresignedDownloadResponse",
    "PresignedUploadRequest",
    "PresignedUploadResponse",
    "RecommendationDecisionCreate",
    "RecommendationRead",
    "RecurrencePatternRead",
    "RoomCreate",
    "RoomRead",
    "TeamCreate",
    "TeamRead",
    "TokenResponse",
    "UserCreate",
    "UserRead",
    "UserUpdate",
    "VoiceTranscriptionRequest",
    "VoiceTranscriptionResponse",
]
