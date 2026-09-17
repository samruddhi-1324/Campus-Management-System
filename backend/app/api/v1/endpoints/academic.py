from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user_id
from app.core.database import get_db
from app.models.academic import AcademicConcernType
from app.schemas.academic import AcademicConcernCreate, AcademicConcernRead
from app.services.academic_service import get_academic_service

router = APIRouter()


@router.post("/concerns", response_model=AcademicConcernRead)
async def submit_academic_concern(
    concern_in: AcademicConcernCreate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Reporter submits confidential academic grievance (FR-2.1, FR-2.2)."""
    academic_service = get_academic_service(db)
    return await academic_service.create_academic_concern(concern_in, reporter_id=user_id)


@router.get("/officer/queue", response_model=list[AcademicConcernRead])
async def list_academic_queue(
    concern_type: AcademicConcernType | None = Query(None),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Designated Academic Affairs officer views academic queue (FR-2.2, FR-2.3)."""
    academic_service = get_academic_service(db)
    return await academic_service.list_academic_queue(officer_id=user_id, concern_type=concern_type)


@router.get("/concerns/{concern_id}", response_model=AcademicConcernRead)
async def get_academic_concern_detail(
    concern_id: str,
    access_reason: str = Query("Routine Triage", description="Mandatory reason for accessing confidential record"),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Fetch academic concern with automatic confidential access audit logging (FR-2.2)."""
    academic_service = get_academic_service(db)
    return await academic_service.get_academic_concern(concern_id=concern_id, officer_id=user_id, access_reason=access_reason)
