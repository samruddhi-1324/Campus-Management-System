import re
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.issue import Issue, IssueStatus
from app.models.master_data import Building, Category
from app.schemas.issue import IssueRead
from app.schemas.search import NLSearchRequest, NLSearchResponse, ParsedSearchFilters


class NLSearchService:
    """Natural Language & Semantic Search engine for campus issues (FR-3.2, FR-3.3, NFR-SEC-01)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def parse_and_execute_search(
        self, request: NLSearchRequest, user_id: str
    ) -> NLSearchResponse:
        query_text = request.query_text.strip()
        lower_q = query_text.lower()

        parsed_filters = ParsedSearchFilters()

        # 1. Parse status intents
        unresolved_keywords = ["unresolved", "open", "pending", "active", "not fixed", "broken", "ongoing"]
        if any(w in lower_q for w in unresolved_keywords):
            parsed_filters.is_unresolved = True
        elif "closed" in lower_q:
            parsed_filters.status = IssueStatus.CLOSED.value
        elif "resolved" in lower_q:
            parsed_filters.status = IssueStatus.RESOLVED.value
        elif "investigating" in lower_q or "in progress" in lower_q:
            parsed_filters.status = IssueStatus.INVESTIGATING.value
        elif "reported" in lower_q:
            parsed_filters.status = IssueStatus.REPORTED.value

        # 2. Parse category intent from DB categories
        cat_result = await self.db.execute(select(Category).where(Category.is_active.is_(True)))
        categories = cat_result.scalars().all()
        matched_category_id = None
        for cat in categories:
            if cat.name.lower() in lower_q or cat.slug.lower() in lower_q:
                parsed_filters.category_slug = cat.slug
                matched_category_id = cat.id
                break

        # Fallback keyword-to-category mapping
        if not matched_category_id:
            category_keywords = {
                "wifi": ["wifi", "wi-fi", "internet", "network", "lan", "connection"],
                "ac": ["ac", "air conditioner", "cooling", "hvac", "chiller"],
                "projector": ["projector", "screen", "display", "av", "audio"],
                "electrical": ["electrical", "power", "switch", "socket", "light", "fuse"],
                "plumbing": ["plumbing", "water", "leak", "pipe", "toilet", "tap", "drain"],
            }
            for slug_key, keywords in category_keywords.items():
                if any(k in lower_q for k in keywords):
                    parsed_filters.category_slug = slug_key
                    # Match against loaded categories by slug if available
                    for cat in categories:
                        if slug_key in cat.slug.lower():
                            matched_category_id = cat.id
                            break
                    break

        # 3. Parse building intent from DB buildings
        bldg_result = await self.db.execute(select(Building).where(Building.is_active.is_(True)))
        buildings = bldg_result.scalars().all()
        matched_building_id = None
        for bldg in buildings:
            if bldg.name.lower() in lower_q or bldg.code.lower() in lower_q:
                parsed_filters.building_name = bldg.name
                matched_building_id = bldg.id
                break

        # 4. Extract meaningful keywords
        stop_words = {
            "show", "me", "all", "the", "a", "an", "in", "on", "at", "for", "from", "with",
            "this", "that", "issues", "complaints", "tickets", "please", "find", "get",
            "unresolved", "open", "closed", "resolved", "month", "today", "week"
        }
        tokens = re.findall(r"\b\w+\b", lower_q)
        extracted_keywords = [t for t in tokens if t not in stop_words and len(t) > 2]
        parsed_filters.keywords = extracted_keywords

        # 5. Build dynamic SQLAlchemy query
        stmt = select(Issue)

        if matched_category_id:
            stmt = stmt.where(Issue.category_id == matched_category_id)

        if matched_building_id:
            stmt = stmt.where(Issue.building_id == matched_building_id)

        if parsed_filters.is_unresolved:
            stmt = stmt.where(
                Issue.status.notin_([IssueStatus.CLOSED, IssueStatus.CONFIRMED, IssueStatus.RESOLVED])
            )
        elif parsed_filters.status:
            stmt = stmt.where(Issue.status == parsed_filters.status)

        # Keyword filtering on title & description
        if extracted_keywords:
            keyword_clauses = []
            for kw in extracted_keywords:
                clause = or_(
                    Issue.title.ilike(f"%{kw}%"),
                    Issue.description.ilike(f"%{kw}%"),
                )
                keyword_clauses.append(clause)
            if keyword_clauses:
                stmt = stmt.where(or_(*keyword_clauses))

        stmt = stmt.order_by(Issue.created_at.desc()).limit(request.limit)
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
