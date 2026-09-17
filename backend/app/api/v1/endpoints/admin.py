from fastapi import APIRouter, Depends, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_active_user, get_db, require_roles
from app.models.audit import AuditLogEntry
from app.models.user import User, UserRole
from app.schemas.audit import AuditLogRead
from app.schemas.master_data import (
    BuildingCreate,
    BuildingRead,
    CategoryCreate,
    CategoryRead,
    DepartmentCreate,
    DepartmentRead,
    RoomCreate,
    RoomRead,
    TeamCreate,
    TeamRead,
)
from app.services.master_data_service import get_master_data_service

router = APIRouter()


# --- Categories (Public read for all authenticated users) ---
@router.get("/categories", response_model=list[CategoryRead])
async def list_categories(
    active_only: bool = Query(True),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """List facilities categories for issue reporting."""
    service = get_master_data_service(db)
    return await service.list_categories(active_only=active_only)


@router.post("/categories", response_model=CategoryRead, status_code=status.HTTP_201_CREATED)
async def create_category(
    cat_in: CategoryCreate,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.OPS_HEAD)),
    db: AsyncSession = Depends(get_db),
):
    """Admin creates a new issue category (FR-1.24)."""
    service = get_master_data_service(db)
    return await service.create_category(cat_in)


# --- Buildings ---
@router.get("/buildings", response_model=list[BuildingRead])
async def list_buildings(
    active_only: bool = Query(True),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """List campus buildings for location selection."""
    service = get_master_data_service(db)
    return await service.list_buildings(active_only=active_only)


@router.post("/buildings", response_model=BuildingRead, status_code=status.HTTP_201_CREATED)
async def create_building(
    building_in: BuildingCreate,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.OPS_HEAD)),
    db: AsyncSession = Depends(get_db),
):
    """Admin creates building master record (FR-1.24)."""
    service = get_master_data_service(db)
    return await service.create_building(building_in)


# --- Rooms ---
@router.get("/rooms", response_model=list[RoomRead])
async def list_rooms(
    building_id: str | None = Query(None),
    active_only: bool = Query(True),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """List rooms filtered optionally by building."""
    service = get_master_data_service(db)
    return await service.list_rooms(building_id=building_id, active_only=active_only)


@router.post("/rooms", response_model=RoomRead, status_code=status.HTTP_201_CREATED)
async def create_room(
    room_in: RoomCreate,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.OPS_HEAD)),
    db: AsyncSession = Depends(get_db),
):
    """Admin creates room within a building (FR-1.24)."""
    service = get_master_data_service(db)
    return await service.create_room(room_in)


# --- Departments ---
@router.get("/departments", response_model=list[DepartmentRead])
async def list_departments(
    active_only: bool = Query(True),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """List institution departments."""
    service = get_master_data_service(db)
    return await service.list_departments(active_only=active_only)


@router.post("/departments", response_model=DepartmentRead, status_code=status.HTTP_201_CREATED)
async def create_department(
    dept_in: DepartmentCreate,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    db: AsyncSession = Depends(get_db),
):
    """Admin creates department record."""
    service = get_master_data_service(db)
    return await service.create_department(dept_in)


# --- Teams ---
@router.get("/teams", response_model=list[TeamRead])
async def list_teams(
    active_only: bool = Query(True),
    current_user: User = Depends(
        require_roles(UserRole.COORDINATOR, UserRole.SUPERVISOR, UserRole.OPS_HEAD, UserRole.ADMIN)
    ),
    db: AsyncSession = Depends(get_db),
):
    """List maintenance teams."""
    service = get_master_data_service(db)
    return await service.list_teams(active_only=active_only)


@router.post("/teams", response_model=TeamRead, status_code=status.HTTP_201_CREATED)
async def create_team(
    team_in: TeamCreate,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.OPS_HEAD)),
    db: AsyncSession = Depends(get_db),
):
    """Admin creates maintenance team (FR-1.26)."""
    service = get_master_data_service(db)
    return await service.create_team(team_in)


# --- Audit Logs ---
@router.get("/audit-logs", response_model=list[AuditLogRead])
async def list_audit_logs(
    target_entity: str | None = Query(None),
    target_id: str | None = Query(None),
    limit: int = Query(50, ge=1, le=200),
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.OPS_HEAD)),
    db: AsyncSession = Depends(get_db),
):
    """Admin/Ops Head views immutable system audit trail (FR-1.27, NFR-AUDIT-01)."""
    stmt = select(AuditLogEntry)
    if target_entity:
        stmt = stmt.where(AuditLogEntry.target_entity == target_entity)
    if target_id:
        stmt = stmt.where(AuditLogEntry.target_id == target_id)
    stmt = stmt.order_by(AuditLogEntry.created_at.desc()).limit(limit)
    result = await db.execute(stmt)
    return list(result.scalars().all())
