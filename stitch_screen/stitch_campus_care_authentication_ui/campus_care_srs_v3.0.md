# Campus Care — Software Requirements Specification

**AI-Powered Facilities & Academic Issue Tracker · Phased Delivery · v3.0**

---

## Document Control

| Field | Value |
|---|---|
| Product Name | Campus Care |
| Document Type | Software Requirements Specification |
| Document Version | 3.0 |
| Supersedes | v2.0 |
| Source Document | Campus Care PRD (Non-Technical Version) |
| Delivery Approach | Phased (Phase 1 – MVP, Phase 2, Phase 3) |
| Intended Audience | Development team, QA, project reviewers, faculty guides |

### Revision History

| Version | Change | Affected Sections |
|---|---|---|
| 1.0 | Initial SRS derived from the Campus Care PRD. | — |
| 2.0 | **Database platform fixed to Supabase (managed PostgreSQL)**, replacing the generic "PostgreSQL or equivalent" placeholder. | 2.1, 2.4, 2.7, 9.1, 11.3 |
| 2.0 | **File storage fixed to Supabase Storage**, replacing the generic "S3-compatible object storage" placeholder; private buckets and signed-URL access specified. | 2.7, 5.1, 9.4, 11.3, 12.1 |
| 2.0 | **Resend added as a third email adapter** (automatic failover for production), alongside Gmail SMTP (local/dev) and Brevo (production). | 2.6, 2.7, 10.1, 10.5, 11.3 |
| 2.0 | **Push-to-device notification channel added** (Firebase Cloud Messaging) with device registration on login, so notifications reach a user's logged-in devices rather than only the in-app inbox. | 2.7, 10.1, 10.6, 12.1, 13 |
| 2.0 | **Database migration automation** requirements added (CI drift detection, single-head enforcement, pre-deploy gate, expand-and-contract rule, pre-migration backup checkpoint). | 9.3, 13 |
| 2.0 | **AI Recommendations sub-system** specified as a distinct capability (resolution, preventive-maintenance, and resourcing recommendations) with data-minimisation and human-in-the-loop constraints. | 8.1, 12.1, 13, 15 |
| 2.0 | Notification channel count updated from four to five (in-app, email, SMS, WhatsApp, **push**). | 1.2, 2.1, 10.1 |
| 3.0 | **Target platforms expanded to six**: web, Windows, macOS, Linux, Android, iOS — all from the single Flutter codebase. Desktop was absent from v2.0 entirely. | 1.2, 2.1, 2.4, 2.7, 4.1 |
| 3.0 | **Cross-platform client requirements added** (FR-PLAT-01–18): adaptive layout, input modality, capability detection, per-platform credential storage, deep linking, packaging and distribution, forced-upgrade handling, platform test matrix. | 4.2 |
| 3.0 | **Push transport differentiated by platform** (FR-NOTIF-30–34). FCM does not support Windows or Linux; those targets use an authenticated WebSocket plus OS-native local notifications. | 10.6a |
| 3.0 | **Phasing restructured** so that web and desktop ship together in Phase 1 and mobile in Phase 2, rather than deferring all mobile work to Phase 3. Constraint C-2 ("web-based only until Phase 3") is withdrawn. | 4, 4.1, 7, 14 |
| 3.0 | FR-3.3 rewritten: the Phase 3 mobile item becomes store distribution and device-native capability, not first delivery of a mobile client. | 7 |
| 3.0 | Compatibility NFRs expanded from browser-only to a six-target support statement. | 13 |

---

## 1. Introduction

### 1.1 Purpose

This Software Requirements Specification (SRS) translates the business and user needs described in the Campus Care PRD into a structured, technical, and testable set of software requirements. It is intended to guide system design, implementation, and verification, and is organized into **delivery phases** so that the system can be built and evaluated incrementally.

### 1.2 Scope

Campus Care is a web-based, AI-assisted issue management platform for higher-education campuses. The system allows reporters (students/staff) to submit facility- and (in later phases) academic-related issues, routes them to the correct operational team, tracks them through a defined lifecycle, and uses AI as a decision-support layer — never as an autonomous decision-maker — to classify, prioritize, deduplicate, summarize, and report on issues.

This SRS covers:

- Functional requirements (FR), grouped by phase and by actor
- Non-functional requirements (NFR): performance, security, availability, usability
- The AI subsystem's functional scope and its human-in-the-loop constraints
- Data persistence: ORM usage, the Supabase-managed database platform, and automated database migration management
- Target platform coverage: web, desktop (Windows/macOS/Linux), and mobile (Android/iOS) from one Flutter codebase, and the requirements that differ between them
- File storage: attachment handling through Supabase Storage, including access control and retention
- Automated multi-channel communications: Email, SMS, WhatsApp, push-to-device, and in-app, including login alerts and welcome messaging
- The AI Recommendations capability and the data-minimisation rules governing it
- Data entities and their relationships
- External interfaces (notification channels, authentication, storage)

This SRS does **not** cover UI visual design, low-level API contracts, or infrastructure/deployment architecture; those belong in a separate technical design document.

### 1.3 Definitions, Acronyms, Abbreviations

| Term | Definition |
|---|---|
| SRS | Software Requirements Specification |
| PRD | Product Requirements Document |
| Reporter | Student or staff member who submits an issue |
| Coordinator | Facilities Coordinator who resolves issues |
| Supervisor | Facilities Supervisor who oversees Coordinators |
| Ops Head | Campus Operations Head (management-level reporting user) |
| Admin | System Administrator |
| SLA | Service Level Agreement / expected resolution time window |
| FR | Functional Requirement |
| NFR | Non-Functional Requirement |
| Dedup | Deduplication (grouping duplicate issue reports) |
| MVP | Minimum Viable Product (Phase 1 scope) |
### 1.4 References

- Campus_Issue_Tracker_PRD.md (source PRD, non-technical version)

---

## 2. Overall Description

### 2.1 Product Perspective

Campus Care is a new, standalone system (not a modification of an existing legacy ticketing tool). It is composed of:

- A **Flutter front end** — a single cross-platform codebase compiled to **six targets**: web, Windows, macOS, Linux, Android, and iOS. All five actor roles are served by the same codebase on every target; the interface adapts to screen size and input modality rather than branching into separate applications (see Section 4.2)
- A **FastAPI (Python) backend** providing the core issue-management API (issue CRUD, lifecycle state machine, assignment logic, audit logging)
- A **data persistence layer** on **Supabase (managed PostgreSQL)**, accessed through an **ORM tool**, with schema changes managed through a **database migration tool** and applied by an **automated migration pipeline** (see Section 9; concrete tooling in Section 2.7)
- A **file storage layer** on **Supabase Storage**, holding issue attachments (photos in Phase 1, voice recordings in Phase 3) in private buckets accessed only via short-lived signed URLs (see Section 9.4)
- An **AI subsystem** that acts as an advisory layer over the core backend (classification, urgency scoring, dedup, recurrence detection, summarization, draft-messaging, reporting)
- A **multi-channel notification/communication layer** (in-app, push-to-device, Email — via Gmail SMTP in local/development, Brevo in production, and Resend as the production failover —, SMS, and WhatsApp) connecting Reporters and Coordinators, including automated login alerts, push delivery to a user's logged-in devices, and welcome messaging (see Section 10)
- An **administrative configuration module** for buildings, categories, teams, and roles

### 2.2 Product Functions (Summary)

1. Issue submission, tracking, and confirmation of resolution (Reporter)
2. Issue triage, assignment, and resolution workflow (Coordinator)
3. Team oversight, escalation, and SLA-risk monitoring (Supervisor)
4. Campus-wide analytics and trend reporting (Ops Head)
5. Master data and access configuration (Admin)
6. AI-assisted classification, urgency detection, deduplication, recurrence detection, resolution suggestion, summarization, and reporting (cross-cutting)

### 2.3 User Classes and Characteristics

See Section 3.

### 2.4 Operating Environment

- **Web:** Flutter Web build (CanvasKit renderer) served over HTTPS, on current major browsers — Chrome, Edge, Firefox, Safari
- **Desktop:** Flutter desktop builds for Windows 10/11 (x64), macOS 12+ (Universal: Apple Silicon and Intel), and Linux (x64, GTK-based distributions), installed locally and updated per FR-PLAT-13
- **Mobile:** Flutter builds for Android 8.0 (API 26) and above, and iOS 15 and above
- All six targets consume the same FastAPI REST/WebSocket API; no platform has a private endpoint or a divergent data contract (FR-PLAT-15)
- FastAPI (Python, ASGI) backend, deployed behind HTTPS, exposing a REST (or REST + WebSocket, for live status updates) API consumed by the Flutter front end
- **Supabase (managed PostgreSQL)** for issue records, accessed via an ORM tool and versioned through a database migration tool (see Section 2.7); Row Level Security is enabled on all user-scoped tables as a second line of defence behind application-level authorization
- **Supabase Storage** for issue attachments, using private buckets with signed-URL access (see Section 9.4)
- AI subsystem implemented via a large language model (LLM) service invoked as an advisory microservice/API from the FastAPI backend, not embedded as a chat interface
- Integration with third-party gateways for automated notifications: Gmail SMTP for Email in local/development environments, Brevo for Email in production with Resend as automatic failover, an SMS gateway, the WhatsApp Business Cloud API, and Firebase Cloud Messaging (FCM) for push delivery to logged-in devices

### 2.5 Design and Implementation Constraints

- AI outputs must always be labeled as suggestions, not facts, per PRD Section 8 ("Keeping Humans in Control")
- No automated merge or automated closure of issues is permitted; a human actor must confirm these actions (FR-AI-06, FR-AI-07)
- The platform must remain fully operational (manual workflow only) if the AI subsystem is unavailable (NFR-AVAIL-02)
- Reporters must never see another reporter's issues or internal staff notes (NFR-SEC-01, NFR-SEC-02)

### 2.6 Assumptions and Dependencies

- The institution provides an authoritative list of buildings, rooms, and departments for Admin configuration
- Users authenticate via institutional credentials (assumed SSO/institutional login availability) or a fallback local account system
- An AI/LLM service is available (internal or third-party API) capable of text classification and summarization tasks
- A Gmail account with 2-Step Verification and an App Password (or OAuth 2.0 credentials) is available for SMTP-based email sending in local/development environments
- A Brevo account (API key) is provisioned for transactional email sending in production
- A Resend account (API key) is provisioned as the production email failover provider
- A Supabase project is provisioned per environment (development, staging, production), each with its own database, storage buckets, and service credentials
- A Firebase project with Cloud Messaging enabled is provisioned, with Android, iOS, macOS, and Web app registrations matching the Flutter client, and a server-side service-account credential for the backend. **Firebase Cloud Messaging does not support Windows or Linux**; push on those targets is delivered by the alternative transport defined in Section 10.6a
- Code-signing identities are available for each distributed target: an Apple Developer account (iOS App Store, macOS notarization), an Android keystore (Play Store), and a Windows code-signing certificate; Linux packages are distributed unsigned or via the institution's own repository
- An SMS gateway account (API key / Account SID + Auth Token) is provisioned for SMS delivery
- A Meta WhatsApp Business Cloud API app is registered and approved, with OAuth 2.0 credentials provisioned for sending WhatsApp messages
- Users provide and keep current a valid phone number (for SMS/WhatsApp) and email address (for Email, sent via Gmail SMTP locally / Brevo in production) at account creation, so automated notifications can be delivered

### 2.7 Technology Stack

The following concrete technology choices satisfy the architectural requirements described in Sections 2.1–2.6 and are used as the reference stack for the remainder of this SRS. Individual components may be substituted during detailed design provided the corresponding functional and non-functional requirements are still met.

| Layer | Component | Selected Technology | Related Requirements |
|---|---|---|---|
| Frontend | Cross-platform client (web + desktop + mobile) | **Flutter** — one codebase, six build targets (web, Windows, macOS, Linux, Android, iOS) | §4.1 (platform matrix), §4.2 (FR-PLAT-01–18) |
| Client architecture | State management & routing | Declarative state layer with a single shared route table across all targets | FR-PLAT-08, FR-PLAT-15 |
| Client storage | Credentials & offline cache | Platform secure storage (Keychain / Keystore / DPAPI / libsecret); browser targets use in-memory tokens with an httpOnly refresh cookie. Local read cache via an embedded SQLite store on desktop and mobile | FR-PLAT-07, FR-PLAT-10 |
| Packaging | Distribution artifacts | Static web bundle; MSIX (Windows); notarized DMG (macOS); AppImage/.deb (Linux); AAB (Play Store); IPA (App Store) | FR-PLAT-12–14 |
| Backend | Application / API server | **FastAPI** (Python, ASGI) | Section 5–8 (all functional requirements) |
| Database | Relational data store | **Supabase** (managed PostgreSQL), `asyncpg` driver over the pooled connection string | Section 12 (Data Model), FR-DATA-01–04 |
| ORM | Data access layer | SQLAlchemy 2.0 (async), with Pydantic/SQLModel schemas for FastAPI integration | FR-DATA-01–04 |
| Migrations | Schema versioning | Alembic | FR-DATA-05–10 |
| Migration automation | CI/CD schema pipeline | Alembic executed as a gated pre-deploy step, with drift and multi-head checks in CI | FR-DATA-11–17 |
| AI Subsystem | LLM advisory service | Claude or GPT API, called asynchronously from FastAPI | FR-AI-01–12 |
| AI Recommendations | Recommendation generation | Deterministic feature layer + LLM narrative generation over de-identified aggregates | FR-AI-13–18 |
| Email | Transactional email delivery | **Gmail SMTP** (local/dev, App Password/OAuth 2.0) · **Brevo** (production primary, API key) · **Resend** (production failover, API key) | FR-NOTIF-01, FR-NOTIF-06–07, FR-NOTIF-14–15, FR-NOTIF-15a, FR-NOTIF-20–20a |
| SMS | SMS delivery | SMS gateway provider (API key / token authentication) | FR-NOTIF-01, FR-NOTIF-08 |
| WhatsApp | WhatsApp Business messaging | Meta WhatsApp Business Cloud API (**OAuth 2.0** authentication) | FR-NOTIF-01, FR-NOTIF-08 |
| Push | Push-to-device delivery | **Firebase Cloud Messaging (FCM)** on Android, iOS, macOS and Web; **authenticated WebSocket + OS-native local notifications** on Windows and Linux, where FCM is unsupported | FR-NOTIF-21–29, FR-NOTIF-30–34 |
| File Storage | Attachments (photos, voice) | **Supabase Storage** — private buckets, signed upload/download URLs | FR-1.1 (photos), FR-3.1 (voice), FR-DATA-18–24 |
| Async/Queue | Notification retry & delivery handling | Background task queue (Celery or RQ with Redis; FastAPI background tasks acceptable for Phase 1 only) | FR-NOTIF-04–05 |

---

## 3. System Actors and User Classes

| # | Actor | PRD Reference | Primary Goal |
|---|---|---|---|
| A1 | Reporter (Student/Staff) | §3.1 | Report an issue and stay informed |
| A2 | Facilities Coordinator (Operator) | §3.2 | Resolve assigned issues efficiently |
| A3 | Facilities Supervisor (Team Lead) | §3.3 | Monitor team workload, intervene when needed |
| A4 | Campus Operations Head (Manager) | §3.4 | View trends, resolution performance |
| A5 | System Administrator | §3.5 | Configure system structure and access |
| A6 (system) | AI Subsystem | §5 | Advisory automation layer (not a human actor, but a system actor with defined interfaces) |
Each actor has a distinct role-based view; no actor's default view exposes data or controls outside their defined scope (see NFR-SEC-01).

---

## 4. Phasing Strategy and Target Platforms

The PRD's MVP (§11) and Future Ideas (§12) sections are restructured here into three delivery phases for technical planning purposes. Phase boundaries are chosen so each phase is independently testable and demoable.

| Phase | Theme | Source in PRD |
|---|---|---|
| **Phase 1 (MVP)** | Core facilities issue lifecycle + foundational AI assistance, delivered on **web and desktop** | PRD §11 |
| **Phase 2** | **Mobile delivery (Android/iOS)** + expanded AI intelligence + academic issue category + deeper analytics | PRD §5 (advanced items), §12 (academic concerns) |
| **Phase 3** | Reach & scale: voice input, natural-language search, app-store distribution and device-native capability, multi-institution, historical pattern mining | PRD §12 |

### 4.1 Target Platform Matrix

All six targets are built from one Flutter codebase. The matrix below states **when each target becomes a supported deliverable**, not when code for it is first written — adaptive layout and platform abstractions are built from Phase 1 so that later targets require configuration and testing rather than rework.

| Target | Phase introduced | Primary actors | Notes |
|---|---|---|---|
| **Web** (Chrome, Edge, Firefox, Safari) | Phase 1 | All five roles | Primary access path; no install required, which matters for occasional Reporter use |
| **Windows desktop** | Phase 1 | Coordinator, Supervisor, Ops Head, Admin | Installed on campus operations workstations; large-screen, keyboard-driven workflows |
| **macOS desktop** | Phase 1 | Coordinator, Supervisor, Ops Head, Admin | Same build configuration as Windows; separate signing and notarization |
| **Linux desktop** | Phase 1 | Admin, technical staff | Lowest-priority desktop target; ship if the institution's workstations require it |
| **Android** | Phase 2 | Reporter, Coordinator | Coordinators work away from a desk — mobile is their primary field client |
| **iOS** | Phase 2 | Reporter, Coordinator | As Android; App Store review adds lead time to the release cycle |

**Rationale for this phasing.** Web and desktop share a large-screen layout and an identical input model (mouse and keyboard), so delivering them together costs little beyond per-platform packaging and signing. Mobile introduces genuinely new work — compact layout, touch targets, camera capture, notification permission flows, background/foreground lifecycle handling, and store review — which is why it is a phase of its own rather than a build-target checkbox. Deferring *all* mobile work to Phase 3, as v2.0 did, would have left Coordinators without a field client until the final phase, which conflicts with their primary goal in Section 3.

### 4.2 Cross-Platform Client Requirements

These requirements are cross-cutting: they apply to every functional requirement in Sections 5–8, on every target in Section 4.1.

#### Codebase and parity

- **FR-PLAT-01** All six targets shall be produced from a single Flutter codebase. Platform-specific behaviour shall be isolated behind narrow abstractions (a storage interface, a notification interface, a file-access interface) rather than distributed through feature code as conditional branches.
- **FR-PLAT-02** Every functional requirement in Sections 5–8 shall be available on every supported target for the actor to whom it applies, except where it depends on a device capability that the target does not provide (FR-PLAT-06). There shall be no "web-only" or "mobile-only" workflow.
- **FR-PLAT-03** The client shall detect available capabilities at runtime and shall hide or disable controls that the current platform cannot service, rather than presenting a control that fails when used.

#### Layout and input

- **FR-PLAT-04** The interface shall adapt across three layout classes driven by available width: **compact** (under 600 dp — phones), **medium** (600–1024 dp — tablets, small windows, split-screen), and **expanded** (over 1024 dp — desktop, laptop, maximised browser). Navigation shall render as a bottom bar in compact, a navigation rail in medium, and a persistent side navigation in expanded.
- **FR-PLAT-05** Layout class shall be a function of the application window's current size, not of the platform it is running on, so that a resized desktop window and a tablet resolve to the same layout. Desktop windows shall be resizable, with a defined minimum size below which the compact layout is used.
- **FR-PLAT-06** The client shall support all three input modalities: touch targets shall meet a minimum of 48 dp; pointer targets shall provide hover affordances; and all primary workflows shall be completable by keyboard alone on web and desktop, including keyboard shortcuts for Coordinator queue triage (open, assign, change status).
- **FR-PLAT-07** Data-dense views — the Coordinator queue (FR-1.9), the Supervisor workload view (FR-1.16), and Ops Head analytics (FR-1.21) — shall present as multi-column tables in the expanded layout and as stacked, prioritised cards in the compact layout. Columns shall not be horizontally scrolled off-screen on small viewports.

#### Device capabilities

- **FR-PLAT-08** Attachment capture (FR-1.1) shall use the capability appropriate to the target: direct camera capture on mobile; file picker on desktop and web; drag-and-drop onto the issue form on desktop and web. All paths shall converge on the same signed-upload flow (FR-DATA-21).
- **FR-PLAT-09** Voice input (FR-3.1) shall require microphone access; on targets where microphone access is unavailable or denied, the feature shall be hidden and text entry shall remain available without degradation.

#### Session, security and navigation

- **FR-PLAT-10** Authentication tokens shall be stored using each platform's secure credential store — Keychain on iOS/macOS, Keystore on Android, DPAPI on Windows, libsecret on Linux. On web, access tokens shall be held in memory only and the refresh token in an httpOnly, Secure, SameSite cookie; browser `localStorage` and `sessionStorage` shall never hold authentication material.
- **FR-PLAT-11** A single shared route table shall define navigation for all targets. Web routes shall be reflected in the address bar and shall support browser back/forward and direct URL entry; mobile shall register the equivalent routes as App Links (Android) and Universal Links (iOS); desktop shall register a custom URI scheme. A deep link to an issue reference shall resolve to the same destination on every target, subject to that user's role permissions.
- **FR-PLAT-12** Where a deep link targets a resource the user is not permitted to see, the client shall route to an access-denied state without disclosing whether the resource exists (supports NFR-SEC-01).

#### Offline and connectivity

- **FR-PLAT-13** Desktop and mobile targets shall maintain a local read cache of the user's own issues and their current status, so the application opens to meaningful content without network access. Web shall operate online-only in Phase 1.
- **FR-PLAT-14** State-changing actions shall require connectivity and shall not be queued for later replay in Phases 1–2, so that two actors cannot produce conflicting lifecycle transitions (FR-1.28) from stale offline state. The client shall clearly indicate offline status and disable state-changing controls rather than accepting input it cannot commit.

#### Packaging, distribution and versioning

- **FR-PLAT-15** All targets shall consume the same versioned API contract. No platform shall have a private endpoint, and an API change shall not require a coordinated simultaneous release of all six clients.
- **FR-PLAT-16** The backend shall advertise a minimum supported client version. A client below that version shall present a blocking upgrade prompt with a link to the appropriate update mechanism for its platform, rather than failing with unexplained errors.
- **FR-PLAT-17** Build artifacts shall be produced per target: a static bundle for web; MSIX for Windows; a signed and notarized DMG for macOS; AppImage or .deb for Linux; an Android App Bundle for Play; and an IPA for the App Store.
- **FR-PLAT-18** Desktop builds shall check for updates on launch and shall support in-place update, so that installed desktop clients do not drift behind the web client's version.

#### Quality

- **FR-PLAT-19** Continuous integration shall build every supported target on every merge to the main branch, so that a change which breaks one platform's build is caught at merge rather than at release.
- **FR-PLAT-20** The test plan shall define a device and browser matrix covering, at minimum: one browser of each engine family (Blink, Gecko, WebKit), one build of each desktop OS, one low-end and one current Android device, and one current iOS device. Acceptance for a phase shall require the matrix to pass, not a single reference environment.
- **FR-PLAT-21** Accessibility shall be verified per platform against that platform's screen reader — TalkBack on Android, VoiceOver on iOS and macOS, NVDA or Narrator on Windows, Orca on Linux, and the browser's accessibility tree on web (supports NFR-USAB-01).
- **FR-PLAT-22** Locale, timezone, and date/number formatting shall be derived from the operating system or browser settings on every target, since SLA windows (FR-1.15) and login alert timestamps (FR-NOTIF-09) are meaningless if rendered in the wrong timezone.

---

## 5. Phase 1 (MVP) — Functional Requirements

**Phase 1 Goal:** Deliver the complete facilities-issue lifecycle (Reported → Closed) for Reporters, Coordinators, Supervisors, Ops Head, and Admin, with foundational AI assistance (classification, urgency detection, dedup, drafting, SLA-risk alerts). Scope limited to facilities categories: AC, projector, wifi, lab equipment, library issues (per PRD §11).

### 5.1 Reporter Functions

- **FR-1.1** The system shall allow a Reporter to submit a new issue with: category (optional, AI-assisted), free-text description, location (building/room), and optional photo attachment(s).
- **FR-1.2** The system shall generate and display a unique reference number immediately upon submission.
- **FR-1.3** The system shall allow a Reporter to view a list of only their own submitted issues, with current status.
- **FR-1.4** The system shall allow a Reporter to view the full status history/timeline of an individual issue they submitted.
- **FR-1.5** The system shall allow a Reporter to respond to information requests raised by a Coordinator on their issue.
- **FR-1.6** The system shall allow a Reporter to confirm resolution ("Yes, it's fixed") or reject resolution ("No, still broken") when an issue is marked Resolved.
- **FR-1.7** Rejecting a resolution shall transition the issue to the **Reopened** state (see Appendix, §16).
- **FR-1.8** The system shall notify a Reporter (in-app, minimum) on every material status change to their issue.

### 5.2 Facilities Coordinator Functions

- **FR-1.9** The system shall display to a Coordinator a queue of issues assigned to them, sorted by urgency/SLA risk by default.
- **FR-1.10** The system shall display a queue of new/unassigned issues relevant to the Coordinator's category or building.
- **FR-1.11** The system shall display the AI's classification, urgency score, and any dedup/recurrence flags for each issue the Coordinator views.
- **FR-1.12** The system shall allow a Coordinator to accept, override, or dismiss any AI-suggested classification or urgency rating.
- **FR-1.13** The system shall allow a Coordinator to update issue status, add internal notes (not visible to Reporter), and send external updates (visible to Reporter).
- **FR-1.14** The system shall allow a Coordinator to mark an issue as **Resolved**, triggering a Reporter confirmation request.
- **FR-1.15** The system shall visually flag issues that are at risk of missing their expected resolution window.

### 5.3 Facilities Supervisor Functions

- **FR-1.16** The system shall display a Supervisor's team-wide workload view: issue counts per Coordinator, per status, per urgency.
- **FR-1.17** The system shall display issues that are Escalated or flagged as SLA-at-risk across the Supervisor's team.
- **FR-1.18** The system shall allow a Supervisor to reassign an issue from one Coordinator to another.
- **FR-1.19** The system shall allow a Supervisor to manually escalate or de-escalate an issue.
- **FR-1.20** The system shall surface AI-detected recurring-equipment patterns (e.g., same asset failing repeatedly) to the Supervisor.

### 5.4 Campus Operations Head Functions

- **FR-1.21** The system shall provide a dashboard of campus-wide issue volume, filterable by building, category, and date range.
- **FR-1.22** The system shall display average and median resolution time, overall and by category/building.
- **FR-1.23** The system shall display the AI-generated weekly plain-language summary (see FR-AI-09) to the Ops Head.

### 5.5 Administrator Functions

- **FR-1.24** The system shall allow an Admin to create, edit, and deactivate buildings, rooms, departments, and issue categories.
- **FR-1.25** The system shall allow an Admin to create, edit, and deactivate user accounts and assign roles (Reporter/Coordinator/Supervisor/Ops Head/Admin).
- **FR-1.26** The system shall allow an Admin to assign Coordinators to teams and teams to categories/buildings.
- **FR-1.27** The system shall maintain and expose an audit log of key administrative and workflow actions (who assigned what, who changed priority, who resolved/closed an issue) per PRD §9.

### 5.6 Core Lifecycle & Cross-Role Functions

- **FR-1.28** The system shall implement the issue lifecycle state machine defined in the Appendix (§16), including the states: Reported, Understood, Assigned, Investigating, Action Taken, Resolved, Confirmed, Closed, and the sub-states Waiting for Information, Escalated, Reopened.
- **FR-1.29** The system shall record a timestamped, immutable audit trail entry for every state transition, assignment change, and priority change.
- **FR-1.30** The system shall enforce that only a human actor (never the AI subsystem) can trigger the following transitions: merge two issues, close an issue, confirm resolution.

---

## 6. Phase 2 — Functional Requirements

**Phase 2 Goal:** Extend the platform's intelligence and category coverage, per PRD §5 (advanced AI capabilities) and PRD §12 ("Handling academic-related concerns").

### 6.1 Academic Issue Category

- **FR-2.1** The system shall support a new top-level issue category type: **Academic Concern** (e.g., exam grievances), distinct from Facilities issues.
- **FR-2.2** The system shall apply additional confidentiality handling to Academic Concern issues: visibility restricted to a designated academic-affairs role, separate from the general Facilities Coordinator pool.
- **FR-2.3** The system shall allow Admins to configure which categories are routed to which role group (Facilities vs. Academic Affairs).

### 6.2 Advanced AI-Assisted Functions

- **FR-2.4** The system shall suggest a previously successful resolution when a new issue is judged similar to a past resolved issue (per PRD §5.5), and shall display the suggestion with a confidence indicator and a link to the referenced past issue.
- **FR-2.5** The system shall maintain and display a continuously updated short-form summary for any issue with more than a configurable threshold of updates/messages (per PRD §5.8).
- **FR-2.6** The system shall detect recurring failures of the same asset or location over a rolling time window (e.g., 30/60/90 days) and generate a "recurring issue" flag with supporting history (per PRD §5.4), visible to Coordinators and Supervisors.
- **FR-2.7** The system shall allow Coordinators/Supervisors to convert a flagged recurring issue into a formal "needs permanent fix / replacement" recommendation record, viewable by the Ops Head.

### 6.3 Expanded Reporting & Management Views

- **FR-2.8** The system shall allow the Ops Head to drill down from summary metrics into the underlying list of issues that make up a metric (e.g., click "wifi complaints this week" to see the list).
- **FR-2.9** The system shall support category-level and building-level SLA configuration (different expected resolution windows for different issue types) by the Admin.
- **FR-2.10** The system shall allow the Ops Head to export analytics views (e.g., CSV) for offline institutional reporting.

---

## 7. Phase 3 — Functional Requirements

**Phase 3 Goal:** Reach, accessibility, and scale features described in PRD §12 as "future ideas."

- **FR-3.1** The system shall allow a Reporter to submit an issue using voice input, which is transcribed to text and processed through the same AI classification pipeline as typed input.
- **FR-3.2** The system shall provide a natural-language search interface allowing users to query issues using everyday phrasing (e.g., "show me all unresolved wifi issues from this month"), scoped to what that user's role is permitted to see.
- **FR-3.3** The mobile clients delivered in Phase 2 shall be distributed through the public application stores (Google Play and the Apple App Store) rather than by direct install, and shall add device-native capabilities that require store-level entitlements — background location for on-site check-in, and camera/microphone entitlements supporting FR-3.1. *(Revised in v3.0: first delivery of a mobile client moved to Phase 2 per Section 4.1; this requirement now covers store distribution and device-native capability only.)*
- **FR-3.4** The system shall support multi-institution/multi-tenant operation, with data, categories, buildings, and user accounts isolated per institution.
- **FR-3.5** The system shall support pattern analysis across multi-year historical data (e.g., seasonal spikes, long-term equipment failure trends) and surface these in the Ops Head analytics view.

---

## 8. AI Subsystem Requirements (Cross-Phase)

These requirements govern the AI subsystem's behavior across all phases and directly operationalize PRD §5 ("How AI Helps") and §8 ("Keeping Humans in Control"). They are grouped separately because they apply across multiple actor-facing features.

| ID | Requirement |
|---|---|
| FR-AI-01 | The AI subsystem shall analyze a submitted issue's description and propose: (a) a likely category, (b) an urgency estimate, (c) a list of missing information items, if any (PRD §5.1). |
| FR-AI-02 | The AI subsystem shall incorporate contextual timing signals (e.g., stated exam time, class schedule) into its urgency estimate, not category alone (PRD §5.2). |
| FR-AI-03 | The AI subsystem shall detect when multiple issues submitted within a configurable time/location window likely describe the same underlying problem and shall propose grouping them, without auto-merging (PRD §5.3, §8). |
| FR-AI-04 | The AI subsystem shall detect recurring failures of the same equipment/location over time and raise a recurrence flag (PRD §5.4). |
| FR-AI-05 | The AI subsystem shall retrieve and suggest previously successful resolutions for similar past issues (PRD §5.5). |
| FR-AI-06 | The AI subsystem shall draft, but never send without explicit human action, status-update messages to Reporters (PRD §5.6). |
| FR-AI-07 | The AI subsystem shall identify issues at risk of missing their expected resolution window and raise an early warning to the responsible Coordinator/Supervisor (PRD §5.7). |
| FR-AI-08 | The AI subsystem shall maintain a running plain-language summary for long-running issue threads (PRD §5.8). |
| FR-AI-09 | The AI subsystem shall generate a plain-language weekly summary report for campus leadership (PRD §5.9). |
| FR-AI-10 | Every AI-generated classification, score, or suggestion shall be visually distinguished from human-entered/confirmed data and shall express uncertainty explicitly rather than presenting a guess as fact (PRD §8). |
| FR-AI-11 | The AI subsystem shall never autonomously merge two issues or close an issue; these actions require explicit human confirmation (PRD §8). |
| FR-AI-12 | If the AI subsystem is unavailable, all core workflow functions (FR-1.x) shall continue to operate without AI-derived fields, with the UI indicating "AI insights unavailable" rather than failing (PRD §8). |

### 8.1 AI Recommendations

The requirements above cover per-issue AI assistance. This subsection specifies the **AI Recommendations** capability: periodic, aggregate-level suggestions addressed to Supervisors, Ops Heads, and Admins about where to act next. Recommendations are advisory, subject to the same human-in-the-loop constraint as all other AI output (FR-AI-11).

| ID | Requirement |
|---|---|
| FR-AI-13 | The system shall generate **recommendations** in three classes: (a) *resolution recommendations* — a suggested fix for an open issue, derived from similar resolved issues (extends FR-AI-05); (b) *preventive-maintenance recommendations* — an asset or location that recurrence data suggests should be serviced or replaced rather than repeatedly repaired (extends FR-AI-04, FR-2.7); (c) *resourcing recommendations* — a category, building, or shift where SLA breaches cluster and staffing or routing may need adjustment. |
| FR-AI-14 | A deterministic analytics layer shall compute the supporting evidence — issue counts, recurrence intervals, mean and median resolution times, SLA breach rates, reopen rates, workload distribution — **before** any LLM call; the LLM shall receive these computed aggregates and shall generate only the explanatory narrative and the suggested action. |
| FR-AI-15 | Reporter identities, contact details, and free-text internal notes shall be excluded from the data passed to the LLM for recommendation generation; recommendations shall be derived from de-identified aggregates and structured issue metadata only (supports NFR-SEC-04). |
| FR-AI-16 | Every recommendation shall be persisted together with the evidence snapshot that produced it, the generating model and prompt version, and a confidence indicator, so that any recommendation shown to a user can be explained and audited after the fact. |
| FR-AI-17 | Recommendations shall be generated on a configurable schedule (default: weekly, aligned with the leadership summary of FR-AI-09) and on demand, subject to a rate limit per user per day. |
| FR-AI-18 | A recipient shall be able to accept, dismiss, or act on a recommendation; the outcome shall be recorded as a `human_decision` (consistent with the `AIInsight` model) and a dismissed recommendation shall not regenerate for a configurable suppression window (default 30 days). |
| FR-AI-19 | The system shall suppress recommendations where the underlying evidence is below a configurable sufficiency threshold (for example, fewer than a minimum number of issues or less than a minimum observation window) and shall display an explicit "insufficient data" state rather than a low-confidence guess (supports FR-AI-10). |
| FR-AI-20 | LLM calls supporting recommendation generation shall be subject to a timeout and an environment-level token budget; on exhaustion of either, the system shall fall back to displaying the deterministic evidence from FR-AI-14 without narrative, rather than failing the view (consistent with FR-AI-12, NFR-AVAIL-02). |
---

## 9. Data Persistence & Database Migration Requirements

This section defines requirements for how the system stores data and manages changes to its database structure over time, supporting the phased delivery approach (Section 4).

### 9.1 ORM (Object-Relational Mapping) Requirements

**Selected tooling:** SQLAlchemy 2.0 (async), integrated with FastAPI via Pydantic/SQLModel-style schemas, running against **Supabase (managed PostgreSQL)** (see Section 2.7).

- **FR-DATA-01** The system shall access all persistent data (issues, users, attachments, updates, audit logs, AI insights, notifications) through the ORM (SQLAlchemy) rather than hand-written raw queries embedded throughout application code.
- **FR-DATA-02** The ORM layer shall enforce the entity relationships defined in the Conceptual Data Model (Section 12) at the application level, in addition to database-level constraints.
- **FR-DATA-03** The ORM layer shall support parameterized queries only, so that no user-supplied input (issue description, notes, search terms) can be interpreted as executable database code.
- **FR-DATA-04** The ORM configuration shall be environment-aware (development / test / staging / production), pointing to the correct Supabase project per environment without code changes.
- **FR-DATA-04a** The ORM shall connect to Supabase through its pooled connection string, with the connection-pool size configured to stay within the connection limit of the Supabase plan in use, so that concurrent background jobs cannot exhaust the pool and block user-facing requests.
- **FR-DATA-04b** Row Level Security shall be enabled on every user-scoped table in Supabase and shall express the visibility rules of Section 12.3, so that the database independently enforces the access restrictions of NFR-SEC-01 and NFR-SEC-02 even if an application-layer check is missed.
- **FR-DATA-04c** The Supabase service-role key shall be used only by the FastAPI backend and shall never be embedded in, or reachable from, the Flutter client.

### 9.2 Database Migration Requirements

**Selected tooling:** Alembic (the standard migration tool for SQLAlchemy/FastAPI projects).

- **FR-DATA-05** The system shall manage all database schema changes (new tables, new columns, new relationships, index changes) through Alembic, rather than manual/ad-hoc schema edits.
- **FR-DATA-06** Every schema change shall be captured as a versioned, timestamped migration file, checked into source control alongside the corresponding application code change.
- **FR-DATA-07** The migration tool shall support forward migration (apply) and rollback (revert) for every migration, so a faulty schema change can be safely undone without data loss to unaffected tables.
- **FR-DATA-08** The system shall track which migrations have been applied to a given environment (e.g., via a migration-history table) and shall refuse to start the application against a database whose schema is behind the version the application code expects.
- **FR-DATA-09** Migrations required to introduce Phase 2 entities (e.g., Academic Concern category, recurrence patterns) and Phase 3 entities (e.g., multi-institution tenancy fields) shall be additive and backward-compatible wherever possible, so existing Phase 1 data is not disrupted.
- **FR-DATA-10** Migration execution (apply/rollback) shall be restricted to Administrator-level deployment permissions and shall be logged in the system audit trail (NFR-AUDIT-01).

### 9.3 Database Migration Automation Requirements

These requirements automate the migration process defined in Section 9.2, so that schema changes are applied by the deployment pipeline rather than by a person running commands against a live database.

- **FR-DATA-11** Migration files shall be drafted using Alembic's autogenerate facility, and every autogenerated file shall be reviewed and, where necessary, hand-corrected before merge; autogenerated output shall not be merged unreviewed.
- **FR-DATA-12** The continuous-integration pipeline shall fail a pull request if the ORM models and the latest migration are out of step — that is, if running autogenerate against a freshly migrated database produces a non-empty diff (schema drift detection).
- **FR-DATA-13** The continuous-integration pipeline shall fail a pull request that introduces a second Alembic head, so that two developers' migrations cannot silently diverge.
- **FR-DATA-14** Migrations shall be applied by the deployment pipeline as a **separate pre-deploy step**, executed before the new application version starts serving traffic; a failed migration shall abort the release rather than allowing a partially migrated system to go live.
- **FR-DATA-15** Each migration shall be applied against a disposable copy of the staging schema in CI and shall be verified to apply and roll back cleanly before it is eligible for production (supports NFR-DATA-02).
- **FR-DATA-16** Schema changes shall follow an expand-and-contract sequence: a column shall first be added as nullable and backfilled, the application shall be released, and only a subsequent migration shall enforce constraints or drop the superseded column — so that the previous application version remains operable during a rollout or rollback.
- **FR-DATA-17** A Supabase backup checkpoint shall be recorded immediately before production migrations execute, and destructive operations (`DROP TABLE`, `DROP COLUMN`, type narrowing) shall require explicit reviewer approval recorded on the pull request.

### 9.4 File Storage Requirements

**Selected tooling:** Supabase Storage (see Section 2.7).

- **FR-DATA-18** Issue attachments — photographs from Phase 1 (FR-1.1) and voice recordings from Phase 3 (FR-3.1) — shall be stored in **Supabase Storage**, not in the relational database; the `IssueAttachment` record shall hold only the storage path and file metadata.
- **FR-DATA-19** Attachment buckets shall be **private**. No attachment shall be served from a public URL.
- **FR-DATA-20** Downloads shall be served through short-lived signed URLs issued by the backend (default validity 60 minutes) only after the backend has verified that the requesting user's role permits access to the parent issue (NFR-SEC-01, NFR-SEC-02).
- **FR-DATA-21** Uploads shall use a backend-issued signed upload URL, so that file bytes travel directly from the Flutter client to Supabase Storage without passing through the API server.
- **FR-DATA-22** The backend shall validate file type and size before issuing an upload URL. Phase 1 accepted types: `jpg`, `jpeg`, `png`, `webp`, `pdf`, maximum 10 MB per file. Phase 3 adds accepted audio types for voice input.
- **FR-DATA-23** Attachment storage paths shall be namespaced as `attachments/{issue_id}/{attachment_id}.{ext}`, and storage bucket policies shall deny any access path not mediated by a backend-issued signed URL.
- **FR-DATA-24** Deleting or anonymising an issue shall soft-delete its attachments; a scheduled job shall permanently purge objects soft-deleted more than an Admin-configurable retention period (default 30 days) earlier.

## 10. Automated Communications Requirements

This section defines requirements for the multi-channel automated notification system (Email, SMS, WhatsApp, in-app), including login alerts and welcome messaging, as introduced in PRD Section 13.

**Selected tooling:** Gmail SMTP for Email in local/development environments, Brevo for Email in production with Resend as automatic failover; a dedicated SMS gateway provider for SMS; the Meta WhatsApp Business Cloud API for WhatsApp; Firebase Cloud Messaging for push-to-device delivery (see Section 2.7 and Section 10.5 for authentication details).

### 10.1 Channel & Delivery Requirements

- **FR-NOTIF-01** The system shall support sending automated notifications through five channels: in-app, **push-to-device (FCM)**, Email (via Gmail SMTP in local/development, and Brevo in production with Resend failover), SMS (via the selected SMS gateway), and WhatsApp (via the WhatsApp Business Cloud API).
- **FR-NOTIF-01a** All outbound channels shall sit behind a single notification orchestrator, which accepts a domain event (issue assigned, status changed, login succeeded, account created) and fans it out to the channels enabled for that user and event type; feature code shall never call a gateway SDK directly.
- **FR-NOTIF-01b** Each channel shall be implemented as an interchangeable provider adapter behind a common interface, so that a provider can be replaced by configuration without changes to calling code (see FR-NOTIF-20).
- **FR-NOTIF-01c** Every notification shall carry an idempotency key derived from `{user_id}:{event_type}:{related_entity_id}:{channel}`; a send matching an already-recorded key shall be suppressed and logged as suppressed rather than dispatched a second time.
- **FR-NOTIF-02** The system shall maintain, per user, one or more registered contact points (email address, mobile number) and associated device/session records used for delivering notifications.
- **FR-NOTIF-03** Each outbound notification shall be generated from a predefined, role-appropriate template (e.g., welcome message, login alert, issue status update), populated with the relevant issue/user data, consistent with the drafting behavior described for AI-assisted messages (FR-AI-06).
- **FR-NOTIF-04** The system shall record a delivery log entry for every notification attempt (channel, recipient, template, status: sent/failed/delivered where the gateway supports delivery receipts, timestamp).
- **FR-NOTIF-05** If a notification fails to send on a given channel, the system shall retry according to a configurable retry policy and shall not silently drop the notification without a logged failure.
- **FR-NOTIF-05a** All outbound sends shall be dispatched through the background task queue and shall never execute inline on the request thread, so that a slow or unavailable gateway cannot delay a user-facing response (supports NFR-PERF-01, NFR-NOTIF-02).
- **FR-NOTIF-05b** The retry policy shall use exponential backoff (reference schedule: 5 s, 30 s, 2 min, 10 min, 1 h) with a bounded maximum attempt count, after which the notification shall be marked permanently failed and surfaced in the delivery log for Admin review.

### 10.2 Welcome Email

- **FR-NOTIF-06** The system shall automatically send a welcome email to a user's registered email address immediately upon account creation, or upon that user's first successful login if the account was pre-provisioned by an Admin.
- **FR-NOTIF-07** The welcome email shall not be sent more than once per account unless explicitly re-triggered by an Administrator.
- **FR-NOTIF-07a** The welcome email shall be queued within a short bounded time of the triggering event and shall not block the account-creation or login response.
- **FR-NOTIF-07b** The welcome email shall contain, at minimum: the recipient's name, their assigned role, a brief orientation to the actions available to that role, and a support contact; the content shall be role-aware, since a Reporter and a Coordinator require different first steps.
- **FR-NOTIF-07c** Uniqueness under FR-NOTIF-07 shall be enforced by the idempotency mechanism of FR-NOTIF-01c, so that repeated logins by a pre-provisioned user cannot produce repeated welcome emails.

### 10.3 Login Notifications

- **FR-NOTIF-08** The system shall automatically send a login notification — via Email, SMS, and/or WhatsApp, according to the user's configured preference (FR-NOTIF-11) — to a user's registered devices/contact points each time that user successfully logs in.
- **FR-NOTIF-09** The login notification shall include, at minimum, the approximate time of login, so the user can recognize whether the login was their own.
- **FR-NOTIF-10** Login notifications shall be classified as a security-relevant notification and shall be sent regardless of a user's non-critical notification channel preferences (see FR-NOTIF-11), consistent with PRD Section 13.

### 10.4 Issue & Status Notifications, and User Preferences

- **FR-NOTIF-11** The system shall allow a user to select their preferred channel(s) — Email, SMS, WhatsApp, and/or in-app only — for non-critical notifications (e.g., issue assigned, updated, resolved, waiting for confirmation, reopened), independent of the always-on channels used for login alerts and the welcome email.
- **FR-NOTIF-12** The system shall send issue/status notifications through the user's selected channel(s) in addition to the corresponding in-app notification, so in-app history is always complete regardless of external channel preference.
- **FR-NOTIF-13** The AI-drafted status update content (FR-AI-06) shall be reusable as the message body for Email/SMS/WhatsApp/push notifications once approved and sent by a Coordinator, avoiding duplicate message-composition work.
- **FR-NOTIF-13a** The system shall support Admin-configurable quiet hours (default 22:00–08:00 in the user's local timezone) during which non-critical push, SMS, and WhatsApp messages are deferred to the next permitted window; in-app notifications and security-relevant notifications (FR-NOTIF-10) shall be exempt.
- **FR-NOTIF-13b** The system shall enforce an Admin-configurable per-user daily cap on SMS and WhatsApp sends, so that a notification storm on a high-traffic issue cannot generate unbounded gateway cost.

### 10.5 Authentication to Third-Party Communication Gateways

The system integrates with external communication providers that differ **by environment** (email) and **by channel** (SMS, WhatsApp), each with its own authentication model. This distinction matters for credential storage, token refresh handling, and security review.

| Gateway | Environment | Authentication Method | Requirement |
|---|---|---|---|
| **Gmail SMTP** (Email) | Local / Development | App Password (Gmail account with 2-Step Verification enabled) or OAuth 2.0 (XOAUTH2) | **FR-NOTIF-14** The system shall authenticate to Gmail's SMTP server using an App Password or OAuth 2.0 (XOAUTH2) credential, stored as a server-side secret, for sending email in local/development environments only. |
| **Brevo** (Email) | Production | Static API key | **FR-NOTIF-15** The system shall authenticate to Brevo using a server-side API key, stored as a secret (never in source control or client-side code), for sending all email in the production environment. |
| **Resend** (Email) | Production (failover) | Static API key | **FR-NOTIF-15a** The system shall authenticate to Resend using a server-side API key, stored as a secret, and shall use Resend only as the automatic failover provider when the production primary (Brevo) is unavailable. |
| **Firebase Cloud Messaging** (Push) | All environments | Service-account credential (OAuth 2.0 server-to-server, short-lived access token) | **FR-NOTIF-17a** The system shall authenticate to FCM using a Firebase service-account credential held server-side, exchanging it for short-lived access tokens; the credential shall never be shipped in the Flutter binary. |
| **SMS gateway** | All environments | API key / Account SID + Auth Token | **FR-NOTIF-16** The system shall authenticate to the SMS gateway using its provider-issued API key/token, stored and used under the same server-side-only constraint as FR-NOTIF-14/15. |
| **WhatsApp Business Cloud API** (Meta) | All environments | **OAuth 2.0** access token | **FR-NOTIF-17** The system shall obtain and use a Meta OAuth 2.0 System User access token to authenticate all WhatsApp Business Cloud API calls, per Meta's mandatory authentication requirement for this API. |
| — | — | Token lifecycle | **FR-NOTIF-18** The system shall monitor the WhatsApp OAuth access token's expiry and refresh/rotate it before expiry, so scheduled and event-triggered WhatsApp notifications (e.g., login alerts) are not silently blocked by an expired token. |
| — | — | Credential isolation | **FR-NOTIF-19** All gateway credentials (Gmail App Password/OAuth token, Brevo API key, SMS gateway token, WhatsApp OAuth credentials/access token) shall be stored in a secrets manager or environment-level secret store, accessible only to the backend service, and shall never be exposed to the Flutter front end. |
| — | — | Provider switching | **FR-NOTIF-20** The email-sending component shall select the active provider (Gmail SMTP vs. Brevo vs. Resend) based on deployment environment configuration (an `EMAIL_PROVIDER` setting resolved from `ENVIRONMENT`: `smtp` for `local`/`development`, `brevo` for `production`), with no code changes required to switch between them. |
| — | — | Automatic failover | **FR-NOTIF-20a** If the primary production email provider returns a server-side error or times out, the system shall retry the send once through the configured failover provider (`EMAIL_FALLBACK_PROVIDER`, default `resend`) before applying the standard retry policy of FR-NOTIF-05b, and shall record in the delivery log which provider ultimately delivered the message. |
| — | — | Delivery feedback | **FR-NOTIF-20b** The system shall expose signed webhook endpoints for Brevo, Resend, the SMS gateway, and the WhatsApp Cloud API to report delivery, bounce, and complaint events, and shall update the corresponding `NotificationLog` entry accordingly. Unsigned or signature-invalid webhook requests shall be rejected. |
| — | — | Suppression | **FR-NOTIF-20c** An email address producing a hard bounce or a spam complaint shall be marked suppressed, and subsequent non-security email to that address shall be skipped and logged as suppressed rather than repeatedly attempted. |

**Clarification:** OAuth 2.0 is required only for the WhatsApp Business Cloud API (Meta's mandatory authentication method), for Firebase Cloud Messaging (service-account token exchange), and, optionally, for Gmail SMTP in local/development if an App Password is not used. Brevo, Resend, and the SMS gateway use simpler static API-key/token authentication — no OAuth flow is required for those three.

### 10.6 Push Notifications and Device Registration

This subsection operationalizes the requirement that notifications reach a user's devices automatically while that user is logged in, rather than waiting to be discovered in the in-app inbox.

- **FR-NOTIF-21** Upon successful login, the Flutter client shall request notification permission (where the platform requires it) and shall register the device's FCM registration token with the backend.
- **FR-NOTIF-22** A device registration record (`UserDevice`, Section 12.1) shall capture: user reference, FCM token, platform, application version, device model, locale, timezone, last-seen timestamp, and active flag.
- **FR-NOTIF-23** A user may have multiple concurrently active devices; a push notification addressed to that user shall be delivered to **all** of their active devices.
- **FR-NOTIF-24** The client shall re-register the token whenever FCM rotates it, so that a rotated token does not silently end delivery to that device.
- **FR-NOTIF-25** On logout, the device record shall be marked inactive and excluded from subsequent delivery; the same shall apply after an Admin-configurable inactivity period (default 90 days).
- **FR-NOTIF-26** An FCM response indicating an unregistered or invalid token shall automatically deactivate that device record, so that dead tokens are not retried indefinitely.
- **FR-NOTIF-27** Push payloads shall carry a deep-link target (for example, an issue reference) so that acting on the notification opens the relevant screen directly, and shall never contain internal notes or another reporter's issue data (NFR-SEC-01, NFR-SEC-02).
- **FR-NOTIF-28** On login, the client shall retrieve any notifications generated while it was offline and render them in the in-app notification centre, so that the in-app history remains complete irrespective of push delivery success (consistent with FR-NOTIF-12).
- **FR-NOTIF-29** Notification permission shall be requested with an in-app explanation of its purpose, presented after the first successful login rather than on first application launch, so that a denied permission does not permanently disable the channel for a user who has not yet understood it.

### 10.6a Push Transport by Platform

Push delivery is not uniform across the six targets of Section 4.1. **Firebase Cloud Messaging supports Android, iOS, macOS and Web, but not Windows or Linux.** The requirements below define a single logical push channel with two underlying transports, so that feature code remains platform-agnostic.

| Target | Transport | Constraint |
|---|---|---|
| Android | FCM | Requires runtime notification permission on Android 13+ |
| iOS | FCM over APNs | Requires an APNs key and explicit user permission |
| macOS | FCM over APNs | Requires app notarization and user permission |
| Web | FCM via service worker (Web Push) | Requires HTTPS, a registered service worker, and a user gesture to prompt; Safari support is narrower than Chromium's |
| Windows | **Authenticated WebSocket + OS-native local notification** | No FCM support; delivered only while the application is running |
| Linux | **Authenticated WebSocket + OS-native local notification** | As Windows; notification presentation varies by desktop environment |

- **FR-NOTIF-30** The notification orchestrator (FR-NOTIF-01a) shall address a logical *device*, not a transport. The transport — FCM or WebSocket — shall be selected from the device record and shall not be visible to the feature code that raises the notification.
- **FR-NOTIF-31** The `UserDevice` record shall store the transport type and, for WebSocket devices, the connection identifier in place of an FCM token; `fcm_token` shall therefore be nullable.
- **FR-NOTIF-32** Windows and Linux clients shall maintain an authenticated WebSocket to the backend while running, and shall surface received notifications through the operating system's native notification facility. On reconnection, the client shall retrieve any notifications raised while it was disconnected (consistent with FR-NOTIF-28).
- **FR-NOTIF-33** Because Windows and Linux receive nothing while the application is closed, notifications classified as security-relevant (FR-NOTIF-10) or SLA-critical shall not rely on push alone on those targets; they shall also dispatch on an always-available channel (email, and SMS/WhatsApp where the user has enabled it).
- **FR-NOTIF-34** Where a user has several active devices and acknowledges a notification on one, the orchestrator shall suppress any not-yet-sent escalation to SMS or WhatsApp for that same event, so that a user working across web, desktop and phone is not billed-for and interrupted three times over one issue (supports FR-NOTIF-13b).

## 11. External Interface Requirements

### 11.1 User Interfaces

- Role-based dashboards for each of the five actor types (Section 3), rendered based on authenticated role, presented through a single adaptive interface across web, desktop, and mobile (Section 4.2).
- Layout, navigation pattern, and data density adapt to the active layout class (FR-PLAT-04) while preserving identical functionality and identical terminology across targets, so that a Coordinator moving between a workstation and a phone is not relearning the product.
- Consistent notification center showing status changes, information requests, and AI-flagged risks relevant to the logged-in user's role, present on every target and reconciled on login (FR-NOTIF-28).

### 11.2 Hardware Interfaces

- **Camera / file system:** required from Phase 1 for photo attachments — via the device camera on mobile, and via file picker or drag-and-drop on desktop and web (FR-PLAT-08).
- **Microphone:** required from Phase 3 for voice input (FR-3.1, FR-PLAT-09); absent or denied microphone access shall degrade gracefully to text entry.
- **Display:** the client shall render correctly from a 320 dp-wide phone viewport up to a maximised desktop window, per the layout classes of FR-PLAT-04.
- **Keyboard and pointer:** required for the desktop and web targets; all primary workflows shall be keyboard-completable (FR-PLAT-06).
- **Operating system notification facility:** used for local notification presentation on the Windows and Linux desktop targets (FR-NOTIF-32).

### 11.3 Software Interfaces

- **Authentication interface (users):** institutional SSO or equivalent identity provider (or local account fallback) — governs how Reporters/Coordinators/Supervisors/Ops Head/Admin log in to the Flutter app.
- **AI/LLM service interface:** request/response API used by the AI subsystem for classification, summarization, similarity search, and text generation tasks.
- **Email gateway interface:** Gmail SMTP in local/development (App Password or OAuth 2.0, FR-NOTIF-14), Brevo API in production (server-side API key, FR-NOTIF-15), and Resend API as production failover (server-side API key, FR-NOTIF-15a), used for welcome emails and email-channel issue/status updates; provider selection is environment-driven (FR-NOTIF-20) with automatic failover (FR-NOTIF-20a) and signed delivery webhooks (FR-NOTIF-20b).
- **SMS gateway interface:** SMS provider API, authenticated via API key/token (FR-NOTIF-15), used for SMS-channel login alerts and issue/status updates.
- **WhatsApp gateway interface:** Meta WhatsApp Business Cloud API, authenticated via OAuth 2.0 access token (FR-NOTIF-16–17), used for WhatsApp-channel login alerts and issue/status updates.
- **Push gateway interface:** Firebase Cloud Messaging, authenticated via a server-side Firebase service-account credential (FR-NOTIF-17a), used to deliver notifications to a user's registered, logged-in devices (Section 10.6).
- **Notification interface (in-app):** delivered directly by the FastAPI backend to the Flutter client (Phase 1 onward), alongside the four external gateways above (per Section 10).
- **File storage interface:** **Supabase Storage**, accessed by the backend using the service-role credential to issue short-lived signed upload and download URLs; the Flutter client transfers file bytes directly to and from Supabase Storage using those signed URLs and never holds a storage credential (Section 9.4). Used for photo attachments (Phase 1) and voice recordings (Phase 3).
- **Database interface:** **Supabase (managed PostgreSQL)**, accessed exclusively through the ORM tool (SQLAlchemy, Section 9.1) over the pooled connection string; direct/raw database access by application code is out of scope, and the Supabase service-role key is never exposed to the client (FR-DATA-04c).
- **Migration interface:** the deployment pipeline executes Alembic against the environment's Supabase database as a gated pre-deploy step (Section 9.3).

### 11.4 Communications Interfaces

- HTTPS for all client-server communication.
- Internal service-to-service calls (backend ↔ AI subsystem) authenticated and access-scoped.

---

## 12. Data Requirements / Conceptual Data Model

### 12.1 Core Entities

| Entity | Key Attributes (illustrative, not exhaustive) |
|---|---|
| **User** | user_id, name, role, department, contact info, status (active/inactive) |
| **Issue** | issue_id, reference_number, category, description, location (building/room), status, urgency (human-confirmed and AI-suggested), reporter_id, assigned_coordinator_id, created_at, expected_resolution_at, resolved_at, closed_at |
| **IssueAttachment** | attachment_id, issue_id, type (photo/voice — voice from Phase 3), storage_bucket, storage_path, mime_type, size_bytes, uploaded_by, uploaded_at, deleted_at |
| **IssueUpdate** | update_id, issue_id, author_id, visibility (internal/external), message, created_at |
| **IssueStateHistory** | history_id, issue_id, from_state, to_state, changed_by, changed_at |
| **IssueGroup (Dedup)** | group_id, primary_issue_id, member_issue_ids[], created_by (human confirmation), created_at |
| **RecurrencePattern** | pattern_id, asset/location_reference, related_issue_ids[], detected_at, status (flagged/confirmed/dismissed) |
| **Building / Room / Department / Category** | master data managed by Admin |
| **Team** | team_id, name, member_user_ids[], covered_categories[], covered_buildings[] |
| **AuditLogEntry** | log_id, actor_id, action, target_entity, target_id, timestamp |
| **AIInsight** | insight_id, issue_id, type (classification/urgency/dedup/recurrence/suggested-resolution/summary), payload, confidence, human_decision (accepted/overridden/dismissed), decided_by, decided_at |
| **UserContactChannel** | channel_id, user_id, type (email/sms/whatsapp), address_or_number, is_verified, is_active |
| **NotificationPreference** | preference_id, user_id, category (login_alert/welcome/issue_update), channel (email/sms/whatsapp/in_app), enabled |
| **NotificationLog** | notification_id, user_id, channel, template, provider, provider_message_id, related_issue_id (nullable), status (queued/sent/delivered/failed/suppressed), attempt_count, idempotency_key, error_detail, sent_at |
| **UserDevice** | device_id, user_id, fcm_token, platform (android/ios/web), app_version, device_model, locale, timezone, last_seen_at, is_active, registered_at |
| **Recommendation** | recommendation_id, type (resolution/preventive/resourcing), scope_reference (issue/asset/building/category), title, body, suggested_action, evidence_snapshot, confidence, model_version, human_decision (accepted/dismissed/acted), decided_by, decided_at, generated_at |
| **SchemaMigration** | migration_id, version, description, applied_at, applied_by |
### 12.2 Key Relationships

- One **User** (Reporter) submits many **Issues**.
- One **Issue** has many **IssueUpdates**, one **IssueStateHistory** trail, zero-or-more **IssueAttachments**, and zero-or-more **AIInsights**.
- Many **Issues** may belong to one **IssueGroup** (dedup) — creation always tied to a confirming human `changed_by`/`created_by` user.
- One **Team** covers many **Categories** and **Buildings**; one **Coordinator** belongs to one (or more, if configured) **Team**.
- One **User** has many **UserContactChannels** (email/SMS/WhatsApp) and many **NotificationPreferences**; every notification sent produces one **NotificationLog** entry.
- One **User** has zero-or-more **UserDevices**; a push notification to that user produces one **NotificationLog** entry per targeted active device.
- One **Issue** has zero-or-more **IssueAttachments**, each of which references exactly one object in **Supabase Storage**; the database stores the path, never the file bytes.
- One **Recommendation** references a scope (an **Issue**, an asset/location, a **Category**, or a **Building**) and carries the evidence snapshot that produced it; acting on a recommendation records a `human_decision`, consistent with the **AIInsight** pattern.

### 12.3 Data Visibility Rules (feeds NFR-SEC-01/02)

- A Reporter may query only `Issue` records where `reporter_id = self`.
- `IssueUpdate.visibility = internal` records are excluded from any Reporter-facing query or export.
- Academic Concern category issues (Phase 2) are excluded from the general Facilities Coordinator's issue queue by default routing rules.
- A user's `UserContactChannel` values (phone number, email) are visible only to that user and to Admins performing account management; they are never exposed in issue exports or analytics.
- A user's `UserDevice` records are visible only to that user (as an active-sessions list) and to Admins performing account management; FCM tokens are never returned in any other API response.
- Attachment access is mediated by signed URL only; a Reporter may obtain a signed URL only for attachments on issues where `reporter_id = self`, and internal-visibility attachments are excluded from Reporter-facing signed-URL issuance (FR-DATA-20).
- `Recommendation` records derived from campus-wide aggregates are visible to Supervisors, Ops Heads, and Admins; they shall not expose individual reporter identities (FR-AI-15).

---

## 13. Non-Functional Requirements

| ID | Category | Requirement |
|---|---|---|
| NFR-SEC-01 | Security / Access Control | A Reporter shall never be able to view another Reporter's issues through any system interface, including search or notification payloads. |
| NFR-SEC-02 | Security / Access Control | Internal Coordinator/Supervisor notes shall never be exposed to Reporter-facing views, exports, or notifications. |
| NFR-SEC-03 | Security | All state-changing actions shall be authenticated and authorized against the acting user's role before execution. |
| NFR-AUDIT-01 | Auditability | Every assignment change, priority/urgency change, status transition, and resolution/closure action shall be logged with actor, timestamp, and before/after values (PRD §9). |
| NFR-AVAIL-01 | Availability | The core issue workflow (submit, view, update, resolve, confirm) shall have a target uptime independent of AI subsystem uptime. |
| NFR-AVAIL-02 | Availability / Degradation | If the AI subsystem becomes unavailable or times out, the platform shall continue to accept, route, and update issues through manual/human workflows without blocking (PRD §8). |
| NFR-PERF-01 | Performance | Issue submission shall return a reference number to the Reporter within a short, bounded response time, independent of AI processing completion (AI insights may populate asynchronously). |
| NFR-PERF-02 | Performance | Dashboards (Coordinator queue, Supervisor workload view, Ops Head analytics) shall load within an acceptable response time under expected concurrent-user load for a single campus. |
| NFR-USAB-01 | Usability | Each role's default view shall surface only information relevant to that role, avoiding a "one-size-fits-all" screen (PRD §4). |
| NFR-USAB-02 | Usability | AI-derived content shall be visually distinguishable from human-confirmed content at all times (PRD §8, FR-AI-10). |
| NFR-RELI-01 | Reliability | No issue shall be permitted to remain indefinitely in a state with no owner and no visible next step (supports PRD §10, item 8). |
| NFR-SCAL-01 | Scalability | The data model and access-control design shall accommodate future multi-institution isolation (Phase 3, FR-3.4) without requiring redesign of core entities. |
| NFR-MAINT-01 | Maintainability | Category, building, department, and role configuration shall be data-driven (Admin-configurable) rather than hardcoded, to support institution-specific structures. |
| NFR-COMPAT-01 | Compatibility | The application shall function on all six supported targets (Section 4.1): current major browser versions on web; Windows 10/11, macOS 12+, and supported Linux distributions on desktop; Android 8.0+ and iOS 15+ on mobile. |
| NFR-COMPAT-02 | Compatibility / Parity | A defect shall be considered platform-specific, and tracked as such, only after it has been reproduced on one target and confirmed absent on another; parity regressions between targets shall be treated with the same severity as functional defects (supports FR-PLAT-02). |
| NFR-COMPAT-03 | Compatibility / Versioning | The backend shall remain compatible with the immediately preceding released client version on every target, because store review and desktop update adoption make simultaneous client upgrades impossible (supports FR-PLAT-15, FR-PLAT-16). |
| NFR-PERF-03 | Performance / Client | The client shall remain responsive on a low-end Android device and within a browser tab, not only on a development workstation; the Coordinator queue shall render its first screen of results without blocking on the full result set. |
| NFR-USAB-03 | Usability / Adaptivity | No primary action shall be reachable on one layout class but unreachable on another; where an expanded-layout action is collapsed on compact, it shall remain available through an explicit overflow affordance (supports FR-PLAT-02, FR-PLAT-04). |
| NFR-SEC-08 | Security / Client Storage | Authentication material shall never be written to browser web storage, to plaintext files on desktop, or to application logs on any target (supports FR-PLAT-10). |
| NFR-MAINT-02 | Maintainability | Platform-conditional code shall be confined to the abstraction layers named in FR-PLAT-01; a platform check appearing inside feature or business logic shall be treated as a review defect, since such checks are what turn one codebase into six. |
| NFR-DATA-01 | Data Integrity | All schema changes shall be applied exclusively through the migration tool (Section 9.2); no direct manual schema edits shall be made against staging or production databases. |
| NFR-DATA-02 | Recoverability | Every database migration shall have a tested rollback path before being applied to a production/live environment. |
| NFR-NOTIF-01 | Reliability | Login notifications and welcome emails shall be treated as high-priority sends; failed attempts shall be retried per FR-NOTIF-05 and surfaced in the delivery log rather than failing silently. |
| NFR-NOTIF-02 | Performance | A login notification shall be dispatched (handed off to the relevant gateway) within a short, bounded time of a successful login, without delaying the login response itself. |
| NFR-SEC-04 | Security / Privacy | Stored contact numbers and email addresses (`UserContactChannel`) shall be treated as personal data: encrypted at rest and accessible only through authorized account-management flows. |
| NFR-SEC-05 | Security | All third-party gateway credentials (Gmail App Password/OAuth token, Brevo API key, Resend API key, SMS gateway token, WhatsApp OAuth 2.0 credentials, Firebase service-account credential, Supabase service-role key) shall be stored in a secrets manager, never committed to source control, and never exposed to the Flutter client (supports FR-NOTIF-14–19, FR-DATA-04c). |
| NFR-SEC-06 | Security / Storage | No issue attachment shall be reachable without a backend-issued, time-limited signed URL; public bucket access shall be disabled at the Supabase Storage policy level, so that a leaked path alone does not grant access (supports FR-DATA-19–20). |
| NFR-SEC-07 | Security / Defence in Depth | Row Level Security shall remain enabled on all user-scoped tables in every environment; a deployment that disables RLS on a user-scoped table shall be treated as a release blocker (supports FR-DATA-04b). |
| NFR-PRIV-01 | Privacy / AI | No reporter identity, contact detail, or internal note shall be transmitted to an external LLM provider; where the provider's plan supports it, zero data retention shall be configured (supports FR-AI-15). |
| NFR-DATA-03 | Data Integrity / Automation | The build pipeline shall fail on schema drift between ORM models and migrations, and on the presence of multiple Alembic heads, so that divergence is caught before merge rather than at deploy time (supports FR-DATA-12–13). |
| NFR-DATA-04 | Recoverability | A backup checkpoint shall exist immediately prior to every production migration, and restore from that checkpoint shall be exercised on a defined periodic basis rather than assumed to work (supports FR-DATA-17). |
| NFR-DATA-05 | Data Integrity / Storage | Deletion of an issue shall not orphan its stored objects; attachment purge shall be driven by a scheduled reconciliation job that also detects storage objects with no corresponding database record (supports FR-DATA-24). |
| NFR-NOTIF-03 | Reliability / Push | Push delivery failure to one device shall not prevent delivery to a user's other devices, nor prevent the corresponding in-app notification from being recorded (supports FR-NOTIF-23, FR-NOTIF-28). |
| NFR-NOTIF-04 | Reliability / Email | Failure of the primary production email provider shall not cause message loss; messages shall fail over to the secondary provider and, failing that, remain queued for retry rather than being dropped (supports FR-NOTIF-20a). |
| NFR-NOTIF-05 | Observability | The system shall expose delivery-health metrics per channel and per provider (success rate, failure rate, queue depth, retry count) and shall raise an operational alert when a channel's failure rate exceeds a configured threshold (supports FR-NOTIF-04). |
| NFR-AI-01 | Cost Control | AI recommendation generation shall operate within a configured per-environment token budget; exhaustion shall degrade the feature to deterministic evidence rather than incurring unbounded cost (supports FR-AI-20). |
---

## 14. System Constraints and Assumptions

- **C-1:** Phase 1 scope is limited to Facilities categories only (AC, projector, wifi, lab equipment, library); Academic Concerns are explicitly out of scope until Phase 2 (PRD §11).
- **C-2:** *(Withdrawn in v3.0.)* The v1.0/v2.0 constraint "no mobile-native application until Phase 3; Phase 1–2 delivery is web-based only" no longer applies. Delivery targets are now defined by the platform matrix in Section 4.1: web and desktop in Phase 1, mobile in Phase 2, store distribution and device-native capability in Phase 3.
- **C-2a:** Push notifications cannot be delivered to a closed Windows or Linux desktop client, because Firebase Cloud Messaging does not support those platforms (Section 10.6a). Time-critical notifications on those targets must therefore also use an always-available channel (FR-NOTIF-33).
- **C-2b:** Mobile releases are subject to application-store review, which adds an unbounded delay between a build being ready and being available to users. Release planning from Phase 2 onward must not assume same-day mobile deployment (supports NFR-COMPAT-03).
- **C-2c:** Flutter Web has meaningful platform limitations relative to desktop and mobile — no secure credential storage (FR-PLAT-10), narrower Web Push support on Safari (Section 10.6a), and weaker offline capability (FR-PLAT-13). Web is a first-class target for functionality but not for every platform capability.
- **C-3:** The AI subsystem is advisory-only; system design must not create any code path where an AI decision executes a merge or closure without a human confirmation step (PRD §8).
- **A-1:** It is assumed the institution can supply structured master data (buildings/rooms/departments) at Admin setup time.
- **A-2:** It is assumed an LLM/AI service with sufficient text-classification and summarization capability is available and integratable within the college-project timeline/budget.

---

## 15. Traceability Matrix (PRD → SRS)

| PRD Section | Topic | SRS Requirement IDs |
|---|---|---|
| §3.1–3.5 | Actors | Section 3 (A1–A6) |
| §4 | Role-specific views | FR-1.3, FR-1.9–1.11, FR-1.16, FR-1.21, FR-1.24, NFR-USAB-01 |
| §5.1 | Auto-understanding of issue | FR-AI-01 |
| §5.2 | Timing-aware urgency | FR-AI-02 |
| §5.3 | Duplicate detection | FR-AI-03, FR-1.28 |
| §5.4 | Recurring issue detection | FR-AI-04, FR-2.6 |
| §5.5 | Suggest prior fix | FR-AI-05, FR-2.4 |
| §5.6 | Drafted updates | FR-AI-06 |
| §5.7 | SLA-risk warning | FR-AI-07, FR-1.15, FR-1.17 |
| §5.8 | Running summary | FR-AI-08, FR-2.5 |
| §5.9 | Weekly leadership summary | FR-AI-09, FR-1.23 |
| §6 | Issue lifecycle | FR-1.28, Appendix §16 |
| §8 | Human control over AI | FR-AI-10, FR-AI-11, FR-AI-12, FR-1.30 |
| §9 | Privacy/traceability | NFR-SEC-01, NFR-SEC-02, NFR-AUDIT-01, FR-1.27 |
| §11 | MVP scope | Section 5 (all Phase 1 FRs) |
| §12 | ORM & database migrations | FR-DATA-01–10, FR-DATA-04a–04c, NFR-DATA-01, NFR-DATA-02 |
| §12 | Database migration automation | FR-DATA-11–17, NFR-DATA-03, NFR-DATA-04 |
| §12 | File storage (Supabase Storage) | FR-DATA-18–24, NFR-SEC-06, NFR-DATA-05 |
| §13 | Automated communications (SMS/WhatsApp/Email, login alerts, welcome email) | FR-NOTIF-01–20, FR-NOTIF-01a–01c, FR-NOTIF-05a–05b, FR-NOTIF-07a–07c, FR-NOTIF-13a–13b, FR-NOTIF-15a, FR-NOTIF-20a–20c, NFR-NOTIF-01, NFR-NOTIF-02, NFR-NOTIF-04, NFR-NOTIF-05, NFR-SEC-04, NFR-SEC-05 |
| §13 | Push notifications to logged-in devices | FR-NOTIF-17a, FR-NOTIF-21–29, NFR-NOTIF-03 |
| §5 (extended) | AI recommendations | FR-AI-13–20, NFR-PRIV-01, NFR-AI-01 |
| §4, §12 | Cross-platform delivery (web, desktop, mobile) | FR-PLAT-01–22, Section 4.1, NFR-COMPAT-01–03, NFR-USAB-03, NFR-PERF-03, NFR-SEC-08, NFR-MAINT-02 |
| §13 | Push transport by platform | FR-NOTIF-30–34, C-2a |
| §14 | Future ideas | Section 6 (Phase 2), Section 7 (Phase 3) |
---

## 16. Appendix — Issue Lifecycle State Model

**Primary path:**

`Reported → Understood → Assigned → Investigating → Action Taken → Resolved → Confirmed → Closed`

**Sub-states (can be entered from applicable primary states):**

- `Waiting for Information` — entered when a Coordinator requests missing details from the Reporter; returns to prior state once information is supplied.
- `Escalated` — entered when a Supervisor or SLA-risk trigger requires higher-level attention; returns to normal flow once handled.
- `Reopened` — entered from `Resolved`/`Confirmed` if the Reporter rejects the resolution (FR-1.7); re-enters the active workflow at `Investigating`.

**State transition rules:**

- Every transition is logged (FR-1.29, NFR-AUDIT-01).
- Transition into `Closed` requires Reporter confirmation (`Confirmed`) except where an Admin-defined auto-close timeout policy is explicitly configured (design decision to be confirmed during detailed design — not assumed by default).
- No transition directly from `Reported` to `Closed` is permitted; the issue must pass through assignment and resolution steps.

---

## 17. Open Decisions

These items are unresolved as of v3.0 and should be settled before detailed design. Each is a decision, not a requirement.

| # | Decision required | Impact if unresolved |
|---|---|---|
| D-1 | Whether Supabase Auth replaces or coexists with institutional SSO. This SRS retains SSO/local-account fallback (§2.6) and uses Supabase only for database and storage. | Affects §2.6, §11.3, and the `User` entity's identity fields. |
| D-2 | Whether Resend is the production failover (as specified) or should replace Brevo as production primary. Retaining all three adapters costs one extra integration to build and maintain. | Affects FR-NOTIF-15, FR-NOTIF-15a, FR-NOTIF-20, FR-NOTIF-20a. |
| D-3 | *(Superseded in v3.0.)* Push is now specified per platform in Section 10.6a. What remains open is whether web push is enabled in Phase 1 or deferred until the mobile clients land in Phase 2, given Safari's narrower Web Push support. | Affects §10.6a phasing and the Phase 1 test plan. |
| D-8 | Whether the Linux desktop target is actually required. It carries its own packaging, notification, and test-matrix cost, and Section 4.1 assigns it only Admin and technical-staff use. Dropping it removes a build target without affecting any actor's primary workflow. | Affects §4.1, FR-PLAT-17, FR-PLAT-20. |
| D-9 | Whether the desktop clients are expected on personally-owned machines or only on managed campus workstations. Managed deployment would let the institution push updates centrally and would make FR-PLAT-18's self-update mechanism unnecessary. | Affects FR-PLAT-17, FR-PLAT-18. |
| D-10 | Whether Phase 1 desktop delivery covers all three desktop OSes or begins with Windows alone. Section 4.1 currently lists all three in Phase 1; narrowing to Windows would materially reduce Phase 1 signing, packaging, and test-matrix work. | Affects §4.1, FR-PLAT-17, FR-PLAT-20. |
| D-11 | Whether offline write support (queued actions with later replay) is required for Coordinators working in basements, plant rooms, or other low-signal areas. FR-PLAT-14 currently excludes it on the grounds of lifecycle conflict risk; if field conditions demand it, a conflict-resolution policy must be specified. | Affects FR-PLAT-13, FR-PLAT-14, FR-1.28. |
| D-4 | Whether the SMS gateway is confirmed, and whether TRAI DLT registration (sender ID and template pre-registration) has been completed. Indian SMS delivery is blocked without it. | Affects FR-NOTIF-08, FR-NOTIF-16, and Phase 1 delivery feasibility. |
| D-5 | Whether the WhatsApp Business Cloud API app is approved, given the review lead time, and which pre-approved message templates exist for login alerts and status updates. | Affects FR-NOTIF-08, FR-NOTIF-17. |
| D-6 | Attachment retention period and whether attachments from closed issues are purged, archived, or retained indefinitely for institutional records. | Affects FR-DATA-24, NFR-DATA-05. |
| D-7 | Whether login notifications are sent on every login or only on logins from an unrecognised device. Every-login alerts on a campus system with daily logins will cause users to disable the channel or filter it as noise. | Affects FR-NOTIF-08, FR-NOTIF-10. |

---

*End of Document*
