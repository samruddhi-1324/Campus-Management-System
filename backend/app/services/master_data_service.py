import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.master_data import Building, Category, Department, Room, Team
from app.schemas.master_data import (
    BuildingCreate,
    CategoryCreate,
    DepartmentCreate,
    RoomCreate,
    TeamCreate,
)


class MasterDataService:
    """Facilities and institution master data service (FR-1.24..26)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    # --- Departments ---
    async def list_departments(self, active_only: bool = True) -> list[Department]:
        stmt = select(Department)
        if active_only:
            stmt = stmt.where(Department.is_active)
        stmt = stmt.order_by(Department.name)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def create_department(self, dept_in: DepartmentCreate) -> Department:
        dept = Department(
            id=str(uuid.uuid4()),
            name=dept_in.name.strip(),
            code=dept_in.code.upper().strip(),
            is_active=True,
        )
        self.db.add(dept)
        await self.db.commit()
        await self.db.refresh(dept)
        return dept

    # --- Buildings ---
    async def list_buildings(self, active_only: bool = True) -> list[Building]:
        stmt = select(Building)
        if active_only:
            stmt = stmt.where(Building.is_active)
        stmt = stmt.order_by(Building.name)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def create_building(self, building_in: BuildingCreate) -> Building:
        building = Building(
            id=str(uuid.uuid4()),
            name=building_in.name.strip(),
            code=building_in.code.upper().strip(),
            is_active=True,
        )
        self.db.add(building)
        await self.db.commit()
        await self.db.refresh(building)
        return building

    # --- Rooms ---
    async def list_rooms(self, building_id: str | None = None, active_only: bool = True) -> list[Room]:
        stmt = select(Room)
        if active_only:
            stmt = stmt.where(Room.is_active)
        if building_id:
            stmt = stmt.where(Room.building_id == building_id)
        stmt = stmt.order_by(Room.room_number)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def create_room(self, room_in: RoomCreate) -> Room:
        room = Room(
            id=str(uuid.uuid4()),
            building_id=room_in.building_id,
            room_number=room_in.room_number.strip(),
            floor=room_in.floor,
            room_type=room_in.room_type,
            is_active=True,
        )
        self.db.add(room)
        await self.db.commit()
        await self.db.refresh(room)
        return room

    # --- Categories ---
    async def list_categories(self, active_only: bool = True) -> list[Category]:
        stmt = select(Category)
        if active_only:
            stmt = stmt.where(Category.is_active)
        stmt = stmt.order_by(Category.name)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def create_category(self, cat_in: CategoryCreate) -> Category:
        category = Category(
            id=str(uuid.uuid4()),
            name=cat_in.name.strip(),
            slug=cat_in.slug.lower().strip(),
            description=cat_in.description,
            default_sla_hours=cat_in.default_sla_hours,
            is_active=True,
        )
        self.db.add(category)
        await self.db.commit()
        await self.db.refresh(category)
        return category

    # --- Teams ---
    async def list_teams(self, active_only: bool = True) -> list[Team]:
        stmt = select(Team)
        if active_only:
            stmt = stmt.where(Team.is_active)
        stmt = stmt.order_by(Team.name)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def create_team(self, team_in: TeamCreate) -> Team:
        team = Team(
            id=str(uuid.uuid4()),
            name=team_in.name.strip(),
            supervisor_id=team_in.supervisor_id,
            is_active=True,
        )
        self.db.add(team)
        await self.db.commit()
        await self.db.refresh(team)
        return team


def get_master_data_service(db: AsyncSession) -> MasterDataService:
    return MasterDataService(db)
