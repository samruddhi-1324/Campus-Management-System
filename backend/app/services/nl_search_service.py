import re
from collections.abc import Sequence

from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql import Select

from app.models.issue import Issue, IssueStatus
from app.models.master_data import Building, Category
from app.schemas.issue import IssueRead
from app.schemas.search import NLSearchRequest, NLSearchResponse, ParsedSearchFilters

STOP_WORDS = {
    "show",
    "me",
    "all",
    "the",
    "a",
    "an",
    "in",
    "on",
    "at",
    "for",
    "from",
    "with",
    "this",
    "that",
    "issues",
    "complaints",
    "tickets",
    "please",
    "find",
    "get",
    "unresolved",
    "open",
    "closed",
    "resolved",
    "month",
    "today",
    "week",
}

CATEGORY_KEYWORD_MAP = {
    "wifi": ["wifi", "wi-fi", "internet", "network", "lan", "connection"],
    "ac": ["ac", "air conditioner", "cooling", "hvac", "chiller"],
    "projector": ["projector", "screen", "display", "av", "audio"],
    "electrical": ["electrical", "power", "switch", "socket", "light", "fuse"],
    "plumbing": ["plumbing", "water", "leak", "pipe", "toilet", "tap", "drain"],
}


class NLSearchService:
    """Natural Language & Semantic Search engine for campus issues (FR-3.2, FR-3.3, NFR-SEC-01)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    def _parse_status_intent(self, lower_q: str, filters: ParsedSearchFilters) -> None:
        """Parse status or unresolved flags from query string."""
        unresolved_keywords = ["unresolved", "open", "pending", "active", "not fixed", "broken", "ongoing"]
        if any(w in lower_q for w in unresolved_keywords):
            filters.is_unresolved = True
        elif "closed" in lower_q:
            filters.status = IssueStatus.CLOSED.value
        elif "resolved" in lower_q:
            filters.status = IssueStatus.RESOLVED.value
        elif "investigating" in lower_q or "in progress" in lower_q:
            filters.status = IssueStatus.INVESTIGATING.value
        elif "reported" in lower_q:
            filters.status = IssueStatus.REPORTED.value

    def _parse_category_intent(
        self, lower_q: str, categories: Sequence[Category], filters: ParsedSearchFilters
    ) -> str | None:
        """Match category from query text against active categories or fallback keywords."""
        for cat in categories:
            if cat.name.lower() in lower_q or cat.slug.lower() in lower_q:
                filters.category_slug = cat.slug
                return cat.id

        for slug_key, keywords in CATEGORY_KEYWORD_MAP.items():
            if any(k in lower_q for k in keywords):
                filters.category_slug = slug_key
                for cat in categories:
                    if slug_key in cat.slug.lower():
                        return cat.id
                break
        return None

    def _parse_building_intent(
        self, lower_q: str, buildings: Sequence[Building], filters: ParsedSearchFilters
    ) -> str | None:
        """Match building name or code from query text."""
        for bldg in buildings:
            if bldg.name.lower() in lower_q or bldg.code.lower() in lower_q:
                filters.building_name = bldg.name
                return bldg.id
        return None

    def _extract_keywords(self, lower_q: str) -> list[str]:
        """Extract search keywords excluding stop words."""
        tokens = re.findall(r"\b\w+\b", lower_q)
        return [t for t in tokens if t not in STOP_WORDS and len(t) > 2]

    def _build_search_query(
        self,
        filters: ParsedSearchFilters,
        matched_cat_id: str | None,
        matched_bldg_id: str | None,
        limit: int,
    ) -> Select:
        """Construct filtered SQLAlchemy select query."""
        stmt = select(Issue)

        if matched_cat_id:
            stmt = stmt.where(Issue.category_id == matched_cat_id)

        if matched_bldg_id:
            stmt = stmt.where(Issue.building_id == matched_bldg_id)

        if filters.is_unresolved:
            stmt = stmt.where(Issue.status.notin_([IssueStatus.CLOSED, IssueStatus.CONFIRMED, IssueStatus.RESOLVED]))
        elif filters.status:
            stmt = stmt.where(Issue.status == filters.status)

        if filters.keywords:
            clauses = [or_(Issue.title.ilike(f"%{kw}%"), Issue.description.ilike(f"%{kw}%")) for kw in filters.keywords]
            stmt = stmt.where(or_(*clauses))

        return stmt.order_by(Issue.created_at.desc()).limit(limit)

    async def parse_and_execute_search(self, request: NLSearchRequest, _user_id: str) -> NLSearchResponse:
        query_text = request.query_text.strip()
        lower_q = query_text.lower()
        parsed_filters = ParsedSearchFilters()

        self._parse_status_intent(lower_q, parsed_filters)

        cat_res = await self.db.execute(select(Category).where(Category.is_active.is_(True)))
        matched_cat_id = self._parse_category_intent(lower_q, cat_res.scalars().all(), parsed_filters)

        bldg_res = await self.db.execute(select(Building).where(Building.is_active.is_(True)))
        matched_bldg_id = self._parse_building_intent(lower_q, bldg_res.scalars().all(), parsed_filters)

        parsed_filters.keywords = self._extract_keywords(lower_q)

        stmt = self._build_search_query(parsed_filters, matched_cat_id, matched_bldg_id, request.limit)
        result = await self.db.execute(stmt)
        issues = result.scalars().all()

        issue_reads = [IssueRead.model_validate(iss) for iss in issues]

        return NLSearchResponse(
            original_query=query_text,
            parsed_filters=parsed_filters,
            results=issue_reads,
            total_matched=len(issue_reads),
        )


def get_nl_search_service(db: AsyncSession) -> NLSearchService:
    return NLSearchService(db)
