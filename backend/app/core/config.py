from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    # App Configuration
    ENVIRONMENT: Literal["development", "staging", "production", "test"] = "development"
    DEBUG: bool = True
    APP_NAME: str = "Campus Care"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "temporary-secret-key-change-in-production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # CORS
    BACKEND_CORS_ORIGINS: list[str] = ["*"]

    # Database (Supabase PostgreSQL async pooled connection)
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/campus_care"
    DB_POOL_SIZE: int = 10
    DB_MAX_OVERFLOW: int = 5
    DB_POOL_TIMEOUT: int = 30

    # Supabase Storage Configuration (FR-DATA-18..24)
    SUPABASE_URL: str = "https://your-project.supabase.co"
    SUPABASE_SERVICE_ROLE_KEY: str = "default-service-role-key"
    SUPABASE_STORAGE_BUCKET_ATTACHMENTS: str = "issue-attachments"
    SIGNED_URL_EXPIRATION_SECONDS: int = 3600

    # Redis Configuration
    REDIS_URL: str = "redis://localhost:6379/0"

    # AI Advisory Subsystem Settings (FR-AI-01..20)
    AI_PROVIDER: Literal["anthropic", "openai", "mock"] = "anthropic"
    ANTHROPIC_API_KEY: str | None = None
    OPENAI_API_KEY: str | None = None
    AI_MODEL_NAME: str = "claude-3-7-sonnet-20250219"
    AI_TIMEOUT_SECONDS: int = 15
    AI_DAILY_TOKEN_BUDGET: int = 100000

    # Multi-Channel Notifications (Section 10)
    EMAIL_PROVIDER: Literal["smtp", "brevo", "resend"] = "smtp"
    EMAIL_FALLBACK_PROVIDER: Literal["resend", "brevo", "none"] = "resend"
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    EMAILS_FROM_EMAIL: str = "campuscare-noreply@institution.edu"
    EMAILS_FROM_NAME: str = "Campus Care"

    BREVO_API_KEY: str | None = None
    RESEND_API_KEY: str | None = None

    # SMS Gateway (FR-NOTIF-16)
    SMS_GATEWAY_PROVIDER: str = "twilio"
    SMS_ACCOUNT_SID: str | None = None
    SMS_AUTH_TOKEN: str | None = None
    SMS_FROM_NUMBER: str | None = None

    # WhatsApp Business Cloud API (FR-NOTIF-17)
    WHATSAPP_API_URL: str = "https://graph.facebook.com/v19.0"
    WHATSAPP_PHONE_NUMBER_ID: str | None = None
    WHATSAPP_ACCESS_TOKEN: str | None = None
    WHATSAPP_APP_SECRET: str | None = None

    # Firebase Cloud Messaging (FR-NOTIF-21..29)
    FIREBASE_CREDENTIALS_PATH: str | None = None

    # Client Platform & Versioning (FR-PLAT-16)
    MINIMUM_SUPPORTED_CLIENT_VERSION: str = "1.0.0"


settings = Settings()
