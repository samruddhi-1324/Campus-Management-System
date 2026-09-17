from app.schemas.base import CoreModel


class AIClassificationRequest(CoreModel):
    title: str
    description: str
    location: str | None = None


class AIClassificationResponse(CoreModel):
    suggested_category_id: str | None = None
    suggested_urgency: str
    urgency_rationale: str
    missing_information: list[str]
    confidence: float
    is_ai_generated: bool = True


class AIDedupCheckRequest(CoreModel):
    title: str
    description: str
    building_id: str | None = None
    room_id: str | None = None


class PotentialDuplicateItem(CoreModel):
    issue_id: str
    reference_number: str
    title: str
    similarity_score: float
    rationale: str


class AIDedupCheckResponse(CoreModel):
    duplicates: list[PotentialDuplicateItem]


class AIStatusDraftRequest(CoreModel):
    issue_id: str
    target_status: str
    notes: str | None = None


class AIStatusDraftResponse(CoreModel):
    draft_message: str
