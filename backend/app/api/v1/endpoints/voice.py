from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user_id
from app.core.database import get_db
from app.schemas.voice import VoiceTranscriptionRequest, VoiceTranscriptionResponse

router = APIRouter()


@router.post("/transcribe", response_model=VoiceTranscriptionResponse)
async def transcribe_voice_issue(
    request: VoiceTranscriptionRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Transcribe voice report and pass through AI classification pipeline (FR-3.1)."""
