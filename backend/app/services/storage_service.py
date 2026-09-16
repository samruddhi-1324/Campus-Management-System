from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.attachment import PresignedUploadRequest, PresignedUploadResponse, PresignedDownloadResponse


class StorageService:
    """Supabase Storage signed URL mediation service (FR-DATA-18..24)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def generate_upload_url(self, request: PresignedUploadRequest, user_id: str) -> PresignedUploadResponse:
        pass

    async def generate_download_url(self, attachment_id: str, user_id: str) -> PresignedDownloadResponse:
        pass


def get_storage_service(db: AsyncSession) -> StorageService:
    return StorageService(db)
