from typing import Optional
from datetime import datetime
from app.schemas.base import CoreModel


class PresignedUploadRequest(CoreModel):
    file_name: str
    mime_type: str
    size_bytes: int


class PresignedUploadResponse(CoreModel):
    attachment_id: str
    upload_url: str
    storage_path: str
    expires_in: int


class PresignedDownloadResponse(CoreModel):
    download_url: str
    expires_in: int


class AttachmentRead(CoreModel):
    id: str
    issue_id: str
    attachment_type: str
    mime_type: str
    size_bytes: int
    uploaded_at: datetime
