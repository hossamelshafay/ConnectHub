"""
ConnectHub AI Engine — Centralized Exception Handlers
======================================================

All HTTP exceptions and unhandled errors are caught here and converted
into consistent ``ErrorResponse`` JSON payloads.

These handlers are registered in ``main.py`` via
``app.add_exception_handler(...)``.
"""

from __future__ import annotations

import time
from typing import Union

from fastapi import Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.core.logging import get_logger
from app.schemas.error_response import ErrorResponse

logger = get_logger(__name__)


def _error_response(
    status_code: int,
    error: str,
    message: str,
    request: Request,
    details: Union[list, None] = None,
) -> JSONResponse:
    """Build a standardised :class:`ErrorResponse` JSON payload."""
    payload = ErrorResponse(
        status_code=status_code,
        error=error,
        message=message,
        path=str(request.url.path),
        details=details,
    )
    return JSONResponse(
        status_code=status_code,
        content=payload.model_dump(),
    )


async def http_exception_handler(
    request: Request, exc: StarletteHTTPException
) -> JSONResponse:
    """
    Handle all :class:`~starlette.exceptions.HTTPException` instances.

    Maps common status codes to human-friendly ``error`` labels.
    """
    error_map = {
        status.HTTP_400_BAD_REQUEST: "bad_request",
        status.HTTP_401_UNAUTHORIZED: "unauthorized",
        status.HTTP_403_FORBIDDEN: "forbidden",
        status.HTTP_404_NOT_FOUND: "not_found",
        status.HTTP_405_METHOD_NOT_ALLOWED: "method_not_allowed",
        status.HTTP_408_REQUEST_TIMEOUT: "request_timeout",
        status.HTTP_413_CONTENT_TOO_LARGE: "payload_too_large",
        status.HTTP_422_UNPROCESSABLE_CONTENT: "unprocessable_entity",
        status.HTTP_429_TOO_MANY_REQUESTS: "too_many_requests",
        status.HTTP_500_INTERNAL_SERVER_ERROR: "internal_server_error",
        status.HTTP_503_SERVICE_UNAVAILABLE: "service_unavailable",
    }
    error_label = error_map.get(exc.status_code, "http_error")

    logger.warning(
        "http_exception",
        status_code=exc.status_code,
        error=error_label,
        path=str(request.url.path),
        method=request.method,
    )

    return _error_response(
        status_code=exc.status_code,
        error=error_label,
        message=str(exc.detail),
        request=request,
    )


async def validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    """
    Handle Pydantic v2 request validation errors.

    Extracts field-level error details so callers know exactly which
    request fields failed and why.
    """
    details = [
        {
            "field": " -> ".join(str(loc) for loc in err["loc"]),
            "message": err["msg"],
            "type": err["type"],
        }
        for err in exc.errors()
    ]

    logger.warning(
        "validation_error",
        path=str(request.url.path),
        method=request.method,
        error_count=len(details),
    )

    return _error_response(
        status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
        error="validation_error",
        message="Request validation failed. Check the `details` field for specifics.",
        request=request,
        details=details,
    )


async def unhandled_exception_handler(
    request: Request, exc: Exception
) -> JSONResponse:
    """
    Catch-all handler for unexpected server errors.

    Logs the full traceback internally but returns a safe, generic
    message to the caller so internal details are never leaked.
    """
    logger.exception(
        "unhandled_exception",
        path=str(request.url.path),
        method=request.method,
        exc_type=type(exc).__name__,
    )

    return _error_response(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        error="internal_server_error",
        message="An unexpected error occurred. Please try again later.",
        request=request,
    )
