import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.sla import CategorySLAConfig
from app.schemas.sla import CategorySLAConfigCreate


class SLAService:
    """Multi-tier SLA configuration and deadline calculation service (FR-2.9)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_sla_config(self, config_in: CategorySLAConfigCreate) -> CategorySLAConfig:
        """Admin configures category and building specific SLA target windows (FR-2.9)."""
        config_id = str(uuid.uuid4())
        config = CategorySLAConfig(
            id=config_id,
            category_id=config_in.category_id,
            building_id=config_in.building_id,
            urgency_level=config_in.urgency_level,
            expected_response_hours=config_in.expected_response_hours,
            expected_resolution_hours=config_in.expected_resolution_hours,
            is_active=True,
        )
        self.db.add(config)
        await self.db.commit()
        await self.db.refresh(config)
        return config

    async def list_sla_configs(self, category_id: str | None = None) -> list[CategorySLAConfig]:
        """List active SLA target configurations."""
        stmt = select(CategorySLAConfig).where(CategorySLAConfig.is_active.is_(True))
        if category_id:
            stmt = stmt.where(CategorySLAConfig.category_id == category_id)

        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def calculate_expected_resolution(
        self,
        category_id: str | None,
        urgency: str = "medium",
        building_id: str | None = None,
    ) -> datetime:
        """Calculates expected resolution timestamp based on SLA rules and urgency multiplier."""
        resolution_hours = 24  # Default fallback

        if category_id:
            # 1. Check building-specific SLA
            if building_id:
                b_stmt = select(CategorySLAConfig).where(
                    CategorySLAConfig.category_id == category_id,
                    CategorySLAConfig.building_id == building_id,
                    CategorySLAConfig.is_active.is_(True),
                )
                b_config = (await self.db.execute(b_stmt)).scalar_one_or_none()
                if b_config:
                    resolution_hours = b_config.expected_resolution_hours

            # 2. Check general category SLA
            if resolution_hours == 24:
                c_stmt = select(CategorySLAConfig).where(
                    CategorySLAConfig.category_id == category_id,
                    CategorySLAConfig.building_id.is_(None),
                    CategorySLAConfig.is_active.is_(True),
                )
                c_config = (await self.db.execute(c_stmt)).scalar_one_or_none()
                if c_config:
                    resolution_hours = c_config.expected_resolution_hours

        # Urgency adjustment factors
        urgency_multipliers = {
            "critical": 0.25,
            "high": 0.5,
            "medium": 1.0,
            "low": 2.0,
        }
        multiplier = urgency_multipliers.get(urgency.lower(), 1.0)
        adjusted_hours = max(1, int(resolution_hours * multiplier))

        return datetime.now(UTC) + timedelta(hours=adjusted_hours)


def get_sla_service(db: AsyncSession) -> SLAService:
    return SLAService(db)
