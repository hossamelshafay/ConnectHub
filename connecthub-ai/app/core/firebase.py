"""
ConnectHub AI Engine — Firebase Initializer
============================================

Establishes the Firebase Admin SDK connection on startup.
No data is read or written here — only the app is initialized.

Supports two credential sources (in priority order):
  1. ``FIREBASE_CREDENTIALS_JSON`` — base64-encoded service-account JSON
     (preferred for Docker / Cloud Run / CI environments).
  2. ``FIREBASE_CREDENTIALS_PATH`` — local path to a service-account JSON file.

Usage:
    from app.core.firebase import initialize_firebase

    # Called once in main.py lifespan
    initialize_firebase()
"""

from __future__ import annotations

import base64
import json
import os
from typing import Optional

import firebase_admin
from firebase_admin import credentials

from app.core.logging import get_logger

logger = get_logger(__name__)


def _build_credentials(
    credentials_path: str,
    credentials_json: str,
) -> Optional[credentials.Base]:
    """
    Resolve Firebase credentials from environment variables.

    Args:
        credentials_path: Filesystem path to a service-account JSON file.
        credentials_json: Base64-encoded service-account JSON string.

    Returns:
        A :class:`firebase_admin.credentials.Base` instance, or ``None``
        if no credentials are configured (emulator / test mode).
    """
    if credentials_json:
        logger.debug("firebase.credentials", source="env_json")
        try:
            decoded = base64.b64decode(credentials_json).decode("utf-8")
            service_account_info = json.loads(decoded)
            return credentials.Certificate(service_account_info)
        except Exception as exc:
            logger.error(
                "firebase.credentials_json_parse_failed", error=str(exc)
            )
            raise ValueError(
                "FIREBASE_CREDENTIALS_JSON is set but could not be decoded. "
                "Ensure it is valid base64-encoded JSON."
            ) from exc

    if credentials_path and os.path.isfile(credentials_path):
        logger.debug(
            "firebase.credentials", source="file", path=credentials_path
        )
        return credentials.Certificate(credentials_path)

    logger.warning(
        "firebase.no_credentials_configured",
        hint="Set FIREBASE_CREDENTIALS_PATH or FIREBASE_CREDENTIALS_JSON",
    )
    return None


def initialize_firebase(
    credentials_path: str = "",
    credentials_json: str = "",
    project_id: str = "",
) -> None:
    """
    Initialize the Firebase Admin SDK.

    This function is idempotent — calling it multiple times is safe.
    If the default app already exists it returns immediately.

    Args:
        credentials_path: Path to service-account JSON file.
        credentials_json: Base64-encoded service-account JSON.
        project_id:       Firebase project ID (used when credentials are absent).
    """
    if firebase_admin._apps:  # type: ignore[attr-defined]
        logger.debug("firebase.already_initialized")
        return

    creds = _build_credentials(credentials_path, credentials_json)

    options: dict = {}
    if project_id:
        options["projectId"] = project_id

    try:
        if creds:
            firebase_admin.initialize_app(creds, options)
        else:
            # Fall back to Application Default Credentials (e.g. Cloud Run)
            firebase_admin.initialize_app(options=options or None)

        logger.info(
            "firebase.initialized",
            project_id=project_id or "default",
        )
    except Exception as exc:
        logger.error("firebase.initialization_failed", error=str(exc))
        raise
