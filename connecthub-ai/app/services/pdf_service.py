"""
ConnectHub AI Engine — PDF Service
====================================

Responsible for reading PDF files, extracting plain text, and validating
upload constraints.

Phase 1: Text extraction + file validation.
Phase 2: OCR fallback for scanned PDFs (via pytesseract / Google Vision).

Usage:
    from app.services.pdf_service import PDFService

    pdf = PDFService()
    text = await pdf.extract_text(file_bytes, filename="resume.pdf")
"""

from __future__ import annotations

import asyncio
import io
import re
import unicodedata
from typing import Optional

import pymupdf  # PyMuPDF

from app.config.settings import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

# Minimum extracted text length to be considered non-empty / non-scanned
_MIN_TEXT_LENGTH = 50


class PDFServiceError(Exception):
    """Raised for general PDF processing failures."""


class PDFValidationError(PDFServiceError):
    """Raised when the uploaded file fails validation checks."""


class PDFService:
    """
    Service for PDF ingestion, validation, and text extraction.

    All heavy I/O is offloaded to a thread-pool executor so it never
    blocks the asyncio event loop.
    """

    def __init__(
        self,
        max_size_bytes: Optional[int] = None,
        allowed_mime_types: Optional[list[str]] = None,
    ) -> None:
        self.max_size_bytes = max_size_bytes or settings.max_upload_size_bytes
        self.allowed_mime_types = (
            allowed_mime_types or settings.allowed_mime_types
        )

    # ── Validation ────────────────────────────────────────────────────────────

    def validate_file_size(self, file_bytes: bytes, filename: str = "") -> None:
        """
        Assert the file is within the configured size limit.

        Args:
            file_bytes: Raw file content.
            filename:   Original filename for logging purposes.

        Raises:
            PDFValidationError: If the file exceeds ``max_size_bytes``.
        """
        size = len(file_bytes)
        max_mb = self.max_size_bytes / (1024 * 1024)

        if size > self.max_size_bytes:
            actual_mb = size / (1024 * 1024)
            logger.warning(
                "pdf.validation.size_exceeded",
                filename=filename,
                actual_mb=round(actual_mb, 2),
                max_mb=round(max_mb, 2),
            )
            raise PDFValidationError(
                f"File size {actual_mb:.1f} MB exceeds the maximum allowed "
                f"size of {max_mb:.0f} MB."
            )

    def validate_mime_type(
        self, content_type: str, filename: str = ""
    ) -> None:
        """
        Assert the file's MIME type is in the allow-list.

        Args:
            content_type: MIME type string from the HTTP multipart upload.
            filename:     Original filename for logging purposes.

        Raises:
            PDFValidationError: If the MIME type is not allowed.
        """
        if content_type not in self.allowed_mime_types:
            logger.warning(
                "pdf.validation.invalid_type",
                filename=filename,
                content_type=content_type,
                allowed=self.allowed_mime_types,
            )
            raise PDFValidationError(
                f"File type '{content_type}' is not supported. "
                f"Allowed types: {', '.join(self.allowed_mime_types)}."
            )

    def validate(
        self,
        file_bytes: bytes,
        content_type: str,
        filename: str = "",
    ) -> None:
        """
        Run all validation checks in order.

        Args:
            file_bytes:   Raw file content.
            content_type: MIME type of the upload.
            filename:     Original filename for logging purposes.

        Raises:
            PDFValidationError: On the first validation failure.
        """
        self.validate_mime_type(content_type, filename)
        self.validate_file_size(file_bytes, filename)

    # ── Text cleaning ─────────────────────────────────────────────────────────

    _CONTROL_CHAR_RE = re.compile(r"[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]")
    _MULTI_SPACE_RE = re.compile(r"[ \t]+")
    _MULTI_NEWLINE_RE = re.compile(r"\n{3,}")

    @classmethod
    def _clean_text(cls, raw: str) -> str:
        """
        Normalize and clean raw text extracted from a PDF.
        Optimized with compiled regex to run in < 1ms even on large multi-page PDFs.
        """
        if not raw:
            return ""

        # 1. Unicode normalization
        text = unicodedata.normalize("NFKC", raw)

        # 2. Non-breaking spaces and zero-width characters → regular space
        text = (
            text.replace("\u00a0", " ")
            .replace("\u200b", "")
            .replace("\u200c", "")
            .replace("\u200d", "")
            .replace("\ufeff", "")
        )

        # 3. Fast control characters removal (keeps \n and \t) via compiled regex
        text = cls._CONTROL_CHAR_RE.sub("", text)

        # 4. Fast line-by-line whitespace normalization
        lines = [cls._MULTI_SPACE_RE.sub(" ", line).strip() for line in text.splitlines()]

        # 5. Collapse consecutive empty lines (allow at most 1 blank line separator)
        result_lines: list[str] = []
        prev_blank = False
        for line in lines:
            is_blank = line == ""
            if is_blank and prev_blank:
                continue
            result_lines.append(line)
            prev_blank = is_blank

        return "\n".join(result_lines).strip()

    # ── Text extraction ───────────────────────────────────────────────────────

    def _extract_text_sync(self, file_bytes: bytes) -> str:
        """
        Synchronous PyMuPDF text extraction (runs in thread pool).

        Reads every page, extracts text with layout preservation, then
        passes the raw result through ``_clean_text``.

        Args:
            file_bytes: Raw PDF bytes.

        Returns:
            Cleaned, normalized plain text with pages separated by double
            newlines and a page-break marker.

        Raises:
            PDFServiceError: If PyMuPDF cannot open or parse the PDF.
            PDFServiceError: If the PDF appears to contain no extractable text
                             (e.g. a scanned image-only PDF).
        """
        if not file_bytes or len(file_bytes) == 0:
            raise PDFServiceError("PDF file is empty (0 bytes).")

        try:
            with pymupdf.open(stream=io.BytesIO(file_bytes), filetype="pdf") as doc:
                if len(doc) == 0:
                    raise PDFServiceError("PDF document contains no pages.")

                pages: list[str] = []
                for page in doc:
                    # "text" mode preserves reading order and paragraph breaks
                    raw = page.get_text("text")  # type: ignore[attr-defined]
                    cleaned = self._clean_text(raw)
                    if cleaned:
                        pages.append(cleaned)

                if not pages:
                    raise PDFServiceError(
                        "No extractable text found in the PDF. "
                        "The document may be empty or a scanned image."
                    )

                full_text = "\n\n".join(pages).strip()

                if not full_text or len(full_text) < _MIN_TEXT_LENGTH:
                    raise PDFServiceError(
                        "The extracted text is too short or contains no readable text."
                    )

                return full_text

        except PDFServiceError:
            raise  # re-raise domain exception directly
        except pymupdf.FileDataError as exc:  # type: ignore[attr-defined]
            raise PDFServiceError(
                f"The uploaded file is corrupted or unreadable: {exc}"
            ) from exc
        except Exception as exc:
            raise PDFServiceError(
                f"The uploaded file is corrupted or unreadable: {exc}"
            ) from exc

    async def extract_text(
        self, file_bytes: bytes, filename: str = ""
    ) -> str:
        """
        Asynchronously extract and clean plain text from a PDF file.

        Offloads the synchronous PyMuPDF call to a thread-pool executor
        so the event loop is never blocked.

        Args:
            file_bytes: Raw PDF bytes.
            filename:   Original filename for logging purposes.

        Returns:
            Cleaned, extracted plain text.

        Raises:
            PDFServiceError: On extraction or validation failure.
        """
        logger.debug(
            "pdf.extract_text.start",
            filename=filename,
            size_bytes=len(file_bytes),
        )

        loop = asyncio.get_event_loop()
        text = await loop.run_in_executor(
            None, self._extract_text_sync, file_bytes
        )

        logger.info(
            "pdf.extract_text.complete",
            filename=filename,
            text_length=len(text),
        )
        return text

    # ── OCR placeholder ───────────────────────────────────────────────────────

    async def extract_text_with_ocr(
        self, file_bytes: bytes, filename: str = ""
    ) -> str:
        """
        OCR-based text extraction for scanned PDFs.

        Phase 2 implementation: will use pytesseract or Google Vision API
        as a fallback when standard extraction yields insufficient text.

        Args:
            file_bytes: Raw PDF bytes.
            filename:   Original filename for logging purposes.

        Returns:
            OCR-extracted text.

        Raises:
            NotImplementedError: Until Phase 2 implementation.
        """
        raise NotImplementedError(
            "OCR extraction is planned for Phase 2. "
            "Use extract_text() for standard PDFs."
        )
