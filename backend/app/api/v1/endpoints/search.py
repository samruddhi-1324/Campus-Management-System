from typing import Any

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user_id
from app.core.database import get_db
from app.schemas.search import NLSearchRequest, NLSearchResponse
from app.services.nl_search_service import get_nl_search_service

router = APIRouter()


@router.post("/query", response_model=NLSearchResponse)
async def query_natural_language(
    request: NLSearchRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> Any:
    """Natural-language issue search scoped to user's permitted role view (FR-3.2, NFR-SEC-01)."""
    search_service = get_nl_search_service(db)
    return await search_service.parse_and_execute_search(request, user_id)
