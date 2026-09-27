# Campus Care — Progress & Repository Milestone Log

**Project**: Campus Care (AI-Powered Facilities & Academic Issue Tracker)  
**Repository**: [`samruddhi-1324/Campus-Management-System`](https://github.com/samruddhi-1324/Campus-Management-System)  
**Specification Version**: PRD & SRS v3.0  
**Current Milestone**: **FULL-STACK SUPABASE CLOUD, PHYSICAL DEVICE VERIFICATION & PRODUCTION DEPLOYMENT BLUEPRINTS COMPLETE**  

- **Phase 1 (MVP)**: Issue lifecycle state machine, RBAC, master data, attachments, notifications.
- **Phase 2 (Academic Intelligence)**: Confidential academic grievance portal, ombudsperson triage, recurrence detector, AI replacement suggestions, SLA risk radar.
- **Phase 3 (Enterprise & Multimodal)**: Multi-institution tenancy, voice recording & AI classification, natural language semantic search, multi-year historical trend mining, WhatsApp webhook handler.
- **Phase 4 (Stitch UI 14 Screen Pairs)**: 14 Desktop & 14 Mobile screens rendered with 100% pure Stitch design, fully wired in a continuous workflow loop using `WorkflowSequenceBar` allowing sequential step-by-step navigation (Step 01 to 14) across the entire application.
- **Phase 5 (Mobile Build & Physical Android Deployment — VERIFIED)**: Built release APK (53.6 MB), installed on device `D6YDOZOJOZZ54DY5`, verified 14-screen navigation flow on physical phone with `SafeArea` padded navigation bar.
- **Phase 6 (Supabase Cloud Database & Storage — LIVE)**: Connected live Supabase project `hiqvjnerhocpzxanlbbq` via async transaction pooler (`aws-0-ap-southeast-1.pooler.supabase.com:6543`), 25 tables initialized, pre-seeded accounts (`samruddhi@campuscare.edu` / `Admin@123456`), Supabase Storage private bucket configured.
- **Phase 7 (Production Cloud Blueprints & Git Sync)**:
  - Created `render.yaml` blueprint for 1-click FastAPI Render backend deployment.
  - Created `frontend/vercel.json` for Flutter Web single-page app (SPA) routing on Vercel.
  - Merged all features from `develop` into `main` branch (`git push origin main` - commit `839706b`).

**Active Branches**: `develop` & `main`  
**Last Updated**: 2026-09-28  

---

## 🚀 Live System Servers & Verification Endpoints

| Service / Platform | Port / URL | Status | Description |
|---|---|---|---|
| **FastAPI Async Backend** | `http://127.0.0.1:8000` & `http://0.0.0.0:8000` | 🟢 Active | OpenAPI docs at `/api/v1/docs` & root `/docs` |
| **Public HTTPS Backend Tunnel** | `https://campuscare-api.loca.lt` | 🟢 Active | Remote & mobile access tunnel |
| **UI Showcase Hub (14 Screens)** | `http://127.0.0.1:3000/index.html` | 🟢 Active | Master 14-screen showcase with desktop/mobile links |
| **Flutter Web Application** | `http://127.0.0.1:5000` | 🟢 Active | Compiled Flutter web client |
| **Physical Android Device** | Device `D6YDOZOJOZZ54DY5` | 🟢 Installed | Release APK installed and verified screen-by-screen |
| **Render Blueprint Configuration** | `render.yaml` | 🟢 Ready | Backend deployment blueprint for Render |
| **Vercel Blueprint Configuration** | `frontend/vercel.json` | 🟢 Ready | Frontend deployment configuration for Vercel |

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

1. **Execute Render & Vercel Cloud Deployment**:
   - Log into Render Dashboard, select `samruddhi-1324/Campus-Management-System`, set root dir to `backend`, and deploy.
   - Log into Vercel Dashboard, import repository, set root dir to `frontend`, and deploy Flutter Web.
2. **Update Frontend API Endpoint**:
   - Update `frontend/lib/app/config.dart` with live Render backend URL (`https://campus-care-backend.onrender.com/api/v1`).
3. **End-to-End Live Cloud Verification**:
   - Submit issue from Vercel Web / Physical Android App -> verify ticket in Supabase Cloud & Render Backend -> Triage & Resolve.
