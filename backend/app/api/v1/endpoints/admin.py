from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.api.deps import get_current_user_id
from app.schemas.master_data import BuildingCreate, BuildingRead, CategoryCreate, CategoryRead, TeamCreate, TeamRead
from app.schemas.audit import AuditLogRead

router = APIRouter()


@router.post("/buildings", response_model=BuildingRead)
async def create_building(
    building_in: BuildingCreate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Admin creates building (FR-1.24)."""
    pass


@router.get("/audit-logs", response_model=List[AuditLogRead])
async def list_audit_logs(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Admin views system audit trail (FR-1.27, NFR-AUDIT-01)."""
    pass
