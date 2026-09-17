from datetime import datetime

from app.models.audit import AuditAction
from app.schemas.base import CoreModel


class AuditLogRead(CoreModel):
    id: str
    actor_id: str
    action: AuditAction
    target_entity: str
    target_id: str
    before_state: dict | None = None
    after_state: dict | None = None
    created_at: datetime


class AIInsightRead(CoreModel):
    id: str
    issue_id: str
    insight_type: str
    payload: dict
    confidence: float
    human_decision: str | None = None
    decided_by: str | None = None
    decided_at: datetime | None = None
