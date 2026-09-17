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
        print("[INFO] Seeding initial database records...")

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
            print("  [+] Created default Admin account: admin@campuscare.edu / Admin@123456")

        # 2. Seed Default Facilities & Academic Categories (PRD §11 & §12)
        categories_data = [
            ("Air Conditioning (AC)", "ac", "Cooling, ventilation, and thermostat issues", 12),
            ("Projectors & AV", "projector", "Classroom audio/visual, smartboards, and projection display failures", 6),
            ("Campus Wifi & Network", "wifi", "Wireless connectivity, dead zones, and network speed drops", 8),
            ("Lab Equipment", "lab_equipment", "Electronics, mechanical, and computer laboratory apparatus", 24),
            ("Library Services", "library", "Study space facilities, RFID gates, and borrowing kiosks", 24),
            ("Academic Concern", "academic", "Confidential academic disputes, grading, and advisor mediation", 48),
            ("Electrical & Power", "electrical", "Power outages, sockets, switches, and backup generators", 6),
            ("Plumbing & Washrooms", "plumbing", "Water leakage, blockages, taps, and restroom maintenance", 4),
        ]

        for cat_name, cat_slug, cat_desc, sla_hrs in categories_data:
            cat_res = await session.execute(select(Category).where(Category.slug == cat_slug))
            if not cat_res.scalar_one_or_none():
                session.add(
                    Category(
                        id=str(uuid.uuid4()),
                        name=cat_name,
                        slug=cat_slug,
                        description=cat_desc,
                        default_sla_hours=sla_hrs,
                        is_active=True,
                    )
                )
                print(f"  [+] Seeded Category: {cat_name} (SLA: {sla_hrs}h)")

        # 3. Seed Campus Buildings & Example Rooms (PRD §11)
        buildings_data = [
            (
                "Main Academic Block",
                "MAB",
                [("101", 1, "lecture_hall"), ("102", 1, "classroom"), ("201", 2, "lab"), ("301", 3, "faculty_room")],
            ),
            (
                "Science & Research Center",
                "SRC",
                [("L101", 1, "lab"), ("L102", 1, "lab"), ("L201", 2, "clean_room")],
            ),
            (
                "Central Library Building",
                "CLB",
                [("G01", 0, "reading_hall"), ("101", 1, "digital_library"), ("201", 2, "archive")],
            ),
        ]

        for b_name, b_code, rooms_list in buildings_data:
            b_res = await session.execute(select(Building).where(Building.code == b_code))
            if not b_res.scalar_one_or_none():
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
                print(f"  [+] Seeded Building: {b_name} with {len(rooms_list)} rooms")

        await session.commit()
        print("[SUCCESS] Database seeding completed successfully!")


if __name__ == "__main__":
    asyncio.run(seed_database())
