
from sqlalchemy import Boolean, ForeignKey, Integer, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin


class Department(Base, TimestampMixin):
    """Department master data (FR-1.24)."""
    __tablename__ = "departments"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    code: Mapped[str] = mapped_column(String(20), unique=True, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)


class Building(Base, TimestampMixin):
    """Campus building master data (FR-1.24)."""
    __tablename__ = "buildings"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    code: Mapped[str] = mapped_column(String(20), unique=True, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    rooms: Mapped[list["Room"]] = relationship("Room", back_populates="building", cascade="all, delete-orphan")


class Room(Base, TimestampMixin):
    """Room within a building (FR-1.24)."""
    __tablename__ = "rooms"
    __table_args__ = (
        UniqueConstraint("building_id", "room_number", name="uq_building_room"),
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    building_id: Mapped[str] = mapped_column(String(36), ForeignKey("buildings.id", ondelete="CASCADE"), index=True, nullable=False)
    room_number: Mapped[str] = mapped_column(String(50), nullable=False)
    floor: Mapped[int | None] = mapped_column(Integer, nullable=True)
    room_type: Mapped[str | None] = mapped_column(String(50), nullable=True)  # classroom, lab, library, office
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    building: Mapped["Building"] = relationship("Building", back_populates="rooms")


class Category(Base, TimestampMixin):
    """Facilities issue categories (AC, Projector, Wifi, Lab Equipment, Library) (PRD §11)."""
    __tablename__ = "categories"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    slug: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    default_sla_hours: Mapped[int] = mapped_column(Integer, default=24, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)


class Team(Base, TimestampMixin):
    """Facilities maintenance team assignments (FR-1.26)."""
    __tablename__ = "teams"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    supervisor_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("users.id"), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
