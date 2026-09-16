from fastapi import APIRouter

api_router = APIRouter()

# Health check endpoint
@api_router.get("/health", tags=["System"])
async def health_check():
    return {"status": "healthy", "service": "Campus Care API", "version": "1.0.0"}

# Feature sub-routers will be mounted here in subsequent phases:
# - auth (Phase 1)
# - users (Phase 1)
# - issues (Phase 1)
# - attachments (Phase 1)
# - notifications (Phase 1)
# - admin (Phase 1)
# - analytics (Phase 1)
# - academic (Phase 2)
# - recommendations (Phase 2)
