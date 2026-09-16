from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.api.deps import get_current_user_id
from app.schemas.ai import (
    AIClassificationRequest,
    AIClassificationResponse,
    AIDedupCheckRequest,
    AIDedupCheckResponse,
    AIStatusDraftRequest,
    AIStatusDraftResponse,
)

router = APIRouter()


@router.post("/classify", response_model=AIClassificationResponse)
async def classify_issue(
    request: AIClassificationRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """AI advisory category & urgency suggestion (FR-AI-01, FR-AI-02)."""
    pass


@router.post("/dedup-check", response_model=AIDedupCheckResponse)
async def check_duplicates(
    request: AIDedupCheckRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """AI duplicate check in vicinity (FR-AI-03)."""
    pass


@router.post("/draft-status", response_model=AIStatusDraftResponse)
async def draft_status_update(
    request: AIStatusDraftRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """AI draft update message for coordinator (FR-AI-06)."""
    pass
