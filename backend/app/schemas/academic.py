from typing import Optional
from app.schemas.base import CoreModel
from app.models.academic import AcademicConcernType


class AcademicConcernCreate(CoreModel):
    title: str
    description: str
    concern_type: AcademicConcernType
    course_code: Optional[str] = None
    academic_term: Optional[str] = None


class AcademicConcernRead(CoreModel):
    id: str
    issue_id: str
    concern_type: AcademicConcernType
    course_code: Optional[str] = None
    academic_term: Optional[str] = None
    assigned_academic_officer_id: Optional[str] = None
    is_confidential: bool
