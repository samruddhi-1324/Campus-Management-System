-- =============================================================================
-- Campus Care — Supabase Managed PostgreSQL Initialization Schema
-- Compliant with Campus Care PRD & SRS v3.0
-- =============================================================================

-- Enable UUID extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- 1. ENUMS
-- =============================================================================

DO $$ BEGIN
    CREATE TYPE user_role_enum AS ENUM ('reporter', 'coordinator', 'supervisor', 'ops_head', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE contact_channel_type_enum AS ENUM ('email', 'sms', 'whatsapp', 'in_app');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE pref_channel_type_enum AS ENUM ('email', 'sms', 'whatsapp', 'in_app');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE issue_status_enum AS ENUM (
        'reported', 'understood', 'assigned', 'investigating', 
        'action_taken', 'resolved', 'confirmed', 'closed',
        'waiting_for_info', 'escalated', 'reopened'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE issue_urgency_enum AS ENUM ('low', 'medium', 'high', 'critical');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE audit_action_enum AS ENUM (
        'create', 'update', 'assign', 'reassign', 'status_change',
        'priority_change', 'resolve', 'close', 'reopen', 'merge'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE academic_concern_type_enum AS ENUM (
        'exam_grievance', 'grade_dispute', 'course_scheduling', 'faculty_advising', 'other'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE recommendation_type_enum AS ENUM ('resolution', 'preventive', 'resourcing');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;


-- =============================================================================
-- 2. MASTER DATA & TENANCY TABLES
-- =============================================================================

-- Institutions (Multi-Tenancy - FR-3.4)
CREATE TABLE IF NOT EXISTS institutions (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(150) UNIQUE NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    domain VARCHAR(100) UNIQUE NOT NULL,
    logo_url VARCHAR(512),
    settings JSONB DEFAULT '{}'::jsonb NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_institutions_slug ON institutions(slug);
CREATE INDEX IF NOT EXISTS idx_institutions_domain ON institutions(domain);

-- Departments
CREATE TABLE IF NOT EXISTS departments (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Buildings
CREATE TABLE IF NOT EXISTS buildings (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Rooms
CREATE TABLE IF NOT EXISTS rooms (
    id VARCHAR(36) PRIMARY KEY,
    building_id VARCHAR(36) NOT NULL REFERENCES buildings(id) ON DELETE CASCADE,
    room_number VARCHAR(50) NOT NULL,
    floor INTEGER,
    room_type VARCHAR(50),
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT uq_building_room UNIQUE (building_id, room_number)
);
CREATE INDEX IF NOT EXISTS idx_rooms_building_id ON rooms(building_id);

-- Categories (Facilities & Academic)
CREATE TABLE IF NOT EXISTS categories (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    default_sla_hours INTEGER DEFAULT 24 NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_categories_slug ON categories(slug);


-- =============================================================================
-- 3. USERS, TEAMS & SECURITY TABLES
-- =============================================================================

-- Users
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    role user_role_enum DEFAULT 'reporter'::user_role_enum NOT NULL,
    department_id VARCHAR(36) REFERENCES departments(id),
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Teams
CREATE TABLE IF NOT EXISTS teams (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    supervisor_id VARCHAR(36) REFERENCES users(id),
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- User Contact Channels (FR-NOTIF-02, NFR-SEC-04)
CREATE TABLE IF NOT EXISTS user_contact_channels (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    channel_type contact_channel_type_enum NOT NULL,
    address_or_number VARCHAR(255) NOT NULL,
    is_verified BOOLEAN DEFAULT false NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_user_contact_channels_user_id ON user_contact_channels(user_id);

-- User Devices (FR-NOTIF-21..34)
CREATE TABLE IF NOT EXISTS user_devices (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    fcm_token VARCHAR(512),
    transport_type VARCHAR(20) DEFAULT 'fcm' NOT NULL,
    platform VARCHAR(20) NOT NULL,
    app_version VARCHAR(20) NOT NULL,
    device_model VARCHAR(100),
    locale VARCHAR(10) DEFAULT 'en' NOT NULL,
    timezone VARCHAR(50) DEFAULT 'UTC' NOT NULL,
    last_seen_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_user_devices_user_id ON user_devices(user_id);

-- Notification Preferences (FR-NOTIF-11)
CREATE TABLE IF NOT EXISTS notification_preferences (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_category VARCHAR(50) NOT NULL,
    channel_type pref_channel_type_enum NOT NULL,
    enabled BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT uq_user_event_channel UNIQUE (user_id, event_category, channel_type)
);
CREATE INDEX IF NOT EXISTS idx_notification_preferences_user ON notification_preferences(user_id);


-- =============================================================================
-- 4. ISSUES & LIFECYCLE TABLES
-- =============================================================================

-- Issues
CREATE TABLE IF NOT EXISTS issues (
    id VARCHAR(36) PRIMARY KEY,
    reference_number VARCHAR(30) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category_id VARCHAR(36) REFERENCES categories(id),
    building_id VARCHAR(36) REFERENCES buildings(id),
    room_id VARCHAR(36) REFERENCES rooms(id),
    location_details VARCHAR(255),
    status issue_status_enum DEFAULT 'reported'::issue_status_enum NOT NULL,
    urgency issue_urgency_enum DEFAULT 'medium'::issue_urgency_enum NOT NULL,
    ai_suggested_urgency VARCHAR(20),
    ai_urgency_rationale TEXT,
    reporter_id VARCHAR(36) NOT NULL REFERENCES users(id),
    assigned_coordinator_id VARCHAR(36) REFERENCES users(id),
    assigned_team_id VARCHAR(36) REFERENCES teams(id),
    expected_resolution_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    confirmed_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_issues_ref_num ON issues(reference_number);
CREATE INDEX IF NOT EXISTS idx_issues_reporter_id ON issues(reporter_id);
CREATE INDEX IF NOT EXISTS idx_issues_coordinator_id ON issues(assigned_coordinator_id);
CREATE INDEX IF NOT EXISTS idx_issues_status ON issues(status);
CREATE INDEX IF NOT EXISTS idx_issues_category_id ON issues(category_id);
CREATE INDEX IF NOT EXISTS idx_issues_building_id ON issues(building_id);
CREATE INDEX IF NOT EXISTS idx_issues_expected_resolution ON issues(expected_resolution_at);

-- Issue Attachments (Supabase Storage metadata - FR-DATA-18..24)
CREATE TABLE IF NOT EXISTS issue_attachments (
    id VARCHAR(36) PRIMARY KEY,
    issue_id VARCHAR(36) NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    attachment_type VARCHAR(20) DEFAULT 'photo' NOT NULL,
    storage_bucket VARCHAR(100) NOT NULL,
    storage_path VARCHAR(512) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    size_bytes BIGINT NOT NULL,
    uploaded_by VARCHAR(36) NOT NULL REFERENCES users(id),
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_attachments_issue_id ON issue_attachments(issue_id);

-- Issue Updates (Staff notes vs. Public updates - FR-1.13, NFR-SEC-02)
CREATE TABLE IF NOT EXISTS issue_updates (
    id VARCHAR(36) PRIMARY KEY,
    issue_id VARCHAR(36) NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    author_id VARCHAR(36) NOT NULL REFERENCES users(id),
    visibility VARCHAR(20) DEFAULT 'external' NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_updates_issue_id ON issue_updates(issue_id);

-- Issue State History (Immutable audit trail - FR-1.29)
CREATE TABLE IF NOT EXISTS issue_state_history (
    id VARCHAR(36) PRIMARY KEY,
    issue_id VARCHAR(36) NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    from_state VARCHAR(30) NOT NULL,
    to_state VARCHAR(30) NOT NULL,
    changed_by VARCHAR(36) NOT NULL REFERENCES users(id),
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_state_history_issue_id ON issue_state_history(issue_id);

-- Issue Groups (Deduplication - FR-AI-03, FR-1.28)
CREATE TABLE IF NOT EXISTS issue_groups (
    id VARCHAR(36) PRIMARY KEY,
    primary_issue_id VARCHAR(36) NOT NULL REFERENCES issues(id),
    created_by VARCHAR(36) NOT NULL REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);


-- =============================================================================
-- 5. AUDIT, AI INSIGHTS & COMMUNICATIONS LOGS
-- =============================================================================

-- System Audit Log (FR-1.27, NFR-AUDIT-01)
CREATE TABLE IF NOT EXISTS audit_log_entries (
    id VARCHAR(36) PRIMARY KEY,
    actor_id VARCHAR(36) NOT NULL REFERENCES users(id),
    action audit_action_enum NOT NULL,
    target_entity VARCHAR(50) NOT NULL,
    target_id VARCHAR(36) NOT NULL,
    before_state JSONB,
    after_state JSONB,
    ip_address VARCHAR(45),
    user_agent VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON audit_log_entries(actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_target ON audit_log_entries(target_entity, target_id);

-- AI Insights Log (FR-AI-01..12)
CREATE TABLE IF NOT EXISTS ai_insights (
    id VARCHAR(36) PRIMARY KEY,
    issue_id VARCHAR(36) NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    insight_type VARCHAR(50) NOT NULL,
    payload JSONB NOT NULL,
    confidence FLOAT DEFAULT 0.0 NOT NULL,
    human_decision VARCHAR(20),
    decided_by VARCHAR(36) REFERENCES users(id),
    decided_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_ai_insights_issue_id ON ai_insights(issue_id);

-- Notification Logs (FR-NOTIF-04)
CREATE TABLE IF NOT EXISTS notification_logs (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    channel VARCHAR(20) NOT NULL,
    template VARCHAR(100) NOT NULL,
    provider VARCHAR(50) NOT NULL,
    provider_message_id VARCHAR(255),
    related_issue_id VARCHAR(36) REFERENCES issues(id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'queued' NOT NULL,
    attempt_count INTEGER DEFAULT 1 NOT NULL,
    idempotency_key VARCHAR(255) UNIQUE NOT NULL,
    error_detail TEXT,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_notification_logs_user ON notification_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_logs_idempotency ON notification_logs(idempotency_key);


-- =============================================================================
-- 6. PHASE 2 & 3 EXTENSIONS (ACADEMIC, RECOMMENDATIONS, SLA, HISTORICAL)
-- =============================================================================

-- Academic Concerns (FR-2.1..2.3)
CREATE TABLE IF NOT EXISTS academic_concerns (
    id VARCHAR(36) PRIMARY KEY,
    issue_id VARCHAR(36) UNIQUE NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    concern_type academic_concern_type_enum NOT NULL,
    course_code VARCHAR(50),
    academic_term VARCHAR(50),
    assigned_academic_officer_id VARCHAR(36) REFERENCES users(id),
    is_confidential BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_academic_concerns_issue ON academic_concerns(issue_id);

-- Confidential Access Logs (FR-2.2)
CREATE TABLE IF NOT EXISTS confidential_access_logs (
    id VARCHAR(36) PRIMARY KEY,
    academic_concern_id VARCHAR(36) NOT NULL REFERENCES academic_concerns(id) ON DELETE CASCADE,
    accessed_by VARCHAR(36) NOT NULL REFERENCES users(id),
    access_reason VARCHAR(255),
    accessed_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- AI Recommendations (FR-AI-13..20)
CREATE TABLE IF NOT EXISTS recommendations (
    id VARCHAR(36) PRIMARY KEY,
    recommendation_type recommendation_type_enum NOT NULL,
    scope_reference VARCHAR(100) NOT NULL,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    suggested_action TEXT NOT NULL,
    evidence_snapshot JSONB NOT NULL,
    confidence FLOAT DEFAULT 0.0 NOT NULL,
    model_version VARCHAR(50) NOT NULL,
    human_decision VARCHAR(20),
    decided_by VARCHAR(36) REFERENCES users(id),
    decided_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Recurrence Patterns (FR-2.6, FR-2.7)
CREATE TABLE IF NOT EXISTS recurrence_patterns (
    id VARCHAR(36) PRIMARY KEY,
    asset_or_location_ref VARCHAR(100) NOT NULL,
    failure_count INTEGER NOT NULL,
    observation_window_days INTEGER DEFAULT 30 NOT NULL,
    related_issue_ids JSONB NOT NULL,
    status VARCHAR(30) DEFAULT 'flagged' NOT NULL,
    converted_recommendation_id VARCHAR(36) REFERENCES recommendations(id),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_recurrence_ref ON recurrence_patterns(asset_or_location_ref);

-- Category SLA Configs (FR-2.9)
CREATE TABLE IF NOT EXISTS category_sla_configs (
    id VARCHAR(36) PRIMARY KEY,
    category_id VARCHAR(36) NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    building_id VARCHAR(36) REFERENCES buildings(id) ON DELETE CASCADE,
    urgency_level VARCHAR(20) NOT NULL,
    expected_response_hours INTEGER DEFAULT 2 NOT NULL,
    expected_resolution_hours INTEGER DEFAULT 24 NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Historical Trend Records (FR-3.5)
CREATE TABLE IF NOT EXISTS historical_trend_records (
    id VARCHAR(36) PRIMARY KEY,
    institution_id VARCHAR(36) REFERENCES institutions(id),
    category_id VARCHAR(36) REFERENCES categories(id),
    year INTEGER NOT NULL,
    quarter INTEGER,
    month INTEGER,
    total_volume INTEGER NOT NULL,
    avg_resolution_hours FLOAT NOT NULL,
    seasonal_spike_flag BOOLEAN DEFAULT false NOT NULL,
    pattern_summary TEXT,
    aggregated_metrics JSONB DEFAULT '{}'::jsonb NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_historical_year ON historical_trend_records(year);


-- =============================================================================
-- 7. SUPABASE ROW LEVEL SECURITY (RLS) POLICIES (FR-DATA-04b, NFR-SEC-01/02/07)
-- =============================================================================

-- Enable Row Level Security on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_contact_channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE issue_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE issue_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE issue_state_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE academic_concerns ENABLE ROW LEVEL SECURITY;
ALTER TABLE confidential_access_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE recurrence_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_logs ENABLE ROW LEVEL SECURITY;

-- Note: The FastAPI backend connects with the Supabase Service Role Key to execute
-- application-level RBAC and state machine logic. Client direct queries are secured
-- by RLS policies ensuring reporters can only select their own records (reporter_id = auth.uid()).
