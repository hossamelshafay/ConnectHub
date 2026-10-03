"""
ConnectHub AI Engine — Application Entry Point
================================================

Creates and configures the FastAPI application with:
  - Structured logging (structlog)
  - Firebase Admin SDK initialization
  - Gemini client initialization (lazy — validates config on startup)
  - CORS middleware
  - Request logging middleware
  - Centralized exception handlers
  - All routers (health, ai, portfolio)
  - Interactive API docs (disabled in production)

Run locally:
    uvicorn app.main:app --reload

Docker:
    CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
"""

from __future__ import annotations

from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.config.settings import settings
from app.core.exceptions import (
    http_exception_handler,
    unhandled_exception_handler,
    validation_exception_handler,
)
from app.core.firebase import initialize_firebase
from app.core.logging import configure_logging, get_logger
from app.dependencies.services import get_gemini_service
from app.middleware.request_logging import RequestLoggingMiddleware
from app.routers import ai, health, portfolio

# ── Bootstrap logging before anything else ───────────────────────────────────
configure_logging(debug=settings.debug)
logger = get_logger(__name__)


# ── Lifespan (startup / shutdown) ─────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """
    Application lifespan context manager.

    Startup:
      1. Log service information.
      2. Initialize Firebase Admin SDK.
      3. Initialize Gemini client (validates API key).

    Shutdown:
      - Log graceful shutdown message.
    """
    # ── Startup ───────────────────────────────────────────────────────────────
    logger.info(
        "service.starting",
        service=settings.project_name,
        version=settings.version,
        environment=settings.app_env,
        debug=settings.debug,
    )

    # Initialize Firebase
    try:
        initialize_firebase(
            credentials_path=settings.firebase_credentials_path,
            credentials_json=settings.firebase_credentials_json,
            project_id=settings.firebase_project_id,
        )
    except Exception as exc:
        logger.warning(
            "firebase.startup_warning",
            error=str(exc),
            hint="Firebase features will be unavailable until credentials are configured.",
        )

    # Initialize Gemini (lazy — only logs a warning if key is absent)
    try:
        gemini = get_gemini_service()
        gemini.initialize()
    except Exception as exc:
        logger.warning(
            "gemini.startup_warning",
            error=str(exc),
            hint="AI features will be unavailable until GEMINI_API_KEY is set.",
        )

    # Initialize storage directory
    try:
        storage_path = settings.upload_temp_dir_path
        logger.info("storage.ready", path=str(storage_path))
    except Exception as exc:
        logger.error("storage.startup_error", error=str(exc))

    logger.info("service.ready", host=settings.host, port=settings.port)

    yield  # ── Application is running ──────────────────────────────────────

    # ── Shutdown ──────────────────────────────────────────────────────────────
    logger.info(
        "service.shutdown",
        service=settings.project_name,
        version=settings.version,
    )


# ── FastAPI application ───────────────────────────────────────────────────────
def create_app() -> FastAPI:
    """
    Factory function that assembles and returns the FastAPI application.

    Using a factory makes the app importable for testing without side effects.
    """
    app = FastAPI(
        title=settings.project_name,
        version=settings.version,
        description=(
            "ConnectHub AI Engine — Standalone AI backend powering CV parsing, "
            "portfolio generation, resume review, ATS analysis, and more."
        ),
        docs_url="/docs" if not settings.is_production else None,
        redoc_url="/redoc" if not settings.is_production else None,
        openapi_url="/openapi.json" if not settings.is_production else None,
        lifespan=lifespan,
    )

    # ── CORS ──────────────────────────────────────────────────────────────────
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins_list,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ── Request logging ───────────────────────────────────────────────────────
    app.add_middleware(RequestLoggingMiddleware)

    # ── Exception handlers ────────────────────────────────────────────────────
    app.add_exception_handler(StarletteHTTPException, http_exception_handler)  # type: ignore[arg-type]
    app.add_exception_handler(RequestValidationError, validation_exception_handler)  # type: ignore[arg-type]
    app.add_exception_handler(Exception, unhandled_exception_handler)

    # ── Routers ───────────────────────────────────────────────────────────────
    app.include_router(health.router)           # GET /health
    app.include_router(ai.router)               # /ai/*  (Phase 2)
    app.include_router(portfolio.router)        # /portfolio/*  (Phase 2)

    return app


app: FastAPI = create_app()
