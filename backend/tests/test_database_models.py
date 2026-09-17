from sqlalchemy.dialects import postgresql
from sqlalchemy.schema import CreateTable

from app.models.base import Base
from app.models.issue import Issue, IssueStatus, IssueUrgency
from app.models.user import UserRole


def test_all_models_registered_in_metadata():
    """Verify that all 24 tables are properly registered in SQLAlchemy Base.metadata."""
    table_names = set(Base.metadata.tables.keys())

    expected_tables = {
        "institutions",
        "departments",
        "buildings",
        "rooms",
        "categories",
        "teams",
        "users",
        "user_contact_channels",
        "user_devices",
        "notification_preferences",
        "issues",
        "issue_attachments",
        "issue_updates",
        "issue_state_history",
        "issue_groups",
        "audit_log_entries",
        "ai_insights",
        "notification_logs",
        "academic_concerns",
        "confidential_access_logs",
        "recommendations",
        "recurrence_patterns",
        "category_sla_configs",
        "historical_trend_records",
    }

    assert expected_tables.issubset(table_names), f"Missing tables: {expected_tables - table_names}"
    assert len(expected_tables) == 24


def test_postgresql_ddl_compilation():
    """Verify that all 24 tables compile cleanly into PostgreSQL DDL."""
    pg_dialect = postgresql.dialect()

    for table_name, table in Base.metadata.tables.items():
        ddl = str(CreateTable(table).compile(dialect=pg_dialect))
        assert f"CREATE TABLE {table_name}" in ddl or f'CREATE TABLE "{table_name}"' in ddl
        assert len(ddl) > 0


def test_issue_model_instantiation():
    """Verify Issue model creation with defaults and enums."""
    issue = Issue(
        id="test-issue-123",
        reference_number="CC-2026-0001",
        title="Broken AC Unit in Lab 301",
        description="Air conditioner unit is leaking water and not cooling.",
        status=IssueStatus.REPORTED,
        urgency=IssueUrgency.HIGH,
    )

    assert issue.reference_number == "CC-2026-0001"
    assert issue.status == IssueStatus.REPORTED
    assert issue.urgency == IssueUrgency.HIGH


def test_user_roles_enum():
    """Verify that all 5 RBAC roles are properly defined."""
    assert UserRole.REPORTER == "reporter"
    assert UserRole.COORDINATOR == "coordinator"
    assert UserRole.SUPERVISOR == "supervisor"
    assert UserRole.OPS_HEAD == "ops_head"
    assert UserRole.ADMIN == "admin"
