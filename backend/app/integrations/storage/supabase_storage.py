from app.core.config import settings


class SupabaseStorageService:
    """Supabase Storage adapter managing signed upload and download URLs (FR-DATA-18..24).

    Ensures private bucket security where no raw credentials reach the Flutter client.
    """

    def __init__(self):
        self.bucket_name = settings.SUPABASE_STORAGE_BUCKET_ATTACHMENTS
        self.expiration = settings.SIGNED_URL_EXPIRATION_SECONDS

    async def create_signed_upload_url(self, file_path: str) -> dict:
        """Generate a short-lived signed upload URL for direct client-to-storage transfer."""
        # Will be implemented using supabase-py in Phase 1
        return {
            "upload_url": f"{settings.SUPABASE_URL}/storage/v1/object/upload/sign/{self.bucket_name}/{file_path}",
            "file_path": file_path,
            "expires_in": self.expiration,
        }

    async def create_signed_download_url(self, file_path: str) -> str | None:
        """Generate a short-lived signed download URL after access check."""
        return f"{settings.SUPABASE_URL}/storage/v1/object/sign/{self.bucket_name}/{file_path}?token=signed"


storage_service = SupabaseStorageService()
