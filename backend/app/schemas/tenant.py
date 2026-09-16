from typing import Optional
from app.schemas.base import CoreModel


class InstitutionCreate(CoreModel):
    name: str
    slug: str
    domain: str
    logo_url: Optional[str] = None
    settings: Optional[dict] = None


class InstitutionRead(CoreModel):
    id: str
    name: str
    slug: str
    domain: str
    logo_url: Optional[str] = None
    settings: dict
    is_active: bool
