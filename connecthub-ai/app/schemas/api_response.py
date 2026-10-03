"""
ConnectHub AI Engine — API Response Schema
==========================================

Standardised success response wrapper used by all endpoints.
"""

from __future__ import annotations

from typing import Any, Generic, Optional, TypeVar

from pydantic import BaseModel, Field

T = TypeVar("T")


class ApiResponse(BaseModel, Generic[T]):
    """
    Generic success response envelope.

    All successful API responses are wrapped in this schema to provide
    a consistent, predictable structure for client consumers.

    Attributes:
        success:  Always ``True`` for 2xx responses.
        message:  Human-readable summary of the result.
        data:     The actual response payload (type-parameterized).
        version:  API version string, e.g. ``"1.0.0"``.
    """

    success: bool = Field(default=True, description="Indicates the request succeeded")
    message: str = Field(description="Human-readable result summary")
    data: Optional[T] = Field(default=None, description="Response payload")
    version: str = Field(default="1.0.0", description="API version")

    model_config = {"arbitrary_types_allowed": True}
