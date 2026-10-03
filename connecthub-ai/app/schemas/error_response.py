"""
ConnectHub AI Engine — Error Response Schema
=============================================

Standardised error envelope returned by all exception handlers.
"""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, List, Optional, Union

from pydantic import BaseModel, Field


class ErrorResponse(BaseModel):
    """
    Standardised error payload returned for all non-2xx responses.

    Attributes:
        success:     Always ``False`` for error responses.
        status_code: HTTP status code mirrored in the body.
        error:       Machine-readable error label (snake_case).
        message:     Human-readable error description.
        path:        The request path that triggered this error.
        timestamp:   ISO-8601 UTC timestamp of when the error occurred.
        details:     Optional list of field-level validation errors.
    """

    success: bool = Field(
        default=False, description="Always False for error responses"
    )
    status_code: int = Field(description="HTTP status code")
    error: str = Field(description="Machine-readable error label")
    message: str = Field(description="Human-readable error description")
    path: str = Field(description="Request path that caused the error")
    timestamp: str = Field(
        default_factory=lambda: datetime.now(timezone.utc).isoformat(),
        description="ISO-8601 UTC timestamp",
    )
    details: Optional[List[Any]] = Field(
        default=None,
        description="Field-level validation details (present for 422 errors)",
    )
