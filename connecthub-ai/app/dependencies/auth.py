"""
ConnectHub AI Engine — Authentication Dependency (Stub)
=========================================================

Phase 2: Firebase Authentication middleware.

Will extract and verify Firebase ID tokens from the
``Authorization: Bearer <token>`` header on protected routes.

Phase 1: Stub that raises NotImplementedError to make the dependency
explicit and prevent accidental use before it is implemented.

Usage (Phase 2):
    from fastapi import Depends
    from app.dependencies.auth import get_current_user

    @router.post("/portfolio/create")
    async def create_portfolio(
        current_user: str = Depends(get_current_user),
    ):
        # current_user is the Firebase UID of the authenticated user
        ...
"""

from __future__ import annotations

from fastapi import HTTPException, Request, status
from firebase_admin import auth as firebase_auth

from app.core.logging import get_logger

logger = get_logger(__name__)


async def get_current_user(request: Request) -> str:
    """
    Extract and verify the Firebase ID token from the Authorization header.

    Args:
        request: The incoming HTTP request.

    Returns:
        The Firebase UID (``uid``) of the authenticated user.

    Raises:
        HTTPException(401): If the token is missing, expired, or invalid.

    Note:
        Phase 2 implementation. Currently raises ``NotImplementedError``
        to prevent accidental use on unprotected routes.
    """
    # ── Phase 2: Uncomment and implement ──────────────────────────────────────
    # authorization = request.headers.get("Authorization", "")
    # if not authorization.startswith("Bearer "):
    #     raise HTTPException(
    #         status_code=status.HTTP_401_UNAUTHORIZED,
    #         detail="Missing or invalid Authorization header.",
    #     )
    #
    # id_token = authorization.removeprefix("Bearer ").strip()
    # try:
    #     decoded = firebase_auth.verify_id_token(id_token)
    #     return decoded["uid"]
    # except firebase_auth.ExpiredIdTokenError:
    #     raise HTTPException(status_code=401, detail="Token has expired.")
    # except firebase_auth.InvalidIdTokenError:
    #     raise HTTPException(status_code=401, detail="Invalid token.")
    # except Exception as exc:
    #     logger.error("auth.verification_failed", error=str(exc))
    #     raise HTTPException(status_code=500, detail="Authentication error.")
    # ─────────────────────────────────────────────────────────────────────────

    raise NotImplementedError(
        "Firebase authentication is planned for Phase 2. "
        "Do not add Depends(get_current_user) to routes until then."
    )
