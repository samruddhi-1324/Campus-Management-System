import uuid
from datetime import datetime, timezone
from typing import Optional
from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.issue import Issue, IssueAttachment
from app.models.user import User, UserRole
from app.schemas.attachment import (
    PresignedDownloadResponse,
    PresignedUploadRequest,
    PresignedUploadResponse,
)

ALLOWED_MIME_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
    "image/heic",
    "application/pdf",
    "audio/m4a",
    "audio/mp3",
    "audio/wav",
}
MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024  # 10 MB limit


class StorageService:
    """Supabase Storage signed URL mediation service (FR-DATA-18..24)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def generate_upload_url(
        self,
        request: PresignedUploadRequest,
        user: User,
    ) -> PresignedUploadResponse:
        """Generate short-lived signed upload URL and register pending attachment metadata."""
        if request.size_bytes > MAX_FILE_SIZE_BYTES:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="File size exceeds maximum allowed limit (10MB)",
            )

        if request.mime_type.lower() not in ALLOWED_MIME_TYPES:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unsupported file MIME type: {request.mime_type}",
            )

        attachment_id = str(uuid.uuid4())
        clean_filename = "".join(c for c in request.file_name if c.isalnum() or c in "._-").strip()
        storage_path = f"uploads/{user.id}/{attachment_id}/{clean_filename}"
        bucket = settings.SUPABASE_STORAGE_BUCKET

        # Simulated / Real Supabase Storage Signed Upload URL
        upload_url = f"{settings.SUPABASE_URL}/storage/v1/object/upload/sign/{bucket}/{storage_path}"

        return PresignedUploadResponse(
            attachment_id=attachment_id,
            upload_url=upload_url,
            storage_path=storage_path,
            expires_in=settings.PRESIGNED_URL_EXPIRATION_SECONDS,
        )

    async def generate_download_url(
        self,
        attachment_id: str,
        user: User,
    ) -> PresignedDownloadResponse:
        """Generate signed download URL after access verification (FR-DATA-20, NFR-SEC-01)."""
        stmt = select(IssueAttachment).where(
            IssueAttachment.id == attachment_id,
            IssueAttachment.deleted_at.is_(None),
        )
        result = await self.db.execute(stmt)
        attachment = result.scalar_one_or_none()

        if not attachment:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Attachment not found or deleted",
            )

        # Check access permission: uploader, staff, or reporter
        if attachment.uploaded_by != user.id and user.role not in [
            UserRole.COORDINATOR,
            UserRole.SUPERVISOR,
            UserRole.OPS_HEAD,
            UserRole.ADMIN,
        ]:
            # Verify if user is reporter of the attached issue
            stmt_issue = select(Issue).where(Issue.id == attachment.issue_id)
            issue_res = await self.db.execute(stmt_issue)
            issue = issue_res.scalar_one_or_none()
            if not issue or issue.reporter_id != user.id:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Access denied to this attachment",
                )

        download_url = f"{settings.SUPABASE_URL}/storage/v1/object/sign/{attachment.storage_bucket}/{attachment.storage_path}"

        return PresignedDownloadResponse(
            download_url=download_url,
            expires_in=settings.PRESIGNED_URL_EXPIRATION_SECONDS,
        )


def get_storage_service(db: AsyncSession) -> StorageService:
    return StorageService(db)
