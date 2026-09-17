
from app.schemas.base import CoreModel


class CategorySLAConfigCreate(CoreModel):
    category_id: str
    building_id: str | None = None
    urgency_level: str
    expected_response_hours: int = 2
    expected_resolution_hours: int = 24


class CategorySLAConfigRead(CoreModel):
    id: str
    category_id: str
    building_id: str | None = None
    urgency_level: str
    expected_response_hours: int
    expected_resolution_hours: int
    is_active: bool
