# Campus Care — Project Progress & Memory Log

**Repository**: `samruddhi-1324/Campus-Management-System`  
**Current State**: Architecture & Database Setup Complete · Ready for Feature Implementation  
**Last Updated**: 2026-09-16  

---

## 🎯 Project Overview & Source of Truth

- **Source Specifications**:
  - `Docs/Campus_Care_PRD.md` (Product Requirements Document)
  - `Docs/Campus_Care_SRS_v3.0.md` (Software Requirements Specification v3.0)
- **Tech Stack**:
  - **Frontend**: Flutter (Single shared codebase targeting Web, Windows, macOS, Linux, Android, iOS)
  - **Backend**: FastAPI (Python async, ASGI)
  - **Database**: Supabase (Managed PostgreSQL)
  - **ORM**: SQLAlchemy 2.0 async (with asyncpg pooled connection)
  - **Database Migrations**: Alembic
  - **Storage**: Supabase Storage (Private buckets with short-lived signed URLs)
  - **AI Subsystem**: LLM Advisory Subsystem (Human-in-the-loop, Anthropic/OpenAI, zero-downtime manual fallback)
  - **Communications Engine**: Multi-channel notification orchestrator (In-app, Email via SMTP/Brevo/Resend failover, SMS, WhatsApp Meta Cloud API, Push via FCM & WebSocket)

---

## 🚀 Accomplished Milestones

### ✅ Step 1 — Foundation (Completed & Synced)
- Root configuration: `.env.example`, `.gitignore`, `README.md`, `docker-compose.yml`.
- Shared Flutter foundation: `adaptive_layout.dart` (Compact <600dp, Medium 600-1024dp, Expanded >1024dp), `api_client.dart` with auth interceptors, `secure_storage.dart` (in-memory for Web, Keychain/Keystore/DPAPI for Desktop/Mobile).
- Backend async engine: SQLAlchemy 2.0 engine with connection pooling, Alembic async migration environment.
- Service adapters: Supabase Storage signed URLs adapter, Multi-channel notification orchestrator, AI advisory client.
- CI/CD: GitHub Actions pipeline enforcing Alembic single-head and schema-drift detection.

### ✅ Step 2 — Phase 1 (MVP) Structure (Completed & Synced)
- 5 Actor Dashboards: Reporter, Coordinator, Supervisor, Ops Head, Admin.
- Core Issue Lifecycle State Machine: `Reported` ➔ `Understood` ➔ `Assigned` ➔ `Investigating` ➔ `Action Taken` ➔ `Resolved` ➔ `Confirmed` ➔ `Closed` + Sub-states (`Waiting for Info`, `Escalated`, `Reopened`).
- Models & Schemas: `users`, `issues`, `issue_attachments`, `issue_updates`, `issue_state_history`, `issue_groups`, `departments`, `buildings`, `rooms`, `categories`, `teams`, `audit_log_entries`, `ai_insights`, `notification_logs`.
- AI Prompts & Schemas (v1): Versioned prompts and JSON schemas for classification, urgency, duplicate detection, draft updates, and weekly executive summaries.

### ✅ Step 3 — Phase 2 Structure (Completed & Synced)
- Academic Concerns Category: Confidential grievance workflow, designated officer routing, and `confidential_access_logs`.
- Advanced AI Decision-Support: Prior resolution recommendation, running thread summaries, and 30/60/90 days rolling-window failure recurrence detection (`recurrence_patterns`).
- Multi-tier SLA configuration: `category_sla_configs` per category and building.
- Mobile Native Enhancements: Android & iOS offline SQLite read cache (`local_cache_service.dart`) and direct camera capture (`mobile_camera_service.dart`).

### ✅ Step 4 — Phase 3 Structure (Completed & Synced)
- Voice Input: Audio recording service (`voice_recorder_service.dart`), Supabase Storage audio transfer, and speech-to-text AI classification pipeline.
- Natural Language Search: Everyday phrasing parser (`nl_search_service.py`) producing role-scoped SQL filters.
- Multi-Institution Tenancy: `institutions` table and multi-tenant scoping.
- Historical Pattern Mining: Multi-year trend analysis (`historical_trend_records`) and seasonal anomaly detection.

### ✅ Database Layer & Supabase Initialization (Completed & Synced)
- **Supabase DDL Script**: `backend/supabase_schema.sql` (24 PostgreSQL tables, custom ENUMs, foreign keys, performance indexes, and Supabase Row Level Security RLS policies).
- **Alembic Migration**: `backend/alembic/versions/2026_09_16_0001_initial_supabase_schema.py` (Versioned forward/rollback migration).
- **Master Data Seeder**: `backend/app/core/seed_db.py` (Default Admin account: `admin@campuscare.edu` / `Admin@123456`, default categories: AC, Projector, Wifi, Lab, Library, Academic, sample buildings & rooms).

---

## 🌿 Git & Repository Memory

- **Remote URL**: `https://github.com/samruddhi-1324/Campus-Management-System.git`
- **Active Branches**:
  - `main`: Production-ready stable release baseline.
  - `develop`: Ongoing integration branch (currently contains all Step 1–4 structures + Database scripts).
- **Branching Workflow for Future Sessions**:
  - `feature/auth-rbac` ➔ For JWT login, refresh tokens, password hashing, and login alerts.
  - `feature/issue-lifecycle` ➔ For issue creation, assignment, status transitions, and Reporter confirmation.
  - `feature/ai-integration` ➔ For live LLM advisory calls (Anthropic/OpenAI).
  - `feature/notifications` ➔ For multi-channel email/SMS/WhatsApp/FCM dispatch.
  - `feature/frontend-ui` ➔ For Flutter UI implementation of screens and widgets.

---

## 📋 Plan for Next Session

1. **Supabase Connection**:
   - Add the live Supabase database URL to `.env`.
   - Run Alembic migration or execute `supabase_schema.sql` in Supabase SQL Editor.
   - Run `python app/core/seed_db.py` to seed default master data and Admin.
2. **Feature Implementation (Starting with Auth & RBAC)**:
   - Implement `AuthService` with secure bcrypt hashing, JWT access/refresh token generation.
   - Implement login alerts trigger (Email/SMS/WhatsApp).
   - Test endpoints `/api/v1/auth/login` and `/api/v1/users/me`.
3. **Issue Engine Implementation**:
   - Implement `IssueService` and `IssueStateMachine` transitions.
   - Connect photo uploads with Supabase Storage signed URLs.
