from typing import Optional
from datetime import datetime
from app.schemas.base import CoreModel
from app.models.audit import AuditAction


class AuditLogRead(CoreModel):
    id: str
    actor_id: str
    action: AuditAction
    target_entity: str
    target_id: str
    before_state: Optional[dict] = None
    after_state: Optional[dict] = None
    created_at: datetime


class AIInsightRead(CoreModel):
    id: str
    issue_id: str
    insight_type: str
    payload: dict
    confidence: float
    human_decision: Optional[str] = None
    decided_by: Optional[str] = None
    decided_at: Optional[datetime] = None
