from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.voice import VoiceTranscriptionRequest, VoiceTranscriptionResponse


class VoiceService:
    """Voice input audio storage and speech-to-text pipeline (FR-3.1)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def transcribe_audio_attachment(self, request: VoiceTranscriptionRequest, user_id: str) -> VoiceTranscriptionResponse:
        pass


def get_voice_service(db: AsyncSession) -> VoiceService:
    return VoiceService(db)
