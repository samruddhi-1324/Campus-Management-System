from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.api import api_router
from app.core.config import settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Initialize background workers, connection pool check
    yield
    # Shutdown: Close database pools, flush caches


app = FastAPI(
    title=settings.APP_NAME,
    description="Campus Care — AI-Powered Facilities & Academic Issue Tracker API",
    version="1.0.0",
    openapi_url="/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# Set CORS middleware
if settings.cors_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

# Include API v1 router and root router for multi-client compatibility
app.include_router(api_router, prefix=settings.API_V1_STR)
app.include_router(api_router)


@app.get("/")
async def root():
    return {
        "app": settings.APP_NAME,
        "environment": settings.ENVIRONMENT,
        "status": "online",
        "docs": f"{settings.API_V1_STR}/docs",
    }
