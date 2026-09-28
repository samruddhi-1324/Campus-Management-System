# Campus Care — Progress & Repository Milestone Log

**Project**: Campus Care (AI-Powered Facilities & Academic Issue Tracker)  
**Repository**: [`samruddhi-1324/Campus-Management-System`](https://github.com/samruddhi-1324/Campus-Management-System)  
**Specification Version**: PRD & SRS v3.0  
**Current Milestone**: **PRODUCTION DEPLOYMENT READY — CORS BUG FIXED, RENDER + VERCEL CONFIGS FINALIZED**  
**Last Updated**: 2026-09-28 (23:49 IST)  

---

## ✅ Completed Phases (Chronological)

- **Phase 1 (MVP)**: Issue lifecycle state machine, RBAC, master data, attachments, notifications.
- **Phase 2 (Academic Intelligence)**: Confidential academic grievance portal, ombudsperson triage, recurrence detector, AI replacement suggestions, SLA risk radar.
- **Phase 3 (Enterprise & Multimodal)**: Multi-institution tenancy, voice recording & AI classification, natural language semantic search, multi-year historical trend mining, WhatsApp webhook handler.
- **Phase 4 (Stitch UI 14 Screen Pairs)**: 14 Desktop & 14 Mobile screens rendered with 100% pure Stitch design, fully wired in a continuous workflow loop using `WorkflowSequenceBar` allowing sequential step-by-step navigation (Step 01 to 14) across the entire application.
- **Phase 5 (Mobile Build & Physical Android Deployment — VERIFIED)**: Built release APK (53.6 MB), installed on device `D6YDOZOJOZZ54DY5`, verified 14-screen navigation flow on physical phone with `SafeArea` padded navigation bar.
- **Phase 6 (Supabase Cloud Database & Storage — LIVE)**: Connected live Supabase project `hiqvjnerhocpzxanlbbq` via async transaction pooler (`aws-0-ap-southeast-1.pooler.supabase.com:6543`), 25 tables initialized, pre-seeded accounts (`samruddhi@campuscare.edu` / `Admin@123456`), Supabase Storage private bucket configured.
- **Phase 7 (Production Cloud Blueprints & Git Sync)**:
  - Created `render.yaml` blueprint for 1-click FastAPI Render backend deployment.
  - Created `frontend/vercel.json` for Flutter Web single-page app (SPA) routing on Vercel.
  - Merged all features from `develop` into `main` branch.
- **Phase 8 (CORS Parsing Bug Fix — RESOLVED)**:
  - **Bug**: `pydantic-settings` tried to `json.loads()` the `BACKEND_CORS_ORIGINS` list field before any field_validator ran. A plain `*` or `["*"]` with quotes caused `SettingsError`.
  - **Fix**: Changed `BACKEND_CORS_ORIGINS: list[str]` → `BACKEND_CORS_ORIGINS: str = "*"` (raw string, bypasses pydantic-settings interception). Added `cors_origins` **property** in `Settings` class that safely parses all formats.
  - **Files Changed**: `backend/app/core/config.py`, `backend/app/main.py`
  - **Verified**: `python -c "from app.core.config import settings; print(settings.cors_origins)"` → `['*']` ✅
  - **Committed**: `9595411` on both `develop` and `main`.

---

## 🔑 Default Credentials Inventory

All accounts are pre-seeded in the live Supabase Database with password: `Admin@123456`

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

## 🌐 Live System Servers & Verification Endpoints

| Service / Platform | Port / URL | Status | Description |
|---|---|---|---|
| **FastAPI Async Backend** | `http://127.0.0.1:8000` | 🟢 Active (local) | OpenAPI docs at `/docs` |
| **UI Showcase Hub (14 Screens)** | `http://127.0.0.1:3000/index.html` | 🟢 Active (local) | Master 14-screen showcase |
| **Flutter Web Application** | `http://127.0.0.1:5000` | 🟢 Active (local) | Compiled Flutter web client |
| **Physical Android Device** | Device `D6YDOZOJOZZ54DY5` | 🟢 Installed | Release APK installed and verified screen-by-screen |
| **Render Backend (to deploy)** | `https://campus-care-backend.onrender.com` | ⏳ Pending deploy | Backend deployment config ready in `render.yaml` |
| **Vercel Frontend (to deploy)** | `https://campus-care-xxxx.vercel.app` | ⏳ Pending deploy | Flutter web config ready in `frontend/vercel.json` |

---

## 🗝️ Supabase & Database Secrets (For Render Environment Variables)

> Set these manually on Render Dashboard → Environment tab (mark as secret):

| Key | Value |
|---|---|
| `DATABASE_URL` | `postgresql+asyncpg://postgres.hiqvjnerhocpzxanlbbq:a9DBHX2NNoqy1a8G@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres` |
| `JWT_SECRET_KEY` | `iAQVLY+Bhv/ddsBdk88napMDRzlUHbpeCXZeCMjohRdF4IkgcI2wHBRPANlOIAbRf+t8UM5PIL9k8qvUQu8t5w==` |
| `SUPABASE_URL` | `https://hiqvjnerhocpzxanlbbq.supabase.co` |
| `SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpcXZqbmVyaG9jcHp4YW5sYmJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAxNTk0NzIsImV4cCI6MjEwNTczNTQ3Mn0.Z5UKRx9467BBJd6LZ140YT3XDEAJ8NfKbbxoTO-__gk` |
| `SUPABASE_SERVICE_ROLE_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpcXZqbmVyaG9jcHp4YW5sYmJxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MDE1OTQ3MiwiZXhwIjoyMTA1NzM1NDcyfQ.br_mT5o-jGPg0oSyNl2NFhhtBwyZr6CJBI_MsFNZKdE` |
| `ENVIRONMENT` | `production` |
| `API_V1_STR` | `/api/v1` |
| `BACKEND_CORS_ORIGINS` | `*` ← plain wildcard, no brackets needed |
| `JWT_ALGORITHM` | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `60` |
| `REFRESH_TOKEN_EXPIRE_DAYS` | `30` |
| `SUPABASE_STORAGE_BUCKET_ATTACHMENTS` | `issue-attachments` |
| `AI_PROVIDER` | `mock` |
| `EMAIL_PROVIDER` | `smtp` |
| `SMTP_HOST` | `smtp.gmail.com` |
| `SMTP_PORT` | `587` |

---

## 🔧 Vercel Environment Variables (For Flutter Web Build)

| Key | Value | Environment |
|---|---|---|
| `API_BASE_URL` | `https://campus-care-backend.onrender.com/api/v1` | Production, Preview, Development |

> The Flutter app reads `API_BASE_URL` via `String.fromEnvironment('API_BASE_URL')` in `AppConfig`. Vercel passes it as a `--dart-define` build flag via the `buildCommand` in `frontend/vercel.json`.

---

## 🖥️ Screen-by-Screen Web Directory

| # | Role / Desk | Direct Link | Key Capabilities |
| :--- | :--- | :--- | :--- |
| 1 | **Main Web Showcase Hub** | [Open Hub](http://127.0.0.1:3000/index.html) | Master directory of all 14 screens |
| 2 | **Desktop Login Screen** | [Open Login](http://127.0.0.1:3000/campus_care_desktop_authentication/code.html) | Role preset selector & JWT authentication |
| 3 | **Student Issue Filing Form** | [Open Form](http://127.0.0.1:3000/campus_care_issue_filing_form_with_voice_input_desktop/code.html) | Voice input, photo upload, location hierarchy |
| 4 | **Student Complaints Dashboard** | [Open Dashboard](http://127.0.0.1:3000/campus_care_complaints_dashboard_desktop/code.html) | Filter by status, view active tickets |
| 5 | **Lifecycle & Resolution Tracker**| [Open Tracker](http://127.0.0.1:3000/campus_care_issue_detail_lifecycle_resolution_tracker_desktop/code.html) | 5-step visual progress, resolution proof photo |
| 6 | **Coordinator Triage Desk** | [Open Workspace](http://127.0.0.1:3000/campus_care_coordinator_triage_workspace_desktop/code.html) | Incoming unassigned queue, AI urgency scorer |
| 7 | **Maintenance Supervisor Hub** | [Open Hub](http://127.0.0.1:3000/campus_care_maintenance_supervisor_sla_risk_radar_desktop/code.html) | SLA countdown rings, technician assignment |
| 8 | **Academic Review Officer** | [Open Desk](http://127.0.0.1:3000/campus_care_academic_officer_review_disposition_workspace_desktop/code.html) | Confidential grievance reviews, redacted identity |
| 9 | **Operations Head Analytics** | [Open Analytics](http://127.0.0.1:3000/campus_care_executive_operations_analytics_dashboard_desktop/code.html) | Campus heatmaps, equipment recurrence radar |
| 10 | **System Admin Portal** | [Open Portal](http://127.0.0.1:3000/campus_care_system_administrator_configuration_portal_desktop/code.html) | Master topology, SLA escalation matrices |
| 11 | **AI Natural Language Search** | [Open Search](http://127.0.0.1:3000/campus_care_ai_natural_language_search_desktop/code.html) | Semantic plain English query discovery |
| 12 | **Multi-Channel Notification Center** | [Open Notifications](http://127.0.0.1:3000/campus_care_unified_multi_channel_notification_center_desktop/code.html) | Multi-channel alert audit logs |
| 13 | **Multi-Campus Switcher** | [Open Switcher](http://127.0.0.1:3000/campus_care_institution_workspace_switcher_desktop/code.html) | Multi-campus institution switching |
| 14 | **Swagger API Explorer** | [Open Swagger](http://127.0.0.1:8000/docs) | Interactive live Supabase DB queries |

---

## 🏁 Starting Point for Next Session

1. **Deploy Backend on Render**:
   - Go to [render.com](https://render.com) → New Web Service → connect `samruddhi-1324/Campus-Management-System`
   - Root dir: `backend`, Branch: `main`, Start cmd: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - Add all env vars from the **Supabase & Database Secrets** table above.
   - Verify: `https://campus-care-backend.onrender.com/docs` should show Swagger UI.

2. **Deploy Frontend on Vercel**:
   - Go to [vercel.com](https://vercel.com) → New Project → import `samruddhi-1324/Campus-Management-System`
   - Root dir: `frontend`, Framework: `Other`
   - Add env var: `API_BASE_URL = https://campus-care-backend.onrender.com/api/v1`
   - Vercel will use the `buildCommand` from `frontend/vercel.json` automatically.

3. **Update CORS After Vercel Deploy**:
   - Go to Render → Environment → change `BACKEND_CORS_ORIGINS` from `*` to your actual Vercel URL.
   - Example: `https://campus-care-abc123.vercel.app`

4. **End-to-End Live Cloud Verification**:
   - Login from Vercel URL → File a complaint → Triage as Coordinator → Resolve as Supervisor.
   - Check Supabase dashboard to confirm DB writes.

---

## 🐛 Known Bugs Fixed

| Bug | Root Cause | Fix | Commit |
|---|---|---|---|
| `SettingsError: error parsing BACKEND_CORS_ORIGINS` | `pydantic-settings` calls `json.loads()` on `list[str]` fields before validators run. `*` is not valid JSON. | Changed field type to `str`, added `cors_origins` property in `Settings` for safe parsing. Updated `main.py` to use `settings.cors_origins`. | `9595411` |

---

**Active Branches**: `develop` & `main`  
**Latest Commit on main**: `9595411` — CORS fix deployed  
