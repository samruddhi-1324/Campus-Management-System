from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.api.deps import get_current_user_id
from app.schemas.attachment import PresignedUploadRequest, PresignedUploadResponse, PresignedDownloadResponse

router = APIRouter()


@router.post("/presigned-upload", response_model=PresignedUploadResponse)
async def get_presigned_upload_url(
    request: PresignedUploadRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Generate signed upload URL for direct client-to-Supabase Storage transfer (FR-DATA-21)."""
    pass


@router.get("/{attachment_id}/presigned-download", response_model=PresignedDownloadResponse)
async def get_presigned_download_url(
    attachment_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Generate time-limited signed download URL after access verification (FR-DATA-20, NFR-SEC-01)."""
    pass
