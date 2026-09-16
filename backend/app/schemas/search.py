from typing import List, Optional
from app.schemas.base import CoreModel
from app.schemas.issue import IssueRead


class NLSearchRequest(CoreModel):
    query_text: str  # e.g., "show me all unresolved wifi issues from this month"
    limit: int = 20


class ParsedSearchFilters(CoreModel):
    category_slug: Optional[str] = None
    building_name: Optional[str] = None
    status: Optional[str] = None
    is_unresolved: Optional[bool] = None
    date_range_start: Optional[str] = None
    date_range_end: Optional[str] = None
    keywords: List[str] = []


class NLSearchResponse(CoreModel):
    original_query: str
    parsed_filters: ParsedSearchFilters
    results: List[IssueRead]
    total_matched: int
