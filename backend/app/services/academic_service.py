from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.academic import AcademicConcern
from app.schemas.academic import AcademicConcernCreate


class AcademicService:
    """Confidential Academic Concern routing and resolution service (FR-2.1..2.3)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_academic_concern(self, concern_in: AcademicConcernCreate, reporter_id: str) -> AcademicConcern:
        pass

    async def get_academic_concern(self, concern_id: str, officer_id: str) -> Optional[AcademicConcern]:
        """Fetch academic concern with mandatory confidential access logging (FR-2.2)."""
        pass


def get_academic_service(db: AsyncSession) -> AcademicService:
    return AcademicService(db)
