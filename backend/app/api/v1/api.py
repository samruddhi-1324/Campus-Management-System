from fastapi import APIRouter
from app.api.v1.endpoints import (
    auth,
    users,
    issues,
    attachments,
    notifications,
    admin,
    analytics,
    ai_advisory,
    webhooks,
)

api_router = APIRouter()

# Health check
@api_router.get("/health", tags=["System"])
async def health_check():
    return {"status": "healthy", "service": "Campus Care API", "version": "1.0.0"}

# Mount Phase 1 MVP Feature Routers
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication & RBAC"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(issues.router, prefix="/issues", tags=["Issues & Lifecycle"])
api_router.include_router(attachments.router, prefix="/attachments", tags=["Attachments & Storage"])
api_router.include_router(notifications.router, prefix="/notifications", tags=["Notifications"])
api_router.include_router(admin.router, prefix="/admin", tags=["Admin & Master Data"])
api_router.include_router(analytics.router, prefix="/analytics", tags=["Analytics & Ops Head"])
api_router.include_router(ai_advisory.router, prefix="/ai", tags=["AI Advisory Subsystem"])
api_router.include_router(webhooks.router, prefix="/webhooks", tags=["Delivery Webhooks"])
