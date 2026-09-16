from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.ai import (
    AIClassificationRequest,
    AIClassificationResponse,
    AIDedupCheckRequest,
    AIDedupCheckResponse,
    AIStatusDraftRequest,
    AIStatusDraftResponse,
)


class AIAdvisoryService:
    """AI Decision-support service adhering to human-in-the-loop rules (FR-AI-01..20)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_classification_advice(self, request: AIClassificationRequest) -> AIClassificationResponse:
        pass

    async def check_duplicate_issues(self, request: AIDedupCheckRequest) -> AIDedupCheckResponse:
        pass

    async def draft_status_message(self, request: AIStatusDraftRequest) -> AIStatusDraftResponse:
        pass


def get_ai_advisory_service(db: AsyncSession) -> AIAdvisoryService:
    return AIAdvisoryService(db)
