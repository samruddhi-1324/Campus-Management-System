from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_active_user, get_db
from app.models.user import User
from app.schemas.ai import (
    AIClassificationRequest,
    AIClassificationResponse,
    AIDedupCheckRequest,
    AIDedupCheckResponse,
    AIStatusDraftRequest,
    AIStatusDraftResponse,
)
from app.services.ai_advisory_service import get_ai_advisory_service

router = APIRouter()


@router.post("/classify", response_model=AIClassificationResponse)
async def classify_issue(
    request: AIClassificationRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """AI advisory category & urgency suggestion (FR-AI-01, FR-AI-02)."""
    service = get_ai_advisory_service(db)
    return await service.get_classification_advice(request)


@router.post("/dedup-check", response_model=AIDedupCheckResponse)
async def check_duplicates(
    request: AIDedupCheckRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """AI duplicate check in vicinity (FR-AI-03)."""
    service = get_ai_advisory_service(db)
    return await service.check_duplicate_issues(request)


@router.post("/draft-status", response_model=AIStatusDraftResponse)
async def draft_status_update(
    request: AIStatusDraftRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """AI draft update message for coordinator (FR-AI-06)."""
    service = get_ai_advisory_service(db)
    return await service.draft_status_message(request)
