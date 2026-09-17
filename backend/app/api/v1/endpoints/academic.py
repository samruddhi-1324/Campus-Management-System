
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user_id
from app.core.database import get_db
from app.schemas.academic import AcademicConcernCreate, AcademicConcernRead

router = APIRouter()


@router.post("/", response_model=AcademicConcernRead)
async def submit_academic_concern(
    concern_in: AcademicConcernCreate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Reporter submits confidential academic grievance (FR-2.1, FR-2.2)."""


@router.get("/officer/queue", response_model=list[AcademicConcernRead])
async def list_academic_queue(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Designated Academic Affairs officer views academic queue (FR-2.2, FR-2.3)."""
