from sqlalchemy.ext.asyncio import AsyncSession

from app.schemas.search import NLSearchRequest, NLSearchResponse


class NLSearchService:
    """Natural-language query parser and role-scoped search service (FR-3.2, NFR-SEC-01)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def execute_natural_search(self, request: NLSearchRequest, user_id: str, user_role: str) -> NLSearchResponse:
        pass


def get_nl_search_service(db: AsyncSession) -> NLSearchService:
    return NLSearchService(db)
