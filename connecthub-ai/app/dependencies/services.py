"""
ConnectHub AI Engine — Dependency Injection Providers
======================================================

FastAPI dependency functions (``Depends(...)`` targets) for all services.

All service instances are created as singletons at module level and
injected into route handlers, ensuring:
  - One Gemini client per process (API key configured once)
  - Shared PDF and validation services
  - Easy swapping in tests via ``app.dependency_overrides``

Usage in a router:
    from fastapi import Depends
    from app.dependencies.services import get_gemini_service, get_portfolio_service

    @router.post("/ai/cv/parse")
    async def parse_cv(
        gemini: GeminiService = Depends(get_gemini_service),
        portfolio_svc: PortfolioService = Depends(get_portfolio_service),
    ):
        ...
"""

from __future__ import annotations

from functools import lru_cache

from app.config.settings import get_settings
from app.services.gemini_service import GeminiService
from app.services.pdf_service import PDFService
from app.services.portfolio_service import PortfolioService
from app.services.upload_service import UploadService
from app.services.validation_service import ValidationService


@lru_cache(maxsize=1)
def get_gemini_service() -> GeminiService:
    """
    Return the singleton :class:`GeminiService` instance.

    The Gemini client is initialized lazily on the first request.
    """
    return GeminiService()


@lru_cache(maxsize=1)
def get_pdf_service() -> PDFService:
    """Return the singleton :class:`PDFService` instance."""
    return PDFService()


@lru_cache(maxsize=1)
def get_validation_service() -> ValidationService:
    """Return the singleton :class:`ValidationService` instance."""
    return ValidationService()


@lru_cache(maxsize=1)
def get_upload_service() -> UploadService:
    """Return the singleton :class:`UploadService` instance."""
    return UploadService(
        settings=get_settings(),
        validator=get_validation_service(),
    )


@lru_cache(maxsize=1)
def get_portfolio_service() -> PortfolioService:
    """
    Return the singleton :class:`PortfolioService` with all dependencies
    pre-wired.
    """
    return PortfolioService(
        gemini=get_gemini_service(),
        pdf=get_pdf_service(),
        validator=get_validation_service(),
        settings=get_settings(),
    )
