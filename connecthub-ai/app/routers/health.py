"""
ConnectHub AI Engine — Health Router
======================================

Provides the ``GET /health`` endpoint used for:
  - Load balancer health checks
  - Docker HEALTHCHECK instructions
  - Uptime monitoring services
  - Deployment readiness probes

This router is always available and never requires authentication.
"""

from __future__ import annotations

from fastapi import APIRouter
from fastapi.responses import JSONResponse

router = APIRouter(tags=["Health"])


@router.get(
    "/health",
    summary="Service health check",
    description=(
        "Returns the operational status of the ConnectHub AI Engine. "
        "Always responds with HTTP 200 when the service is running."
    ),
    response_description="Service status payload",
)
async def health_check() -> JSONResponse:
    """
    Health check endpoint.

    Returns:
        JSON with service status, name, and version.
    """
    return JSONResponse(
        content={
            "status": "ok",
            "service": "ConnectHub AI Engine",
            "version": "1.0.0",
        }
    )
