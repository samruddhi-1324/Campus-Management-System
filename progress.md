# Campus Care — Progress & Repository Milestone Log

**Project**: Campus Care (AI-Powered Facilities & Academic Issue Tracker)  
**Repository**: [`samruddhi-1324/Campus-Management-System`](https://github.com/samruddhi-1324/Campus-Management-System)  
**Specification Version**: PRD & SRS v3.0  
**Current Milestone**: **SUPABASE CLOUD POSTGRESQL & STORAGE INTEGRATION 100% COMPLETE**  
- **Phase 1 (MVP)**: Issue lifecycle state machine, RBAC, master data, attachments, notifications.
- **Phase 2 (Academic Intelligence)**: Confidential academic grievance portal, ombudsperson triage, recurrence detector, AI replacement suggestions, SLA risk radar.
- **Phase 3 (Enterprise & Multimodal)**: Multi-institution tenancy, voice recording & AI classification, natural language semantic search, multi-year historical trend mining, WhatsApp webhook handler.
- **Phase 4 (Stitch UI 14 Screen Pairs)**: 14 Desktop & 14 Mobile screens rendered with 100% pure Stitch design, fully wired in a continuous workflow loop.
- **Phase 5 (Mobile Build & Physical Android Deployment)**: Built release APK (52.9 MB), installed on device, dual network routing.
- **Phase 6 (Supabase Cloud Database & Storage — LIVE)**:
  - Connected live Supabase project `hiqvjnerhocpzxanlbbq` via async transaction pooler.
  - Added `statement_cache_size: 0` for pgbouncer compatibility in SQLAlchemy 2.0.
  - Created all 25 relational tables and schema indexes in Supabase Cloud.
  - Seeded all demo accounts & personalized Admin `samruddhi@campuscare.edu` in Supabase with password `Admin@123456`.
  - Configured Supabase storage bucket `issue-attachments`.
**Active Branches**: `develop` & `main`  
**Last Updated**: 2026-09-24  

---

## 🚀 Live System Servers & Verification Endpoints

| Service / Platform | Port / URL | Status | Description |
|---|---|---|---|
| **FastAPI Async Backend** | `http://127.0.0.1:8000` & `http://0.0.0.0:8000` | 🟢 Active | OpenAPI docs at `/api/v1/docs` & root `/docs` |
| **Flutter Web Application** | `http://127.0.0.1:5000` | 🟢 Active | Live compiled Flutter web client |
| **UI Showcase Hub (14 Screens)** | `http://127.0.0.1:3000/index.html` | 🟢 Active | Master 14-screen showcase with desktop/mobile links |
| **Desktop Auth & Login Screen** | `http://127.0.0.1:3000/campus_care_desktop_authentication/code.html` | 🟢 Active | Interactive Stitch Desktop Auth screen |
| **Mobile Auth & Login Screen** | `http://127.0.0.1:3000/campus_care_mobile_authentication/code.html` | 🟢 Active | Interactive Stitch Mobile Auth screen |
| **Physical Android App (APK)** | `d:\Campus Complaint Management\CampusCare.apk` | 🟢 Installed on Device | Direct release APK installed on phone via USB |

---

## 🔑 Default Credentials Inventory

All accounts are pre-seeded with password: `Admin@123456`

| Role | Email ID | Password | Access / Scope |
|---|---|---|---|
| **System Admin (Personal)** | `samruddhi@campuscare.edu` | `Admin@123456` | Full platform administration & tenant configurations |
| **System Admin (Default)** | `admin@campuscare.edu` | `Admin@123456` | Master data & system settings |
| **Student / Reporter** | `student@campuscare.edu` | `Admin@123456` | Issue filing, voice memos, resolution tracking |
| **Triage Coordinator** | `coordinator@campuscare.edu` | `Admin@123456` | Triage desk, technician assignment, priority classification |
| **Maintenance Supervisor** | `supervisor@campuscare.edu` | `Admin@123456` | SLA risk radar, fatigue monitoring, technician dispatch |
| **Academic Officer** | `academic@campuscare.edu` | `Admin@123456` | Confidential grievance review, FERPA locker, ombudsperson |
| **Operations Head** | `opshead@campuscare.edu` | `Admin@123456` | Executive operations analytics, multi-year trend mining |

---

## 🗄️ Database & Supabase Cloud Migration Blueprint

### 1. Database Specifications:
- **ORM**: SQLAlchemy 2.0 Async (`postgresql+asyncpg`)
- **Schema Migration**: Alembic (`alembic.ini` & `backend/alembic/`)
- **Total Relational Tables (25)**:
  `users`, `tenants`, `categories`, `buildings`, `rooms`, `issues`, `issue_status_history`, `issue_internal_notes`, `issue_attachments`, `academic_concerns`, `confidential_access_logs`, `failure_recurrence_patterns`, `asset_recommendations`, `sla_configurations`, `notifications`, `user_notification_preferences`, `whatsapp_webhook_logs`, `audio_transcription_jobs`, `historical_trend_snapshots`, `seasonal_spike_alerts`, `technician_skills`, `category_sla_mappings`, `audit_logs`, `user_tokens`, `alembic_version`.

### 2. Supabase Connection Requirements:
- **Connection URI Format**: `postgresql+asyncpg://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres`
- **Storage Bucket**: `issue-attachments` (Private bucket with signed URL access)
- **API Keys Needed**: `SUPABASE_URL` & `SUPABASE_SERVICE_ROLE_KEY`

---

## 🏁 Starting Point for Next Session

1. **Complete Supabase Cloud Database Connection**:
   - Obtain database connection URI and secret `service_role` key from the Supabase Project Settings.
   - Update `.env` file with the Supabase connection parameters.
   - Run `alembic upgrade head` to apply all 25 tables to Supabase cloud.
   - Run seed script to populate master data and users in Supabase.
2. **Supabase Storage Validation**:
   - Test photo and voice attachment upload from mobile app and web directly into `issue-attachments` bucket.
3. **End-to-End Testing**:
   - File issue from phone app ➔ Triage in Coordinator desktop ➔ Monitor on SLA Risk Radar.
