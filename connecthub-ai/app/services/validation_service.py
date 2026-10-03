"""
ConnectHub AI Engine — Validation Service
==========================================

Provides reusable validation utilities for AI-generated JSON payloads
and other data structures across all ConnectHub AI modules.

Phase 1: Skeleton with foundational helpers.
Phase 2: Full JSON schema validation for Gemini responses.

Usage:
    from app.services.validation_service import ValidationService

    validator = ValidationService()
    validator.validate_not_empty(text, field_name="cv_text")
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List, Optional, Type, TypeVar

import pymupdf
from pydantic import BaseModel, ValidationError

from app.core.logging import get_logger

logger = get_logger(__name__)

M = TypeVar("M", bound=BaseModel)


class ValidationServiceError(Exception):
    """Raised when a validation check fails."""


class ValidationService:
    """
    Centralised validation service used by all AI modules.

    Methods here are pure utility functions — they raise descriptive
    exceptions rather than returning boolean flags, making call-sites
    cleaner.
    """

    # ── String / text helpers ─────────────────────────────────────────────────

    @staticmethod
    def validate_not_empty(value: str, field_name: str = "value") -> None:
        """
        Assert a string is non-empty after stripping whitespace.

        Args:
            value:      The string to validate.
            field_name: Name used in the exception message.

        Raises:
            ValidationServiceError: If the string is empty.
        """
        if not value or not value.strip():
            raise ValidationServiceError(
                f"'{field_name}' must not be empty."
            )

    @staticmethod
    def validate_min_length(
        value: str, min_length: int, field_name: str = "value"
    ) -> None:
        """
        Assert a string meets a minimum length requirement.

        Args:
            value:      The string to validate.
            min_length: Minimum required character count.
            field_name: Name used in the exception message.

        Raises:
            ValidationServiceError: If the string is shorter than ``min_length``.
        """
        if len(value.strip()) < min_length:
            raise ValidationServiceError(
                f"'{field_name}' must be at least {min_length} characters long "
                f"(got {len(value.strip())})."
            )

    # ── Pydantic model validation ─────────────────────────────────────────────

    @staticmethod
    def validate_model(
        data: Dict[str, Any],
        model_class: Type[M],
        context: str = "",
    ) -> M:
        """
        Parse and validate a dictionary against a Pydantic model.

        Args:
            data:        The raw dictionary to validate.
            model_class: The Pydantic model class to validate against.
            context:     Optional label for error logging.

        Returns:
            A validated Pydantic model instance.

        Raises:
            ValidationServiceError: If validation fails, with field-level details.
        """
        try:
            return model_class.model_validate(data)
        except ValidationError as exc:
            errors = exc.errors()
            logger.warning(
                "validation.model_failed",
                model=model_class.__name__,
                context=context,
                error_count=len(errors),
            )
            raise ValidationServiceError(
                f"Data validation failed for {model_class.__name__}"
                + (f" [{context}]" if context else "")
                + f": {errors}"
            ) from exc

    # ── JSON validation ───────────────────────────────────────────────────────

    @staticmethod
    def validate_required_keys(
        data: Dict[str, Any],
        required_keys: List[str],
        context: str = "",
    ) -> None:
        """
        Assert that a dictionary contains all required top-level keys.

        Args:
            data:          Dictionary to inspect.
            required_keys: Keys that must be present.
            context:       Optional label for error logging.

        Raises:
            ValidationServiceError: If any key is missing.
        """
        missing = [k for k in required_keys if k not in data]
        if missing:
            logger.warning(
                "validation.missing_keys",
                missing=missing,
                context=context,
            )
            raise ValidationServiceError(
                f"Missing required keys: {missing}"
                + (f" [{context}]" if context else "")
            )

    # ── File and Upload Validation (Phase 2.1) ────────────────────────────────

    @staticmethod
    def validate_file_presence(filename: Optional[str]) -> None:
        """
        Validate that a file is present and has a non-empty filename.

        Raises:
            ValidationServiceError: If filename is None or empty.
        """
        if not filename or not filename.strip():
            raise ValidationServiceError("No file was provided in the upload request.")

    @staticmethod
    def validate_file_extension(filename: str, allowed_extensions: List[str]) -> None:
        """
        Validate that the file extension is allowed.

        Raises:
            ValidationServiceError: If extension is not allowed.
        """
        ext = Path(filename).suffix.lower()
        if not ext or ext not in allowed_extensions:
            allowed_str = ", ".join(allowed_extensions)
            raise ValidationServiceError(
                f"Invalid file extension '{ext or 'none'}'. Allowed extensions: {allowed_str}."
            )

    @staticmethod
    def validate_mime_type(content_type: Optional[str], allowed_mime_types: List[str]) -> None:
        """
        Validate that the MIME type is allowed.

        Raises:
            ValidationServiceError: If MIME type is missing or not allowed.
        """
        normalized_mime = (content_type or "").lower().strip()
        if not normalized_mime or normalized_mime not in allowed_mime_types:
            allowed_str = ", ".join(allowed_mime_types)
            raise ValidationServiceError(
                f"Invalid MIME type '{content_type or 'unknown'}'. Allowed MIME types: {allowed_str}."
            )

    @staticmethod
    def validate_file_size(size_bytes: int, max_bytes: int, max_mb: int) -> None:
        """
        Validate that the file size is non-empty and does not exceed maximum limit.

        Raises:
            ValidationServiceError: If file is empty or exceeds limit.
        """
        if size_bytes <= 0:
            raise ValidationServiceError("Uploaded file is empty (0 bytes).")
        if size_bytes > max_bytes:
            raise ValidationServiceError(
                f"File size exceeds maximum allowed limit of {max_mb} MB."
            )

    @staticmethod
    def validate_pdf_magic_bytes(header: bytes) -> None:
        """
        Validate that the initial bytes match the standard PDF signature (%PDF-).
        Prevents executable files or renamed documents from being accepted.

        Raises:
            ValidationServiceError: If header does not begin with %PDF-.
        """
        if not header.startswith(b"%PDF-"):
            raise ValidationServiceError(
                "Corrupted file or invalid PDF header. The file does not conform to the PDF standard."
            )

    @staticmethod
    def validate_pdf_integrity(content: bytes) -> int:
        """
        Validate that the PDF is structurally valid and can be opened without error.
        Does NOT perform any text extraction, OCR, or parsing.

        Returns:
            The number of pages in the PDF document.

        Raises:
            ValidationServiceError: If document is corrupted or contains 0 pages.
        """
        try:
            doc = pymupdf.open(stream=content, filetype="pdf")
            page_count = len(doc)
            doc.close()
            if page_count < 1:
                raise ValueError("PDF document contains no pages.")
            return page_count
        except Exception as exc:
            logger.warning("validation.pdf_corrupted", error=str(exc))
            raise ValidationServiceError(
                "Corrupted file or unreadable PDF structure."
            ) from exc

    # ── Gemini response validation ───────────────────────────────────────────

    @staticmethod
    def clean_json_string(raw: str) -> str:
        """
        Clean potential markdown code blocks or surrounding text from Gemini.
        E.g. ```json\n{...}\n``` or ```{...}```
        """
        text = raw.strip()
        # Remove opening ```json or ```
        if text.startswith("```"):
            lines = text.splitlines()
            if lines and lines[0].startswith("```"):
                lines = lines[1:]
            if lines and lines[-1].strip() == "```":
                lines = lines[:-1]
            text = "\n".join(lines).strip()

        # If there's still text before the first '{' or after the last '}', slice to JSON boundaries
        start = text.find("{")
        end = text.rfind("}")
        if start != -1 and end != -1 and end >= start:
            text = text[start : end + 1]

        return text

    def validate_gemini_json_response(
        self,
        raw_response: str,
        expected_model: Type[M],
        context: str = "gemini_response",
    ) -> M:
        """
        Parse and validate a Gemini JSON string response into the expected Pydantic model.

        Strips any markdown code fences, handles malformed JSON, and enforces
        the model schema while filling safe defaults.

        Args:
            raw_response:    Raw text returned by Gemini.
            expected_model:  Pydantic model to validate against.
            context:         Optional label for logging and error reporting.

        Returns:
            A validated Pydantic model instance.

        Raises:
            ValidationServiceError: If the JSON cannot be parsed or fails schema validation.
        """
        if not raw_response or not raw_response.strip():
            raise ValidationServiceError("Gemini returned an empty response.")

        cleaned_json = self.clean_json_string(raw_response)

        try:
            parsed = json.loads(cleaned_json)
        except json.JSONDecodeError as exc:
            logger.error(
                "validation.gemini_json_decode_failed",
                error=str(exc),
                raw_preview=raw_response[:200],
            )
            raise ValidationServiceError(
                f"Gemini did not return valid JSON: {exc}"
            ) from exc

        if not isinstance(parsed, dict):
            raise ValidationServiceError(
                f"Expected a JSON object from Gemini, got {type(parsed).__name__}."
            )

        return self.validate_model(parsed, expected_model, context=context)


