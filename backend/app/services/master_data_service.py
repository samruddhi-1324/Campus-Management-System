from typing import List
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.master_data import Building, Room, Category, Team
from app.schemas.master_data import BuildingCreate, RoomCreate, CategoryCreate, TeamCreate


class MasterDataService:
    """Administrator master data management service (FR-1.24..26)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_building(self, building_in: BuildingCreate) -> Building:
        pass

    async def create_room(self, room_in: RoomCreate) -> Room:
        pass

    async def create_category(self, category_in: CategoryCreate) -> Category:
        pass

    async def create_team(self, team_in: TeamCreate) -> Team:
        pass


def get_master_data_service(db: AsyncSession) -> MasterDataService:
    return MasterDataService(db)
