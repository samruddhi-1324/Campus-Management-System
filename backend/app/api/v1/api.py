from fastapi import APIRouter

from app.api.v1.endpoints import (
    academic,
    admin,
    ai_advisory,
    analytics,
    attachments,
    auth,
    historical_analytics,
    issues,
    notifications,
    recommendations,
    recurrence,
    search,
    sla,
    tenants,
    users,
    voice,
    webhooks,
)

api_router = APIRouter()


# Health check
@api_router.get("/health", tags=["System"])
async def health_check():
    return {"status": "healthy", "service": "Campus Care API", "version": "3.0.0"}


# Phase 1 MVP Feature Routers
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication & RBAC"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(issues.router, prefix="/issues", tags=["Issues & Lifecycle"])
api_router.include_router(attachments.router, prefix="/attachments", tags=["Attachments & Storage"])
api_router.include_router(notifications.router, prefix="/notifications", tags=["Notifications"])
api_router.include_router(admin.router, prefix="/admin", tags=["Admin & Master Data"])
api_router.include_router(analytics.router, prefix="/analytics", tags=["Analytics & Ops Head"])
api_router.include_router(ai_advisory.router, prefix="/ai", tags=["AI Advisory Subsystem"])
api_router.include_router(webhooks.router, prefix="/webhooks", tags=["Delivery Webhooks"])

# Phase 2 Feature Routers
api_router.include_router(academic.router, prefix="/academic", tags=["Academic Concerns (Phase 2)"])
api_router.include_router(recommendations.router, prefix="/recommendations", tags=["AI Recommendations (Phase 2)"])
api_router.include_router(recurrence.router, prefix="/recurrence", tags=["Recurrence Detection (Phase 2)"])
api_router.include_router(sla.router, prefix="/sla", tags=["SLA Enhancements (Phase 2)"])

# Phase 3 Feature Routers
api_router.include_router(voice.router, prefix="/voice", tags=["Voice Input (Phase 3)"])
api_router.include_router(search.router, prefix="/search", tags=["Natural Language Search (Phase 3)"])
api_router.include_router(tenants.router, prefix="/tenants", tags=["Multi-Institution Support (Phase 3)"])
api_router.include_router(historical_analytics.router, prefix="/historical-analytics", tags=["Historical Pattern Mining (Phase 3)"])
