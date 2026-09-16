from typing import List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.api.deps import get_current_user_id
from app.schemas.recommendation import RecurrencePatternRead

router = APIRouter()


@router.get("/patterns", response_model=List[RecurrencePatternRead])
async def list_recurrence_patterns(
    window_days: int = Query(30, ge=7, le=180),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """View detected recurring equipment & location issues (FR-2.6)."""
    pass


@router.post("/patterns/{pattern_id}/convert-to-replacement")
async def convert_pattern_to_replacement(
    pattern_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Convert recurring issue to formal permanent replacement recommendation (FR-2.7)."""
    pass
