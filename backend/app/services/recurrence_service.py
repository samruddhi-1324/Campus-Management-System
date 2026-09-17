
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.recommendation import RecurrencePattern


class RecurrenceService:
    """Equipment and Location failure recurrence detection over rolling windows (FR-2.6, FR-2.7)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def detect_recurring_patterns(self, window_days: int = 30) -> list[RecurrencePattern]:
        pass

    async def convert_to_replacement_recommendation(self, pattern_id: str, actor_id: str) -> RecurrencePattern:
        pass


def get_recurrence_service(db: AsyncSession) -> RecurrenceService:
    return RecurrenceService(db)
