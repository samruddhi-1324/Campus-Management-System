
from app.schemas.base import CoreModel
from app.schemas.issue import IssueRead


class NLSearchRequest(CoreModel):
    query_text: str  # e.g., "show me all unresolved wifi issues from this month"
    limit: int = 20


class ParsedSearchFilters(CoreModel):
    category_slug: str | None = None
    building_name: str | None = None
    status: str | None = None
    is_unresolved: bool | None = None
    date_range_start: str | None = None
    date_range_end: str | None = None
    keywords: list[str] = []


class NLSearchResponse(CoreModel):
    original_query: str
    parsed_filters: ParsedSearchFilters
    results: list[IssueRead]
    total_matched: int
