from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.api.deps import get_current_user_id
from app.schemas.sla import CategorySLAConfigCreate, CategorySLAConfigRead

router = APIRouter()


@router.post("/configs", response_model=CategorySLAConfigRead)
async def create_sla_config(
    config_in: CategorySLAConfigCreate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Admin configures category/building SLA targets (FR-2.9)."""
    pass


@router.get("/configs", response_model=List[CategorySLAConfigRead])
async def list_sla_configs(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """List active SLA target configurations."""
    pass
