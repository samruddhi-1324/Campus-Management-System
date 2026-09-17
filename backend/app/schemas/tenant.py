
from app.schemas.base import CoreModel


class InstitutionCreate(CoreModel):
    name: str
    slug: str
    domain: str
    logo_url: str | None = None
    settings: dict | None = None


class InstitutionRead(CoreModel):
    id: str
    name: str
    slug: str
    domain: str
    logo_url: str | None = None
    settings: dict
    is_active: bool
