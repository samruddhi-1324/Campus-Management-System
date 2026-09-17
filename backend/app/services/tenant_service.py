from sqlalchemy.ext.asyncio import AsyncSession

from app.models.tenant import Institution
from app.schemas.tenant import InstitutionCreate


class TenantService:
    """Multi-institution isolation and tenant onboarding service (FR-3.4, NFR-SCAL-01)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_institution(self, inst_in: InstitutionCreate) -> Institution:
        pass

    async def get_institution_by_domain(self, domain: str) -> Institution | None:
        pass


def get_tenant_service(db: AsyncSession) -> TenantService:
    return TenantService(db)
