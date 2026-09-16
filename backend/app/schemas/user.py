from typing import Optional
from pydantic import EmailStr
from app.schemas.base import CoreModel
from app.models.user import UserRole


class UserCreate(CoreModel):
    email: EmailStr
    password: str
    full_name: str
    role: UserRole = UserRole.REPORTER
    department_id: Optional[str] = None


class UserUpdate(CoreModel):
    full_name: Optional[str] = None
    role: Optional[UserRole] = None
    department_id: Optional[str] = None
    is_active: Optional[bool] = None


class UserRead(CoreModel):
    id: str
    email: EmailStr
    full_name: str
    role: UserRole
    department_id: Optional[str] = None
    is_active: bool
