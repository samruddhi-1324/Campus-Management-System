import uuid
from typing import Sequence
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.tenant import Institution
from app.schemas.tenant import InstitutionCreate


class TenantService:
    """Multi-institution isolation and tenant onboarding service (FR-3.4, NFR-SCAL-01)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_institution(self, inst_in: InstitutionCreate) -> Institution:
        institution = Institution(
            id=str(uuid.uuid4()),
            name=inst_in.name,
            slug=inst_in.slug.lower().strip(),
            domain=inst_in.domain.lower().strip(),
            logo_url=inst_in.logo_url,
            settings=inst_in.settings or {},
            is_active=True,
        )
        self.db.add(institution)
        await self.db.commit()
        await self.db.refresh(institution)
        return institution

    async def list_institutions(self, active_only: bool = True) -> Sequence[Institution]:
        query = select(Institution)
        if active_only:
            query = query.where(Institution.is_active.is_(True))
        query = query.order_by(Institution.name.asc())
        result = await self.db.execute(query)
        return result.scalars().all()

    async def get_institution_by_id(self, institution_id: str) -> Institution | None:
        query = select(Institution).where(Institution.id == institution_id)
        result = await self.db.execute(query)
        return result.scalars().first()

    async def get_institution_by_domain(self, domain: str) -> Institution | None:
        clean_domain = domain.lower().strip()
        query = select(Institution).where(Institution.domain == clean_domain)
        result = await self.db.execute(query)
        return result.scalars().first()

    async def get_institution_by_slug(self, slug: str) -> Institution | None:
        clean_slug = slug.lower().strip()
        query = select(Institution).where(Institution.slug == clean_slug)
        result = await self.db.execute(query)
        return result.scalars().first()

    async def update_institution(
        self,
        institution_id: str,
        settings: dict | None = None,
        logo_url: str | None = None,
        is_active: bool | None = None,
    ) -> Institution | None:
        inst = await self.get_institution_by_id(institution_id)
        if not inst:
            return None
        if settings is not None:
            inst.settings = settings
        if logo_url is not None:
            inst.logo_url = logo_url
        if is_active is not None:
            inst.is_active = is_active
        await self.db.commit()
        await self.db.refresh(inst)
        return inst


def get_tenant_service(db: AsyncSession) -> TenantService:
    return TenantService(db)
