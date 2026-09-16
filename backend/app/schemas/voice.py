from typing import Optional
from app.schemas.base import CoreModel
from app.schemas.ai import AIClassificationResponse


class VoiceTranscriptionRequest(CoreModel):
    attachment_id: str
    audio_format: str = "m4a"
    language_code: Optional[str] = "en"


class VoiceTranscriptionResponse(CoreModel):
    transcribed_text: str
    confidence: float
    duration_seconds: float
    classification: Optional[AIClassificationResponse] = None
