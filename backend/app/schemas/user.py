
from pydantic import EmailStr

from app.models.user import UserRole
from app.schemas.base import CoreModel


class UserCreate(CoreModel):
    email: EmailStr
    password: str
    full_name: str
    role: UserRole = UserRole.REPORTER
    department_id: str | None = None


class UserUpdate(CoreModel):
    full_name: str | None = None
    role: UserRole | None = None
    department_id: str | None = None
    is_active: bool | None = None


class UserRead(CoreModel):
    id: str
    email: EmailStr
    full_name: str
    role: UserRole
    department_id: str | None = None
    is_active: bool
