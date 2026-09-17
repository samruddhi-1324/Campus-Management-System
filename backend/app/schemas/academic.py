from app.models.academic import AcademicConcernType
from app.schemas.base import CoreModel


class AcademicConcernCreate(CoreModel):
    title: str
    description: str
    concern_type: AcademicConcernType
    course_code: str | None = None
    academic_term: str | None = None


class AcademicConcernRead(CoreModel):
    id: str
    issue_id: str
    concern_type: AcademicConcernType
    course_code: str | None = None
    academic_term: str | None = None
    assigned_academic_officer_id: str | None = None
    is_confidential: bool
