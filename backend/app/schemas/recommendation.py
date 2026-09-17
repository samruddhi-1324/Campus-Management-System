from datetime import datetime

from app.models.recommendation import RecommendationType
from app.schemas.base import CoreModel


class RecommendationRead(CoreModel):
    id: str
    recommendation_type: RecommendationType
    scope_reference: str
    title: str
    body: str
    suggested_action: str
    evidence_snapshot: dict
    confidence: float
    human_decision: str | None = None
    created_at: datetime


class RecommendationDecisionCreate(CoreModel):
    decision: str  # accepted | dismissed | acted
    decision_notes: str | None = None


class RecurrencePatternRead(CoreModel):
    id: str
    asset_or_location_ref: str
    failure_count: int
    observation_window_days: int
    related_issue_ids: list[str]
    status: str
    created_at: datetime
