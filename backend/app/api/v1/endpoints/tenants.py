from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user_id
from app.core.database import get_db
from app.schemas.tenant import InstitutionCreate, InstitutionRead

router = APIRouter()


@router.post("/", response_model=InstitutionRead)
async def create_institution_tenant(
    inst_in: InstitutionCreate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Provision multi-institution tenant (FR-3.4)."""
