from app.schemas.base import CoreModel


class DepartmentCreate(CoreModel):
    name: str
    code: str


class DepartmentRead(CoreModel):
    id: str
    name: str
    code: str
    is_active: bool


class BuildingCreate(CoreModel):
    name: str
    code: str


class BuildingRead(CoreModel):
    id: str
    name: str
    code: str
    is_active: bool


class RoomCreate(CoreModel):
    building_id: str
    room_number: str
    floor: int | None = None
    room_type: str | None = None


class RoomRead(CoreModel):
    id: str
    building_id: str
    room_number: str
    floor: int | None = None
    room_type: str | None = None
    is_active: bool


class CategoryCreate(CoreModel):
    name: str
    slug: str
    description: str | None = None
    default_sla_hours: int = 24


class CategoryRead(CoreModel):
    id: str
    name: str
    slug: str
    description: str | None = None
    default_sla_hours: int
    is_active: bool


class TeamCreate(CoreModel):
    name: str
    supervisor_id: str | None = None


class TeamRead(CoreModel):
    id: str
    name: str
    supervisor_id: str | None = None
    is_active: bool
