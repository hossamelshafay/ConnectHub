"""
ConnectHub AI Engine — Request Logging Middleware
=================================================

Logs every HTTP request with:
  - Method & path
  - Status code
  - Execution time (ms)
  - Success / failure flag

Implemented as a pure ASGI middleware for minimal overhead.
"""

from __future__ import annotations

import time

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

from app.core.logging import get_logger

logger = get_logger(__name__)


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """
    ASGI middleware that emits one structured log entry per request.

    Logged fields
    -------------
    event        : always ``"http_request"``
    method       : HTTP verb (GET, POST, …)
    path         : URL path without query string
    status_code  : HTTP response status code
    duration_ms  : wall-clock time in milliseconds
    success      : True when status < 400
    """

    async def dispatch(self, request: Request, call_next) -> Response:  # type: ignore[override]
        start = time.perf_counter()
        response: Response

        try:
            response = await call_next(request)
        except Exception:
            # Let the exception propagate; the unhandled_exception_handler
            # in core/exceptions.py will produce the HTTP 500 response.
            raise
        finally:
            duration_ms = round((time.perf_counter() - start) * 1000, 2)

        logger.info(
            "http_request",
            method=request.method,
            path=request.url.path,
            status_code=response.status_code,
            duration_ms=duration_ms,
            success=response.status_code < 400,
        )

        return response
