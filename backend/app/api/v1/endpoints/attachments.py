from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_active_user, get_db
from app.models.user import User
from app.schemas.attachment import (
    PresignedDownloadResponse,
    PresignedUploadRequest,
    PresignedUploadResponse,
)
from app.services.storage_service import get_storage_service

router = APIRouter()


@router.post("/presigned-upload", response_model=PresignedUploadResponse, status_code=status.HTTP_201_CREATED)
async def get_presigned_upload_url(
    request: PresignedUploadRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Generate signed upload URL for direct client-to-Supabase Storage transfer (FR-DATA-21)."""
    service = get_storage_service(db)
    return await service.generate_upload_url(request, user=current_user)


@router.get("/{attachment_id}/presigned-download", response_model=PresignedDownloadResponse)
async def get_presigned_download_url(
    attachment_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Generate time-limited signed download URL after access verification (FR-DATA-20, NFR-SEC-01)."""
    service = get_storage_service(db)
    return await service.generate_download_url(attachment_id, user=current_user)
