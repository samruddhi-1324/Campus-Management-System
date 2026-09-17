import asyncio
import uuid

from sqlalchemy import select

from app.core.database import AsyncSessionLocal
from app.core.security import get_password_hash
from app.models.master_data import Building, Category, Room
from app.models.user import User, UserRole


async def seed_database():
    """Seed initial master data and admin user into Supabase database."""
    async with AsyncSessionLocal() as session:
        print("🌱 Seeding initial database records...")

        # 1. Check or Create Admin User
        admin_email = "admin@campuscare.edu"
        res = await session.execute(select(User).where(User.email == admin_email))
        existing_admin = res.scalar_one_or_none()

        if not existing_admin:
            admin_user = User(
                id=str(uuid.uuid4()),
                email=admin_email,
                hashed_password=get_password_hash("Admin@123456"),
                full_name="System Administrator",
                role=UserRole.ADMIN,
                is_active=True,
            )
            session.add(admin_user)
            print("  ✅ Created default Admin account: admin@campuscare.edu / Admin@123456")

        # 2. Seed Default Facilities & Academic Categories (PRD §11 & §12)
        categories_data = [
            ("Air Conditioning (AC)", "ac", "Cooling, ventilation, and thermostat issues", 12),
            ("Projectors & AV", "projector", "Classroom audio/visual, smartboards, and projection display failures", 6),
            ("Campus Wifi & Network", "wifi", "Wireless connectivity, dead zones, and network speed drops", 8),
            ("Lab Equipment", "lab_equipment", "Electronics, mechanical, and computer laboratory apparatus", 24),
            ("Library Services", "library", "Study space facilities, RFID gates, and borrowing kiosks", 24),
            ("Academic Concern", "academic_concern", "Confidential grievances, exam schedule disputes & grading inquiries", 48),
        ]

        for name, slug, desc, sla_hours in categories_data:
            res = await session.execute(select(Category).where(Category.slug == slug))
            cat = res.scalar_one_or_none()
            if not cat:
                cat_id = str(uuid.uuid4())
                new_cat = Category(
                    id=cat_id,
                    name=name,
                    slug=slug,
                    description=desc,
                    default_sla_hours=sla_hours,
                    is_active=True,
                )
                session.add(new_cat)
                print(f"  ✅ Seeded Category: {name} (Default SLA: {sla_hours}h)")

        # 3. Seed Default Buildings & Rooms
        buildings_data = [
            ("Main Academic Block", "MAB", [("101", 1, "Classroom"), ("102", 1, "Classroom"), ("201", 2, "Seminar Hall")]),
            ("Engineering Wing", "ENG", [("Lab 204", 2, "Computer Lab"), ("Lab 305", 3, "Electronics Lab")]),
            ("Central Library", "LIB", [("Reading Hall A", 1, "Library"), ("Digital Resource Center", 2, "Lab")]),
        ]

        for b_name, b_code, rooms_list in buildings_data:
            res = await session.execute(select(Building).where(Building.code == b_code))
            bldg = res.scalar_one_or_none()
            if not bldg:
                bldg_id = str(uuid.uuid4())
                new_bldg = Building(
                    id=bldg_id,
                    name=b_name,
                    code=b_code,
                    is_active=True,
                )
                session.add(new_bldg)

                for r_num, floor, r_type in rooms_list:
                    new_room = Room(
                        id=str(uuid.uuid4()),
                        building_id=bldg_id,
                        room_number=r_num,
                        floor=floor,
                        room_type=r_type,
                        is_active=True,
                    )
                    session.add(new_room)
                print(f"  ✅ Seeded Building: {b_name} with {len(rooms_list)} rooms")

        await session.commit()
        print("🎉 Database seeding completed successfully!")


if __name__ == "__main__":
    asyncio.run(seed_database())
