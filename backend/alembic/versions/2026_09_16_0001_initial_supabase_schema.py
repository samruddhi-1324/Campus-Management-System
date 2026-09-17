"""Initial Supabase PostgreSQL Schema for Campus Care

Revision ID: 2026_09_16_0001
Revises: 
Create Date: 2026-09-16 19:50:00.000000

"""
from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "2026_09_16_0001"
down_revision: str | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # 1. Institutions
    op.create_table(
        "institutions",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("name", sa.String(150), unique=True, nullable=False),
        sa.Column("slug", sa.String(50), unique=True, nullable=False),
        sa.Column("domain", sa.String(100), unique=True, nullable=False),
        sa.Column("logo_url", sa.String(512), nullable=True),
        sa.Column("settings", postgresql.JSONB, server_default="{}", nullable=False),
        sa.Column("is_active", sa.Boolean, server_default="true", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("idx_institutions_slug", "institutions", ["slug"])
    op.create_index("idx_institutions_domain", "institutions", ["domain"])

    # 2. Departments
    op.create_table(
        "departments",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("name", sa.String(100), unique=True, nullable=False),
        sa.Column("code", sa.String(20), unique=True, nullable=False),
        sa.Column("is_active", sa.Boolean, server_default="true", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # 3. Buildings
    op.create_table(
        "buildings",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("name", sa.String(100), unique=True, nullable=False),
        sa.Column("code", sa.String(20), unique=True, nullable=False),
        sa.Column("is_active", sa.Boolean, server_default="true", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # 4. Rooms
    op.create_table(
        "rooms",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("building_id", sa.String(36), sa.ForeignKey("buildings.id", ondelete="CASCADE"), nullable=False),
        sa.Column("room_number", sa.String(50), nullable=False),
        sa.Column("floor", sa.Integer, nullable=True),
        sa.Column("room_type", sa.String(50), nullable=True),
        sa.Column("is_active", sa.Boolean, server_default="true", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.UniqueConstraint("building_id", "room_number", name="uq_building_room"),
    )
    op.create_index("idx_rooms_building_id", "rooms", ["building_id"])

    # 5. Categories
    op.create_table(
        "categories",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("name", sa.String(100), unique=True, nullable=False),
        sa.Column("slug", sa.String(50), unique=True, nullable=False),
        sa.Column("description", sa.Text, nullable=True),
        sa.Column("default_sla_hours", sa.Integer, server_default="24", nullable=False),
        sa.Column("is_active", sa.Boolean, server_default="true", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("idx_categories_slug", "categories", ["slug"])

    # 6. Users
    op.create_table(
        "users",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("email", sa.String(255), unique=True, nullable=False),
        sa.Column("hashed_password", sa.String(255), nullable=False),
        sa.Column("full_name", sa.String(150), nullable=False),
        sa.Column("role", sa.Enum("reporter", "coordinator", "supervisor", "ops_head", "admin", name="user_role_enum"), nullable=False),
        sa.Column("department_id", sa.String(36), sa.ForeignKey("departments.id"), nullable=True),
        sa.Column("is_active", sa.Boolean, server_default="true", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("idx_users_email", "users", ["email"])
    op.create_index("idx_users_role", "users", ["role"])

    # 7. Teams
    op.create_table(
        "teams",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("name", sa.String(100), unique=True, nullable=False),
        sa.Column("supervisor_id", sa.String(36), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("is_active", sa.Boolean, server_default="true", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # 8. User Contact Channels
    op.create_table(
        "user_contact_channels",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("channel_type", sa.Enum("email", "sms", "whatsapp", "in_app", name="contact_channel_type_enum"), nullable=False),
        sa.Column("address_or_number", sa.String(255), nullable=False),
        sa.Column("is_verified", sa.Boolean, server_default="false", nullable=False),
        sa.Column("is_active", sa.Boolean, server_default="true", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("idx_user_contact_channels_user_id", "user_contact_channels", ["user_id"])

    # 9. User Devices
    op.create_table(
        "user_devices",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("fcm_token", sa.String(512), nullable=True),
        sa.Column("transport_type", sa.String(20), server_default="fcm", nullable=False),
        sa.Column("platform", sa.String(20), nullable=False),
        sa.Column("app_version", sa.String(20), nullable=False),
        sa.Column("device_model", sa.String(100), nullable=True),
        sa.Column("locale", sa.String(10), server_default="en", nullable=False),
        sa.Column("timezone", sa.String(50), server_default="UTC", nullable=False),
        sa.Column("last_seen_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("is_active", sa.Boolean, server_default="true", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("idx_user_devices_user_id", "user_devices", ["user_id"])

    # 10. Notification Preferences
    op.create_table(
        "notification_preferences",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("event_category", sa.String(50), nullable=False),
        sa.Column("channel_type", sa.Enum("email", "sms", "whatsapp", "in_app", name="pref_channel_type_enum"), nullable=False),
        sa.Column("enabled", sa.Boolean, server_default="true", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.UniqueConstraint("user_id", "event_category", "channel_type", name="uq_user_event_channel"),
    )

    # 11. Issues
    op.create_table(
        "issues",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("reference_number", sa.String(30), unique=True, nullable=False),
        sa.Column("title", sa.String(200), nullable=False),
        sa.Column("description", sa.Text, nullable=False),
        sa.Column("category_id", sa.String(36), sa.ForeignKey("categories.id"), nullable=True),
        sa.Column("building_id", sa.String(36), sa.ForeignKey("buildings.id"), nullable=True),
        sa.Column("room_id", sa.String(36), sa.ForeignKey("rooms.id"), nullable=True),
        sa.Column("location_details", sa.String(255), nullable=True),
        sa.Column(
            "status",
            sa.Enum(
                "reported", "understood", "assigned", "investigating",
                "action_taken", "resolved", "confirmed", "closed",
                "waiting_for_info", "escalated", "reopened",
                name="issue_status_enum",
            ),
            server_default="reported",
            nullable=False,
        ),
        sa.Column(
            "urgency",
            sa.Enum("low", "medium", "high", "critical", name="issue_urgency_enum"),
            server_default="medium",
            nullable=False,
        ),
        sa.Column("ai_suggested_urgency", sa.String(20), nullable=True),
        sa.Column("ai_urgency_rationale", sa.Text, nullable=True),
        sa.Column("reporter_id", sa.String(36), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("assigned_coordinator_id", sa.String(36), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("assigned_team_id", sa.String(36), sa.ForeignKey("teams.id"), nullable=True),
        sa.Column("expected_resolution_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("confirmed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("closed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("idx_issues_ref_num", "issues", ["reference_number"])
    op.create_index("idx_issues_reporter_id", "issues", ["reporter_id"])
    op.create_index("idx_issues_coordinator_id", "issues", ["assigned_coordinator_id"])
    op.create_index("idx_issues_status", "issues", ["status"])

    # 12. Issue Attachments
    op.create_table(
        "issue_attachments",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("issue_id", sa.String(36), sa.ForeignKey("issues.id", ondelete="CASCADE"), nullable=False),
        sa.Column("attachment_type", sa.String(20), server_default="photo", nullable=False),
        sa.Column("storage_bucket", sa.String(100), nullable=False),
        sa.Column("storage_path", sa.String(512), nullable=False),
        sa.Column("mime_type", sa.String(100), nullable=False),
        sa.Column("size_bytes", sa.BigInteger, nullable=False),
        sa.Column("uploaded_by", sa.String(36), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("idx_attachments_issue_id", "issue_attachments", ["issue_id"])

    # 13. Issue Updates
    op.create_table(
        "issue_updates",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("issue_id", sa.String(36), sa.ForeignKey("issues.id", ondelete="CASCADE"), nullable=False),
        sa.Column("author_id", sa.String(36), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("visibility", sa.String(20), server_default="external", nullable=False),
        sa.Column("message", sa.Text, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # 14. Issue State History
    op.create_table(
        "issue_state_history",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("issue_id", sa.String(36), sa.ForeignKey("issues.id", ondelete="CASCADE"), nullable=False),
        sa.Column("from_state", sa.String(30), nullable=False),
        sa.Column("to_state", sa.String(30), nullable=False),
        sa.Column("changed_by", sa.String(36), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("reason", sa.Text, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # 15. Issue Groups (Dedup)
    op.create_table(
        "issue_groups",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("primary_issue_id", sa.String(36), sa.ForeignKey("issues.id"), nullable=False),
        sa.Column("created_by", sa.String(36), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("notes", sa.Text, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # 16. Audit Log Entries
    op.create_table(
        "audit_log_entries",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("actor_id", sa.String(36), sa.ForeignKey("users.id"), nullable=False),
        sa.Column(
            "action",
            sa.Enum(
                "create", "update", "assign", "reassign", "status_change",
                "priority_change", "resolve", "close", "reopen", "merge",
                name="audit_action_enum",
            ),
            nullable=False,
        ),
        sa.Column("target_entity", sa.String(50), nullable=False),
        sa.Column("target_id", sa.String(36), nullable=False),
        sa.Column("before_state", postgresql.JSONB, nullable=True),
        sa.Column("after_state", postgresql.JSONB, nullable=True),
        sa.Column("ip_address", sa.String(45), nullable=True),
        sa.Column("user_agent", sa.String(255), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("idx_audit_logs_actor", "audit_log_entries", ["actor_id"])

    # 17. AI Insights
    op.create_table(
        "ai_insights",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("issue_id", sa.String(36), sa.ForeignKey("issues.id", ondelete="CASCADE"), nullable=False),
        sa.Column("insight_type", sa.String(50), nullable=False),
        sa.Column("payload", postgresql.JSONB, nullable=False),
        sa.Column("confidence", sa.Float, server_default="0.0", nullable=False),
        sa.Column("human_decision", sa.String(20), nullable=True),
        sa.Column("decided_by", sa.String(36), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("decided_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("idx_ai_insights_issue_id", "ai_insights", ["issue_id"])

    # 18. Notification Logs
    op.create_table(
        "notification_logs",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("channel", sa.String(20), nullable=False),
        sa.Column("template", sa.String(100), nullable=False),
        sa.Column("provider", sa.String(50), nullable=False),
        sa.Column("provider_message_id", sa.String(255), nullable=True),
        sa.Column("related_issue_id", sa.String(36), sa.ForeignKey("issues.id", ondelete="SET NULL"), nullable=True),
        sa.Column("status", sa.String(20), server_default="queued", nullable=False),
        sa.Column("attempt_count", sa.Integer, server_default="1", nullable=False),
        sa.Column("idempotency_key", sa.String(255), unique=True, nullable=False),
        sa.Column("error_detail", sa.Text, nullable=True),
        sa.Column("sent_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # 19. Academic Concerns (Phase 2)
    op.create_table(
        "academic_concerns",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("issue_id", sa.String(36), sa.ForeignKey("issues.id", ondelete="CASCADE"), unique=True, nullable=False),
        sa.Column(
            "concern_type",
            sa.Enum(
                "exam_grievance", "grade_dispute", "course_scheduling", "faculty_advising", "other",
                name="academic_concern_type_enum",
            ),
            nullable=False,
        ),
        sa.Column("course_code", sa.String(50), nullable=True),
        sa.Column("academic_term", sa.String(50), nullable=True),
        sa.Column("assigned_academic_officer_id", sa.String(36), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("is_confidential", sa.Boolean, server_default="true", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # 20. Confidential Access Logs (Phase 2)
    op.create_table(
        "confidential_access_logs",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("academic_concern_id", sa.String(36), sa.ForeignKey("academic_concerns.id", ondelete="CASCADE"), nullable=False),
        sa.Column("accessed_by", sa.String(36), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("access_reason", sa.String(255), nullable=True),
        sa.Column("accessed_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # 21. Recommendations (Phase 2)
    op.create_table(
        "recommendations",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column(
            "recommendation_type",
            sa.Enum("resolution", "preventive", "resourcing", name="recommendation_type_enum"),
            nullable=False,
        ),
        sa.Column("scope_reference", sa.String(100), nullable=False),
        sa.Column("title", sa.String(200), nullable=False),
        sa.Column("body", sa.Text, nullable=False),
        sa.Column("suggested_action", sa.Text, nullable=False),
        sa.Column("evidence_snapshot", postgresql.JSONB, nullable=False),
        sa.Column("confidence", sa.Float, server_default="0.0", nullable=False),
        sa.Column("model_version", sa.String(50), nullable=False),
        sa.Column("human_decision", sa.String(20), nullable=True),
        sa.Column("decided_by", sa.String(36), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("decided_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # 22. Recurrence Patterns (Phase 2)
    op.create_table(
        "recurrence_patterns",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("asset_or_location_ref", sa.String(100), nullable=False),
        sa.Column("failure_count", sa.Integer, nullable=False),
        sa.Column("observation_window_days", sa.Integer, server_default="30", nullable=False),
        sa.Column("related_issue_ids", postgresql.JSONB, nullable=False),
        sa.Column("status", sa.String(30), server_default="flagged", nullable=False),
        sa.Column("converted_recommendation_id", sa.String(36), sa.ForeignKey("recommendations.id"), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # 23. Category SLA Configs (Phase 2)
    op.create_table(
        "category_sla_configs",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("category_id", sa.String(36), sa.ForeignKey("categories.id", ondelete="CASCADE"), nullable=False),
        sa.Column("building_id", sa.String(36), sa.ForeignKey("buildings.id", ondelete="CASCADE"), nullable=True),
        sa.Column("urgency_level", sa.String(20), nullable=False),
        sa.Column("expected_response_hours", sa.Integer, server_default="2", nullable=False),
        sa.Column("expected_resolution_hours", sa.Integer, server_default="24", nullable=False),
        sa.Column("is_active", sa.Boolean, server_default="true", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # 24. Historical Trend Records (Phase 3)
    op.create_table(
        "historical_trend_records",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("institution_id", sa.String(36), sa.ForeignKey("institutions.id"), nullable=True),
        sa.Column("category_id", sa.String(36), sa.ForeignKey("categories.id"), nullable=True),
        sa.Column("year", sa.Integer, nullable=False),
        sa.Column("quarter", sa.Integer, nullable=True),
        sa.Column("month", sa.Integer, nullable=True),
        sa.Column("total_volume", sa.Integer, nullable=False),
        sa.Column("avg_resolution_hours", sa.Float, nullable=False),
        sa.Column("seasonal_spike_flag", sa.Boolean, server_default="false", nullable=False),
        sa.Column("pattern_summary", sa.Text, nullable=True),
        sa.Column("aggregated_metrics", postgresql.JSONB, server_default="{}", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )


def downgrade() -> None:
    # Drop in reverse order of creation
    op.drop_table("historical_trend_records")
    op.drop_table("category_sla_configs")
    op.drop_table("recurrence_patterns")
    op.drop_table("recommendations")
    op.drop_table("confidential_access_logs")
    op.drop_table("academic_concerns")
    op.drop_table("notification_logs")
    op.drop_table("ai_insights")
    op.drop_table("audit_log_entries")
    op.drop_table("issue_groups")
    op.drop_table("issue_state_history")
    op.drop_table("issue_updates")
    op.drop_table("issue_attachments")
    op.drop_table("issues")
    op.drop_table("notification_preferences")
    op.drop_table("user_devices")
    op.drop_table("user_contact_channels")
    op.drop_table("teams")
    op.drop_table("users")
    op.drop_table("categories")
    op.drop_table("rooms")
    op.drop_table("buildings")
    op.drop_table("departments")
    op.drop_table("institutions")
