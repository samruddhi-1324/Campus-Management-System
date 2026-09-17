from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user_id
from app.core.database import get_db
from app.schemas.tenant import InstitutionCreate, InstitutionRead
from app.services.tenant_service import get_tenant_service

router = APIRouter()


@router.post("/", response_model=InstitutionRead, status_code=status.HTTP_201_CREATED)
async def create_institution_tenant(
    inst_in: InstitutionCreate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> Any:
    """Provision multi-institution tenant (FR-3.4, NFR-SCAL-01)."""
    service = get_tenant_service(db)
    existing_domain = await service.get_institution_by_domain(inst_in.domain)
    if existing_domain:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Institution with domain '{inst_in.domain}' already exists.",
        )
    existing_slug = await service.get_institution_by_slug(inst_in.slug)
    if existing_slug:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Institution with slug '{inst_in.slug}' already exists.",
        )
    return await service.create_institution(inst_in)


@router.get("/", response_model=list[InstitutionRead])
async def list_institution_tenants(
    db: AsyncSession = Depends(get_db),
) -> Any:
    """Public discovery endpoint for active institutions (FR-3.6)."""
    service = get_tenant_service(db)
    return await service.list_institutions(active_only=True)


@router.get("/{identifier}", response_model=InstitutionRead)
async def get_institution(
    identifier: str,
    db: AsyncSession = Depends(get_db),
) -> Any:
    """Lookup institution by ID, slug, or custom domain."""
    service = get_tenant_service(db)
    inst = (
        await service.get_institution_by_id(identifier)
        or await service.get_institution_by_slug(identifier)
        or await service.get_institution_by_domain(identifier)
    )
    if not inst:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Institution '{identifier}' not found.",
        )
    return inst
