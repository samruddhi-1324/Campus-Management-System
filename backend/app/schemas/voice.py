from app.schemas.ai import AIClassificationResponse
from app.schemas.base import CoreModel


class VoiceTranscriptionRequest(CoreModel):
    attachment_id: str
    audio_format: str = "m4a"
    language_code: str | None = "en"


class VoiceTranscriptionResponse(CoreModel):
    transcribed_text: str
    confidence: float
    duration_seconds: float
    classification: AIClassificationResponse | None = None
