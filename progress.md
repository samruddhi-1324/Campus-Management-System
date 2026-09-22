# Campus Care — Technical Architecture & Repository Memory

**Project**: Campus Care (AI-Powered Facilities & Academic Issue Tracker)  
**Repository**: [`samruddhi-1324/Campus-Management-System`](https://github.com/samruddhi-1324/Campus-Management-System)  
**Specification Version**: PRD & SRS v3.0  
**Current Milestone**: **ALL PHASES COMPLETED (100%)** — Phase 1 (MVP), Phase 2 (Academic Intelligence), Phase 3 (Enterprise & Multimodal), Phase 4 (Stitch UI/UX 14 Screen Pairs for Desktop & Mobile) · 19/19 Automated Tests Passing · Local PostgreSQL Database Seeded · Live Servers Active  
**Active Branch**: `develop`  
**Last Updated**: 2026-09-22  

---

## 🗄️ Local PostgreSQL Database Inventory (`campus_care`)

- **Connection URL**: `postgresql+asyncpg://postgres:root@localhost:5432/campus_care`
- **Total Tables**: 25 (24 domain entities + `alembic_version`)
- **Seeded Master Data**:
  - **Admin User**: `admin@campuscare.edu` / `Admin@123456` (`role = ADMIN`)
  - **Categories (8)**: AC, Projectors & AV, Campus Wifi & Network, Lab Equipment, Library Services, Academic Concern, Electrical & Power, Plumbing & Washrooms
  - **Buildings & Rooms (3 Buildings / 10 Rooms)**: Main Academic Block (101, 102, 201, 301), Science & Research Center (L101, L102, L201), Central Library Building (G01, 101, 201)

---

## 🎨 Stitch UI Screen Catalog & Multi-Target Layout Specs

| # | Screen Name | Route | Responsive Form Factors (Desktop / Web / Mobile) |
|---|---|---|---|
| **1** | **Login & Authentication** | `/login` | Split-screen hero on Desktop/Web; single-column touch with biometrics & role pill on Mobile |
| **2** | **Institution Workspace Selector** | `/institution/select` | 3-column interactive card grid on Web/Desktop; vertical swipeable list with bottom confirm bar on Mobile |
| **3** | **Reporter: My Issues Dashboard** | `/reporter/issues` | Dual-pane split view with live preview on Desktop; segmented status tabs with FAB on Mobile |
| **4** | **Reporter: File New Issue** | `/reporter/new` | 2-column form with waveform voice recorder on Web; step scroll with camera trigger on Mobile |
| **5** | **Issue Detail & Resolution Stepper** | `/reporter/issues/:id` | 2-column lifecycle timeline with internal notes toggle on Desktop; tabbed view with confirm/reopen bar on Mobile |
| **6** | **Confidential Academic Concerns** | `/academic/concerns` | Centered Privacy Shield card on Web; biometric-protected full-screen form on Mobile |
| **7** | **Coordinator Queue & Triage Desk** | `/coordinator/queue` | Full-width triage table with AI suggestions & batch actions on Desktop; swipeable triage cards on Mobile |
| **8** | **Supervisor SLA Risk Radar** | `/supervisor/sla-risks` | Radial countdown grid with 1-click escalation on Desktop; priority list with 1-tap WhatsApp ping on Mobile |
| **9** | **Academic Officer Confidential Review** | `/academic/concerns/:id/review` | Split-pane audit trail & disposition editor on Desktop; secure multi-step hearing review on Mobile |
| **10** | **Operations Analytics Dashboard** | `/ops/analytics` | 4 KPI cards, MTTR charts, and CSV export on Desktop; swipeable KPI carousel on Mobile |
| **11** | **Failure Recurrence Hotspot Tracker** | `/recurrence/patterns` | 2-column equipment fatigue cards with ROI calculation on Desktop; vertical scroll cards on Mobile |
| **12** | **AI Asset Replacement Suggestions** | `/recommendations` | Grid of AI recommendation cards with confidence meters on Desktop; stacked decision cards on Mobile |
| **13** | **Multi-Year Seasonal Pattern Mining** | `/historical-analytics` | Multi-year longitudinal alerts and capital expenditure plan on Desktop; stacked alert cards on Mobile |
| **14** | **Natural Language & Semantic Search** | `/search` | Plain English query bar with real-time AI parsed filter chips and 2-column result cards |
| **15** | **Multi-Channel Notification Center** | `/notifications` | Left channel sidebar on Desktop; segmented filter pills with swipe-to-dismiss cards on Mobile |

---

## 🧪 Verification & Automated Test Matrix

### 19/19 Pytest Integration Suite (`backend/tests/`)
1. `test_all_models_registered_in_metadata`: Verifies all 24 SQLAlchemy models exist in shared metadata.
2. `test_postgresql_ddl_compilation`: Validates PostgreSQL DDL compilation for all schemas.
3. `test_issue_model_instantiation`: Tests Issue entity instantiation and default state.
4. `test_user_roles_enum`: Validates RBAC UserRole enum coverage.
5. `test_password_hashing`: Tests bcrypt password verification and salt generation.
6. `test_jwt_access_token_generation`: Validates JWT HMAC-SHA256 signature and claims.
7. `test_jwt_refresh_token_generation`: Validates long-lived refresh token lifecycles.
8. `test_valid_forward_transitions`: Tests state machine valid progression.
9. `test_invalid_transitions`: Verifies prohibited state transitions reject immediately.
10. `test_validate_transition_role_enforcement`: Tests RBAC checks on state transitions.
11. `test_invalid_transition_raises_400`: Verifies HTTP 400 Bad Request on invalid state transition.
12. `test_academic_concern_creation_and_confidential_access`: Verifies confidential concern creation and mandatory `ConfidentialAccessLog` generation.
13. `test_recurrence_detection_and_replacement_conversion`: Verifies rolling-window failure detection and conversion to replacement recommendation.
14. `test_sla_calculation_and_urgency_factors`: Tests dynamic urgency multipliers and SLA target calculations.
15. `test_analytics_drilldown_and_csv_export`: Tests operations analytics KPI aggregations and streamed CSV generation.
16. `test_tenant_creation_and_lookup`: Verifies multi-institution tenant provisioning and domain/slug resolution (FR-3.4, FR-3.6).
17. `test_voice_transcription_and_classification`: Verifies voice audio transcription and automatic AI advisory classification pipeline (FR-3.1).
18. `test_natural_language_search_parsing_and_execution`: Verifies natural language query parsing and dynamic issue filter execution (FR-3.2, FR-3.3).
19. `test_historical_trend_analytics_and_seasonal_patterns`: Verifies multi-year longitudinal pattern mining and seasonal spike detection (FR-3.5).

---

## 📋 Complete Git Branches & Milestone Checkpoints

| Branch Name | Status | Key Deliverables & Changes |
|---|---|---|
| `main` | Production Baseline | Clean base with CI/CD and specifications |
| `develop` | **Active Working Branch** (`2717b4a`) | Phase 1, Phase 2, Phase 3 fully implemented, Ruff 100% formatted, 19/19 tests passing, local PostgreSQL seeded |
| `feature/phase-1-mvp` | Merged / Pushed | Core state machine, RBAC, master data, attachments, notifications, 11 tests |
| `feature/phase-2-academic-intelligence` | Merged / Pushed (`3b64773`) | Academic concerns subsystem, recurrence tracker, AI recommendations, SLA radar, analytics dashboard, CSV export |
| `feature/phase-3-enterprise-multimodal` | Merged / Pushed (`3b64773`) | Multi-institution tenancy, voice transcription & AI classification, natural language search, multi-year historical trend mining, WhatsApp webhook handler, Flutter UI additions |

---

## 🎯 Next Session Starting Point: UI Stitch Import & 1:1 Flutter Integration

When resuming in the next session:
1. **Import Stitch `.zip` Package**: Extract Stitch-generated UI screens into `frontend/` assets/designs.
2. **Implement 1:1 Flutter UI Components**: Build pixel-perfect, adaptive Flutter widgets for Web, Desktop, and Mobile matching the imported Stitch designs.
3. **Connect API Client Endpoints**: Wire the Flutter UI state management (Riverpod/BLoC/Provider) to the live FastAPI backend.
4. **End-to-End Verification**: Run full Flutter analyze and integration test suite across all 15 screens.

```mermaid
flowchart TD
    subgraph ClientLayer["Frontend Client (Single Flutter Codebase)"]
        WEB["Web Browser (CanvasKit, in-memory tokens)"]
        DESKTOP["Desktop: Windows / macOS / Linux (Secure Credential Store)"]
        MOBILE["Mobile: Android / iOS (Direct Camera, Push, Offline Cache)"]
    end

    subgraph APILayer["Backend Server (FastAPI Async)"]
        GATEWAY["API Router & JWT / RBAC Middleware"]
        STATEMACHINE["Issue Lifecycle State Machine Engine"]
        ACADEMIC_SVC["Confidential Academic Concerns & Audit Trail Engine"]
        RECURRENCE_SVC["Rolling Failure Recurrence & Fatigue Tracker"]
        RECOMMEND_SVC["AI Asset Replacement Recommendation Engine"]
        SLA_SVC["Dynamic SLA Multiplier & Risk Predictor"]
        ANALYTICS_SVC["Operations Analytics, Drilldown & CSV Export"]
        NOTIF_ORCH["Multi-Channel Notification Orchestrator"]
        STORAGE_MED["Supabase Storage Signed URL Mediator"]
        AI_ADVISORY["AI Advisory Subsystem Client (Human-in-the-loop)"]
        AUDIT_ENGINE["Immutable System Audit Trail Engine"]
    end

    subgraph DataLayer["Persistence & Storage Layer"]
        SUPABASE_DB[("Supabase PostgreSQL (SQLAlchemy 2.0 Async / asyncpg)")]
        SUPABASE_STORAGE["Supabase Storage (Private Buckets)"]
        REDIS_QUEUE[("Redis Background Task Queue")]
    end

    subgraph ExternalGateways["External Gateways & Providers"]
        LLM_SVC["LLM Providers: Anthropic Claude / OpenAI"]
        EMAIL_GW["Email: Gmail SMTP (Dev) / Brevo (Prod) / Resend (Failover)"]
        SMS_GW["SMS Gateway (Twilio / Provider)"]
        WA_GW["Meta WhatsApp Business Cloud API (OAuth 2.0)"]
        PUSH_GW["Firebase Cloud Messaging (FCM) & WebSocket"]
    end

    ClientLayer -->|HTTPS REST & WebSocket| GATEWAY
    GATEWAY --> STATEMACHINE
    GATEWAY --> ACADEMIC_SVC
    GATEWAY --> RECURRENCE_SVC
    GATEWAY --> RECOMMEND_SVC
    GATEWAY --> SLA_SVC
    GATEWAY --> ANALYTICS_SVC
    GATEWAY --> STORAGE_MED
    GATEWAY --> NOTIF_ORCH
    GATEWAY --> AI_ADVISORY
    GATEWAY --> AUDIT_ENGINE

    STATEMACHINE --> SUPABASE_DB
    ACADEMIC_SVC --> SUPABASE_DB
    RECURRENCE_SVC --> SUPABASE_DB
    RECOMMEND_SVC --> SUPABASE_DB
    SLA_SVC --> SUPABASE_DB
    ANALYTICS_SVC --> SUPABASE_DB
    AUDIT_ENGINE --> SUPABASE_DB
    STORAGE_MED --> SUPABASE_STORAGE
    NOTIF_ORCH --> REDIS_QUEUE

    AI_ADVISORY -.->|Asynchronous Advice| LLM_SVC
    REDIS_QUEUE --> EMAIL_GW
    REDIS_QUEUE --> SMS_GW
    REDIS_QUEUE --> WA_GW
    REDIS_QUEUE --> PUSH_GW
```

---

## 🗄️ Deep Database & Data Model Specification

### 1. Persistence Architecture
- **Engine**: Supabase Managed PostgreSQL using `postgresql+asyncpg://` over pooled connections (`pool_size=10`, `max_overflow=5`, `pool_timeout=30s`).
- **Test Engine**: In-memory SQLite with custom `@compiles(JSONB, "sqlite")` handler in `tests/conftest.py` allowing 100% offline isolated integration test execution.
- **ORM**: SQLAlchemy 2.0 async with `DeclarativeBase` and `TimestampMixin` (`created_at`, `updated_at` with timezone).
- **Migrations**: Alembic with automated schema-drift detection and single-head enforcement in CI/CD.

### 2. Entity-Relationship Matrix (24 Relational Tables)

| Domain | Table Name | Key Attributes | Relationships & Constraints |
|---|---|---|---|
| **Tenancy** | `institutions` | `id`, `name`, `slug`, `domain`, `settings`, `is_active` | Unique `slug` & `domain`. Multi-tenant scoping for Phase 3. |
| **Master Data** | `departments` | `id`, `name`, `code`, `is_active` | Unique `name` & `code`. |
| | `buildings` | `id`, `name`, `code`, `is_active` | Unique `name` & `code`. Parent to `rooms`. |
| | `rooms` | `id`, `building_id`, `room_number`, `floor`, `room_type` | Unique `(building_id, room_number)`. Foreign key to `buildings(id) ON DELETE CASCADE`. |
| | `categories` | `id`, `name`, `slug`, `description`, `default_sla_hours` | Unique `slug`. Covers AC, Projector, Wifi, Lab, Library, Academic. |
| | `teams` | `id`, `name`, `supervisor_id`, `is_active` | Foreign key to `users(id)` for team lead supervisor. |
| **Users & Security** | `users` | `id`, `email`, `hashed_password`, `full_name`, `role`, `department_id` | Role ENUM (`reporter`, `coordinator`, `supervisor`, `ops_head`, `admin`). |
| | `user_contact_channels` | `id`, `user_id`, `channel_type`, `address_or_number`, `is_verified` | Type ENUM (`email`, `sms`, `whatsapp`, `in_app`). PII encrypted at rest. |
| | `user_devices` | `id`, `user_id`, `fcm_token`, `transport_type`, `platform`, `app_version` | Supports multi-device concurrent sessions. `fcm_token` nullable for WebSocket devices. |
| | `notification_preferences` | `id`, `user_id`, `event_category`, `channel_type`, `enabled` | Unique `(user_id, event_category, channel_type)` for user granular control. |
| **Issue Core Engine** | `issues` | `id`, `reference_number`, `title`, `description`, `status`, `urgency`, `reporter_id`, `assigned_coordinator_id`, `expected_resolution_at` | Unique `reference_number`. Status ENUM (11 states). Urgency ENUM (`low`, `medium`, `high`, `critical`). |
| | `issue_attachments` | `id`, `issue_id`, `attachment_type`, `storage_bucket`, `storage_path`, `size_bytes`, `uploaded_by` | Private Supabase bucket metadata. No file bytes in DB. Soft-delete support. |
| | `issue_updates` | `id`, `issue_id`, `author_id`, `visibility`, `message` | Visibility (`external` public vs. `internal` staff-only). |
| | `issue_state_history` | `id`, `issue_id`, `from_state`, `to_state`, `changed_by`, `reason` | Immutable state transition trail (FR-1.29). |
| | `issue_groups` | `id`, `primary_issue_id`, `created_by`, `notes` | Deduplication grouping requiring human confirmation (FR-AI-03). |
| **Audit & Observability** | `audit_log_entries` | `id`, `actor_id`, `action`, `target_entity`, `target_id`, `before_state`, `after_state`, `ip_address`, `user_agent` | Action ENUM (10 actions). Full JSONB before/after snapshot. |
| | `ai_insights` | `id`, `issue_id`, `insight_type`, `payload`, `confidence`, `human_decision`, `decided_by` | Tracks human acceptance/override of AI advice. |
| | `notification_logs` | `id`, `user_id`, `channel`, `template`, `provider`, `status`, `idempotency_key`, `sent_at` | Unique `idempotency_key` preventing duplicate dispatches. |
| **Phase 2 & 3 Subsystems** | `academic_concerns` | `id`, `issue_id`, `concern_type`, `course_code`, `assigned_academic_officer_id`, `is_confidential` | Strict confidentiality isolation from facilities pool. |
| | `confidential_access_logs`| `id`, `academic_concern_id`, `accessed_by`, `access_reason`, `accessed_at` | Mandatory access audit logging for academic grievances. |
| | `recommendations` | `id`, `recommendation_type`, `scope_reference`, `title`, `body`, `evidence_snapshot`, `confidence`, `human_decision` | Resolution, Preventive Maintenance, and Resourcing recommendations. |
| | `recurrence_patterns` | `id`, `asset_or_location_ref`, `failure_count`, `observation_window_days`, `related_issue_ids`, `status` | 30/60/90 days rolling failure detector. |
| | `category_sla_configs` | `id`, `category_id`, `building_id`, `urgency_level`, `expected_response_hours`, `expected_resolution_hours` | Multi-tier SLA target windows. |
| | `historical_trend_records`| `id`, `institution_id`, `category_id`, `year`, `total_volume`, `avg_resolution_hours`, `seasonal_spike_flag` | Multi-year historical pattern dataset. |

---

## 🔄 Issue Lifecycle State Machine & Transition Rules

```mermaid
stateDiagram-v2
    [*] --> Reported
    Reported --> Understood: Coordinator Triages
    Reported --> Assigned: Direct Assignment
    Reported --> Escalated: High SLA Risk

    Understood --> Assigned: Assign Coordinator
    Understood --> WaitingForInfo: Missing Details Requested
    Understood --> Escalated: Urgency Escalation

    Assigned --> Investigating: Inspection Begins
    Assigned --> WaitingForInfo: Additional Info Needed
    Assigned --> Escalated: Overdue

    Investigating --> ActionTaken: Repair / Maintenance Done
    Investigating --> WaitingForInfo: Parts / Clarification
    Investigating --> Escalated: Complex Failure

    ActionTaken --> Resolved: Coordinator Marks Resolved
    ActionTaken --> Investigating: Further Work Needed

    Resolved --> Confirmed: Reporter Accepts Fix
    Resolved --> Reopened: Reporter Rejects Fix ("Still Broken")
    Resolved --> Closed: Auto-Close Timeout Policy

    Confirmed --> Closed: Terminal Close
    Reopened --> Investigating: Re-enters Active Queue

    WaitingForInfo --> Understood: Reporter Responds
    WaitingForInfo --> Assigned: Info Received
    WaitingForInfo --> Investigating: Info Received

    Escalated --> Assigned: Reassigned by Supervisor
    Escalated --> Investigating: Prioritized Fix
    Escalated --> ActionTaken: Supervisor Intervention

    Closed --> [*]
```

### Transition Enforcement Rules (FR-1.28..30, NFR-SEC-03):
1. **Reporter-Only Guard**: Only the issue reporter (`reporter_id = auth.uid()`) can trigger transitions to `CONFIRMED` or `REOPENED`.
2. **No Direct Closure**: No transition directly from `REPORTED` to `CLOSED` is permitted; issues must proceed through triage and resolution.
3. **No Autonomous AI Transitions**: Merging issues (`issue_groups`) and closing issues strictly require human confirmation (FR-AI-11).
4. **Immutable Logging**: Every transition automatically generates an entry in `issue_state_history` and `audit_log_entries`.

---

## 🔒 Confidential Academic Concerns Engine (Phase 2)

### 1. Security & Privacy Shield (FR-2.1 – FR-2.3, NFR-SEC-01)
- Academic issues (grading disputes, thesis advisor conflicts, exam grievances) are decoupled from the general facilities queue.
- **Strict Role-Based Access Control**: Only users with role `admin` or designated `academic_officer` can view or update academic concerns.
- **Mandatory Audit Logging**: Whenever an officer accesses or triages a confidential record, an immutable entry is written to `confidential_access_logs` recording:
  - `academic_concern_id`
  - `accessed_by` (User UUID)
  - `access_reason` (Explicit explanation provided by officer)
  - `accessed_at` (Timestamp)

### 2. Failure Recurrence & AI Replacement Engine (FR-2.4 – FR-2.7)
- **Recurrence Engine (`recurrence_service.py`)**: Computes breakdown frequencies across rolling 14/30/60/90 day windows using ANSI SQL queries.
- **1-Click Conversion**: High recurrence clusters can be directly converted into formal `recommendations` records with automated ROI calculation and evidence snapshots.
- **Human-in-the-Loop Decision Recording**: Ops Head can mark recommendations as `accepted`, `dismissed`, or `acted`.

### 3. Dynamic SLA Engine & Analytics (FR-2.8 – FR-2.10)
- **Urgency Multiplier**: Multi-factor SLA urgency scoring based on historical breach rates and high-traffic building weights.
- **Executive Analytics & CSV Export**: Real-time KPI summaries, drilldown queue filtering, and streamed CSV exports with proper RFC-4180 escaping.

---

## 📱 Cross-Platform Flutter Client Architecture

### 1. Implemented UI Screen Inventory

| Screen | Route | Role / Target | Key Features & Implementation |
|---|---|---|---|
| **Login** | `/login` | All Users | Role-based JWT auth, password toggle, tenant logo |
| **My Issues** | `/reporter/issues` | Reporter (Student/Faculty) | Status tabs, SLA countdown, quick issue filing FAB |
| **Report Issue** | `/reporter/new` | Reporter | Category/Building picker, photo upload, voice note trigger |
| **Issue Detail** | `/reporter/issues/:id` | Reporter / Staff | Timeline view, staff note filtering, confirm/reopen buttons |
| **Coordinator Queue** | `/coordinator/queue` | Facilities Coordinator | Unassigned triage queue, priority indicators, batch actions |
| **Issue Triage** | `/coordinator/issues/:id/triage` | Coordinator | AI category suggestion badge, duplicate detector, assign worker |
| **Supervisor Workload** | `/supervisor/workload` | Supervisor | Team allocation matrix, active issue load per technician |
| **SLA Risk Radar** | `/supervisor/sla-risks` | Supervisor | Real-time breach risk list, countdown timers, 1-click urgency escalation |
| **Academic Concerns** | `/academic/concerns` | Student / Reporter | Confidential grievance form with Privacy Shield banner |
| **Confidential Triage** | `/academic/concerns/:id/confidential-review` | Academic Affairs Officer | Access reason audit badge, restricted officer notes, disposition actions |
| **AI Recommendations** | `/recommendations` | Operations Head / Admin | AI confidence score badges, cost estimates, Accept/Dismiss triggers |
| **Recurrence Tracker** | `/recurrence/patterns` | Ops Head / Supervisor | Rolling window hotspot cards, convert to replacement recommendation |
| **Analytics Dashboard** | `/ops/analytics` | Operations Head | KPI summary cards, drilldown list, 1-click CSV export downloader |
| **Admin Settings** | `/admin/settings` | Super Admin | Institution parameters, SLA thresholds, security policies |
| **Master Data** | `/admin/master-data` | Super Admin | Buildings, Rooms, Categories, and Team CRUD management |
| **Audit Logs** | `/admin/audit-logs` | Super Admin | Immutable JSONB state change history with IP and actor tracking |
| **Notification Center** | `/notifications` | All Users | Multi-channel dispatch history, read status toggles |

---

## 🧪 Verification & Automated Test Matrix

### 19/19 Pytest Integration Suite (`backend/tests/`)
1. `test_all_models_registered_in_metadata`: Verifies all 24 SQLAlchemy models exist in shared metadata.
2. `test_postgresql_ddl_compilation`: Validates PostgreSQL DDL compilation for all schemas.
3. `test_issue_model_instantiation`: Tests Issue entity instantiation and default state.
4. `test_user_roles_enum`: Validates RBAC UserRole enum coverage.
5. `test_password_hashing`: Tests bcrypt password verification and salt generation.
6. `test_jwt_access_token_generation`: Validates JWT HMAC-SHA256 signature and claims.
7. `test_jwt_refresh_token_generation`: Validates long-lived refresh token lifecycles.
8. `test_valid_forward_transitions`: Tests state machine valid progression.
9. `test_invalid_transitions`: Verifies prohibited state transitions reject immediately.
10. `test_validate_transition_role_enforcement`: Tests RBAC checks on state transitions.
11. `test_invalid_transition_raises_400`: Verifies HTTP 400 Bad Request on invalid state transition.
12. `test_academic_concern_creation_and_confidential_access`: Verifies confidential concern creation and mandatory `ConfidentialAccessLog` generation.
13. `test_recurrence_detection_and_replacement_conversion`: Verifies rolling-window failure detection and conversion to replacement recommendation.
14. `test_sla_calculation_and_urgency_factors`: Tests dynamic urgency multipliers and SLA target calculations.
15. `test_analytics_drilldown_and_csv_export`: Tests operations analytics KPI aggregations and streamed CSV generation.
16. `test_tenant_creation_and_lookup`: Verifies multi-institution tenant provisioning and domain/slug resolution (FR-3.4, FR-3.6).
17. `test_voice_transcription_and_classification`: Verifies voice audio transcription and automatic AI advisory classification pipeline (FR-3.1).
18. `test_natural_language_search_parsing_and_execution`: Verifies natural language query parsing and dynamic issue filter execution (FR-3.2, FR-3.3).
19. `test_historical_trend_analytics_and_seasonal_patterns`: Verifies multi-year longitudinal pattern mining and seasonal spike detection (FR-3.5).

---

## 📋 Complete Git Branches & Milestone Checkpoints

| Branch Name | Status | Key Deliverables & Changes |
|---|---|---|
| `main` | Production Baseline | Clean base with CI/CD and specifications |
| `develop` | Integration Baseline | Unified architecture, Alembic migrations, database models |
| `feature/phase-1-mvp` | Merged / Pushed | Core state machine, RBAC, master data, attachments, notifications, 11 tests |
| `feature/phase-2-academic-intelligence` | Merged / Pushed | Academic concerns subsystem, recurrence tracker, AI recommendations, SLA radar, analytics dashboard, CSV export, 15 tests |
| `feature/phase-3-enterprise-multimodal` | **Active & Completed** | Multi-institution tenancy, voice transcription & AI classification, natural language search, multi-year historical trend mining, WhatsApp webhook handler, Flutter UI additions, 19 tests |

---

## 🎯 Phase 3 Complete (Enterprise Readiness & Self-Healing Platform)

All Phase 3 deliverables have been implemented:
1. **Multimodal Voice Input (FR-3.1, FR-PLAT-09)**: Audio recording transcription chained with automated AI classification.
2. **Natural Language Search (FR-3.2, FR-3.3)**: Intent parsing and dynamic SQL query generator with RBAC filtering (`/search/query`).
3. **Multi-Year Historical Trend Analytics (FR-3.4, FR-3.5)**: Longitudinal seasonal breakdown analytics & long-term budgeting recommendations (`/historical-analytics/multi-year`).
4. **Multi-Tenant Institution Management (FR-3.6, FR-3.7)**: Tenant domain routing, slug validation, and institution switcher (`/tenants/`).
5. **Meta WhatsApp Inbound Webhook**: Meta WhatsApp Cloud API challenge verification & inbound message handler (`/webhooks/whatsapp`).

