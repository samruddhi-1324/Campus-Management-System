from typing import List, Optional
from app.schemas.base import CoreModel


class AIClassificationRequest(CoreModel):
    title: str
    description: str
    location: Optional[str] = None


class AIClassificationResponse(CoreModel):
    suggested_category_id: Optional[str] = None
    suggested_urgency: str
    urgency_rationale: str
    missing_information: List[str]
    confidence: float
    is_ai_generated: bool = True


class AIDedupCheckRequest(CoreModel):
    title: str
    description: str
    building_id: Optional[str] = None
    room_id: Optional[str] = None


class PotentialDuplicateItem(CoreModel):
    issue_id: str
    reference_number: str
    title: str
    similarity_score: float
    rationale: str


class AIDedupCheckResponse(CoreModel):
    duplicates: List[PotentialDuplicateItem]


class AIStatusDraftRequest(CoreModel):
    issue_id: str
    target_status: str
    notes: Optional[str] = None


class AIStatusDraftResponse(CoreModel):
    draft_message: str
