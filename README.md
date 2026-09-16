# Campus Care

**AI-Powered Facilities & Academic Issue Tracker**  
*Single codebase, multi-target (Web, Windows, macOS, Linux, Android, iOS) issue resolution system.*

---

## 🏛️ Architecture Overview

Campus Care is organized into clean, decoupled layers following the PRD and SRS v3.0 specifications:

- **Frontend (`frontend/`)**: Single Flutter codebase targeting Web, Desktop (Windows, macOS, Linux), and Mobile (Android, iOS) with adaptive layouts.
- **Backend (`backend/`)**: FastAPI (Python async) REST & WebSocket API, implementing core lifecycle state machines, audit trails, and security.
- **Database & Migrations (`backend/alembic/`)**: Supabase-managed PostgreSQL with SQLAlchemy 2.0 async ORM and Alembic automated schema migrations.
- **Storage**: Supabase Storage private buckets accessed exclusively via backend-issued short-lived signed URLs.
- **AI Subsystem (`ai/` & `backend/app/integrations/ai/`)**: LLM advisory layer for auto-classification, urgency scoring, duplicate detection, recurrence analysis, and plain-language summaries (Human-in-the-loop).
- **Communications (`backend/app/integrations/notifications/`)**: Multi-channel notification orchestrator supporting In-app, Email (Gmail SMTP / Brevo / Resend failover), SMS, WhatsApp Business Cloud API, and Push (FCM + WebSocket).
- **CI/CD (`.github/workflows/`)**: Automated testing, linting, Alembic schema drift detection, and multi-platform build checks.

---

## 📁 Repository Structure

```
├── .github/
│   └── workflows/              # CI/CD pipelines (schema drift, tests, builds)
├── Docs/                       # PRD and SRS v3.0 specifications
├── ai/                         # AI subsystem prompts, evaluators & recommendation logic
├── backend/                    # FastAPI async application
│   ├── alembic/                # Database migrations
│   ├── app/
│   │   ├── api/                # API route controllers & dependencies
│   │   ├── core/               # App configuration, security, database engine
│   │   ├── integrations/       # External adapters (Storage, Notifications, AI)
│   │   ├── models/             # SQLAlchemy 2.0 async ORM entities
│   │   ├── schemas/            # Pydantic v2 validation models
│   │   └── services/           # Business logic & lifecycle state machine
│   ├── tests/                  # Backend unit, integration & migration tests
│   ├── alembic.ini             # Alembic configuration
│   └── requirements.txt        # Python dependencies
├── frontend/                   # Shared Flutter application
│   ├── lib/
│   │   ├── app/                # App entry, router & theme
│   │   ├── core/               # Core services, responsive layout & HTTP client
│   │   ├── features/           # Clean-architecture feature modules
│   │   └── shared/             # Shared reusable UI components
│   └── pubspec.yaml            # Flutter dependencies
├── tests/                      # End-to-end and cross-cutting test suites
├── .env.example                # Configuration template
└── docker-compose.yml          # Local development infrastructure
```

---

## 🚀 Phased Delivery

- **Step 1 — Foundation**: Architecture, configurations, database, backend/frontend scaffold, adapters, CI/CD.
- **Step 2 — Phase 1 (MVP)**: Facilities issue lifecycle, RBAC (5 roles), Web + Desktop, photos, AI advisory, notifications.
- **Step 3 — Phase 2**: Android + iOS mobile clients, Academic Concerns category, recurrence detection, deeper analytics.
- **Step 4 — Phase 3**: Voice input, natural language search, app-store distribution, multi-institution support.
