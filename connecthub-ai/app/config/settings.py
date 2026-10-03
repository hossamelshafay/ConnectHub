"""
ConnectHub AI Engine — Centralized Application Settings
========================================================

All configuration is loaded from environment variables.
No secrets are ever hardcoded.

Usage:
    from app.config.settings import settings
"""

from __future__ import annotations

from functools import lru_cache
from pathlib import Path
from typing import List

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Centralized settings loaded from environment variables / .env file.

    Fields map directly to the keys in .env.example.
    Pydantic-settings handles coercion and validation automatically.
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ── Application ──────────────────────────────────────────────────────────
    app_env: str = Field(default="development", description="Runtime environment")
    project_name: str = Field(
        default="ConnectHub AI Engine", description="Human-readable service name"
    )
    version: str = Field(default="1.0.0", description="API version")
    debug: bool = Field(default=False, description="Enable debug mode")

    # ── Server ───────────────────────────────────────────────────────────────
    host: str = Field(default="0.0.0.0", description="Uvicorn bind host")
    port: int = Field(default=8000, description="Uvicorn bind port")

    # ── Google Gemini ─────────────────────────────────────────────────────────
    gemini_api_key: str = Field(
        default="", description="Google Gemini API key — never hardcode"
    )
    gemini_model: str = Field(
        default="gemini-3.8-flash", description="Gemini model name"
    )
    gemini_timeout_seconds: int = Field(
        default=180, description="Per-request timeout for Gemini calls"
    )
    gemini_max_retries: int = Field(
        default=3, description="Max retry attempts for transient Gemini errors"
    )

    # ── Firebase ─────────────────────────────────────────────────────────────
    firebase_credentials_path: str = Field(
        default="",
        description="Path to Firebase service-account JSON file",
    )
    firebase_credentials_json: str = Field(
        default="",
        description="Base64-encoded Firebase service-account JSON (for Docker/Cloud)",
    )
    firebase_project_id: str = Field(
        default="", description="Firebase project ID"
    )

    # ── File Uploads ─────────────────────────────────────────────────────────
    max_upload_size_mb: int = Field(
        default=10, description="Maximum allowed file upload size in megabytes"
    )
    upload_temp_directory: str = Field(
        default="storage/uploads",
        description="Directory path for temporary uploaded files",
    )
    allowed_upload_extensions: str = Field(
        default=".pdf",
        description="Comma-separated list of allowed file extensions",
    )
    allowed_upload_mime_types: str = Field(
        default="application/pdf",
        description="Comma-separated list of allowed MIME types",
    )
    allowed_file_types: str = Field(
        default="application/pdf",
        description="Backward-compatible comma-separated list of allowed MIME types",
    )

    # ── CORS ─────────────────────────────────────────────────────────────────
    cors_origins: str = Field(
        default="http://localhost:3000",
        description="Comma-separated list of allowed CORS origins",
    )

    # ── Derived helpers ───────────────────────────────────────────────────────
    @property
    def max_upload_size_bytes(self) -> int:
        """Upload limit in bytes, derived from `max_upload_size_mb`."""
        return self.max_upload_size_mb * 1024 * 1024

    @property
    def allowed_extensions_list(self) -> List[str]:
        """Parsed list of allowed file extensions (lowercase, normalized with leading dot)."""
        extensions = [
            ext.strip().lower()
            for ext in self.allowed_upload_extensions.split(",")
            if ext.strip()
        ]
        return [ext if ext.startswith(".") else f".{ext}" for ext in extensions]

    @property
    def allowed_mime_types_list(self) -> List[str]:
        """Parsed list of allowed MIME types (lowercase)."""
        raw = self.allowed_upload_mime_types or self.allowed_file_types
        return [t.strip().lower() for t in raw.split(",") if t.strip()]

    @property
    def allowed_mime_types(self) -> List[str]:
        """Backward-compatible alias for allowed_mime_types_list."""
        return self.allowed_mime_types_list

    @property
    def upload_temp_dir_path(self) -> Path:
        """
        Resolved absolute Path for the temporary upload directory.
        If a relative path is given, it is resolved relative to the backend project root.
        Creates the directory automatically if it does not already exist.
        """
        raw_path = Path(self.upload_temp_directory)
        if raw_path.is_absolute():
            resolved = raw_path
        else:
            project_root = Path(__file__).resolve().parent.parent.parent
            resolved = (project_root / raw_path).resolve()
        resolved.mkdir(parents=True, exist_ok=True)
        return resolved

    @property
    def cors_origins_list(self) -> List[str]:
        """Parsed list of CORS origins."""
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def is_production(self) -> bool:
        """True when running in a production environment."""
        return self.app_env.lower() == "production"

    @field_validator("gemini_api_key", mode="before")
    @classmethod
    def _warn_empty_gemini_key(cls, value: str) -> str:
        """Warn (but do not fail) if the Gemini key is missing at startup."""
        if not value:
            import warnings
            warnings.warn(
                "GEMINI_API_KEY is not set. Gemini features will be unavailable.",
                stacklevel=2,
            )
        return value


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """
    Return the singleton Settings instance.

    Uses ``@lru_cache`` so the .env file is only parsed once per process.
    Call ``get_settings.cache_clear()`` in tests to reload config.
    """
    return Settings()


# Module-level convenience alias
settings: Settings = get_settings()
