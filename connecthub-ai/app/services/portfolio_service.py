"""
ConnectHub AI Engine — Portfolio Service
=========================================

Orchestrates the full CV-to-Portfolio parsing pipeline.

Pipeline (Phase 3):
    PDF Upload
        ↓
    Validate file (presence, extension, MIME type, size, magic bytes, integrity)
        ↓
    PDFService.extract_text() [clean, normalize unicode, collapse spaces]
        ↓
    GeminiService.generate_portfolio() [Gemini 2.5 Flash, temperature=0, JSON mode]
        ↓
    ValidationService.validate_gemini_json_response() [strip fences, schema validate, fill defaults]
        ↓
    CVPortfolio (Pydantic schema)
        ↓
    Return structured JSON / ApiResponse

No Firestore writes in this phase.
No Flutter integration in this phase.
Backend-only implementation following Feature-First clean layered architecture.

Usage:
    from app.services.portfolio_service import PortfolioService

    service = PortfolioService()
    portfolio = await service.generate_portfolio_from_cv(file)
"""

from __future__ import annotations

import time
from typing import List, Optional, Union

from fastapi import HTTPException, UploadFile, status

from app.config.settings import Settings, get_settings
from app.core.logging import get_logger
from app.schemas.cv_portfolio_schema import CVPortfolio
from app.schemas.portfolio_schema import PortfolioCreateResponse, PortfolioData
from app.schemas.website_schema import WebsitePortfolioInput, WebsitePortfolioOutput
from app.prompts.website_prompt import build_website_prompt
from app.services.gemini_service import (
    GeminiService,
    GeminiServiceError,
    GeminiTimeoutError,
)
from app.services.pdf_service import PDFService, PDFServiceError
from app.services.validation_service import (
    ValidationService,
    ValidationServiceError,
)

logger = get_logger(__name__)

CHUNK_SIZE = 64 * 1024  # 64 KB per read chunk


class PortfolioServiceError(Exception):
    """Raised for general portfolio processing failures."""


class PortfolioService:
    """
    Orchestrates the CV → Portfolio AI pipeline.

    Dependencies are injected via constructor to facilitate unit testing with mocks.

    Args:
        gemini:    Gemini AI client for content generation.
        pdf:       PDF ingestion, cleaning, and text extraction service.
        validator: Data and security validation service.
        settings:  Central application settings.
    """

    def __init__(
        self,
        gemini: Optional[GeminiService] = None,
        pdf: Optional[PDFService] = None,
        validator: Optional[ValidationService] = None,
        settings: Optional[Settings] = None,
    ) -> None:
        self._gemini = gemini or GeminiService()
        self._pdf = pdf or PDFService()
        self._validator = validator or ValidationService()
        self._settings = settings or get_settings()

        logger.debug("portfolio_service.initialized")

    # ── Phase 3 Pipeline ─────────────────────────────────────────────────────

    async def generate_portfolio_from_cv(
        self,
        file: Union[UploadFile, bytes, str, None],
        filename: Optional[str] = None,
        content_type: Optional[str] = None,
        client_ip: str = "unknown",
    ) -> CVPortfolio:
        """
        Execute the full AI CV Parsing pipeline.

        Pipeline:
          1. Validate PDF (presence, extension, MIME type, size, magic bytes, structure).
          2. Extract & clean text using PyMuPDF.
          3. Send text to Gemini 2.5 Flash with structured prompt.
          4. Parse and validate JSON response into CVPortfolio schema.
          5. Return validated CVPortfolio instance.

        Args:
            file:         Uploaded file (UploadFile), raw bytes, or None.
            filename:     Optional filename override when file is raw bytes.
            content_type: Optional MIME type override when file is raw bytes.
            client_ip:    Client IP for audit logging.

        Returns:
            A validated :class:`CVPortfolio` populated from the CV.

        Raises:
            HTTPException(400): If validation or text extraction fails.
            HTTPException(413): If file size exceeds the limit.
            HTTPException(502): If Gemini fails or produces invalid JSON.
            HTTPException(504): If Gemini request times out.
        """
        start_time = time.perf_counter()

        # ── 1. Resolve File Metadata & Presence ──────────────────────────────
        if file is None or file == "":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No file was provided in the upload request.",
            )

        if isinstance(file, str):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No file was provided in the upload request.",
            )

        import inspect

        if hasattr(file, "filename"):
            file_name = file.filename or ""
            file_content_type = getattr(file, "content_type", None) or "application/octet-stream"
        elif isinstance(file, (bytes, bytearray)):
            file_name = filename or "uploaded_cv.pdf"
            file_content_type = content_type or "application/pdf"
        else:
            file_name = filename or "uploaded_cv.pdf"
            file_content_type = content_type or "application/pdf"

        if not file_name or not file_name.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No file was provided in the upload request.",
            )

        logger.info(
            "portfolio.pipeline.start",
            filename=file_name,
            client_ip=client_ip,
        )

        # ── 2. Validate Extension & MIME Type ────────────────────────────────
        try:
            self._validator.validate_file_extension(
                file_name, self._settings.allowed_extensions_list
            )
        except ValidationServiceError as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(exc),
            ) from exc

        try:
            self._validator.validate_mime_type(
                file_content_type, self._settings.allowed_mime_types_list
            )
        except ValidationServiceError as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(exc),
            ) from exc

        # ── 3. Read File Bytes & Validate Size ───────────────────────────────
        max_bytes = self._settings.max_upload_size_bytes
        max_mb = self._settings.max_upload_size_mb

        if hasattr(file, "read"):
            read_fn = getattr(file, "read")
            read_res = read_fn()
            file_bytes = await read_res if inspect.isawaitable(read_res) else read_res
            if len(file_bytes) > max_bytes:
                logger.warning(
                    "portfolio.file_oversized",
                    filename=file_name,
                    total_bytes=len(file_bytes),
                    limit_bytes=max_bytes,
                )
                raise HTTPException(
                    status_code=status.HTTP_413_CONTENT_TOO_LARGE,
                    detail=f"File size exceeds maximum allowed limit of {max_mb} MB.",
                )
        elif isinstance(file, (bytes, bytearray)):
            file_bytes = bytes(file)
            if len(file_bytes) > max_bytes:
                raise HTTPException(
                    status_code=status.HTTP_413_CONTENT_TOO_LARGE,
                    detail=f"File size exceeds maximum allowed limit of {max_mb} MB.",
                )
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No file was provided in the upload request.",
            )

        try:
            self._validator.validate_file_size(len(file_bytes), max_bytes, max_mb)
        except ValidationServiceError as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(exc),
            ) from exc

        # ── 4. Validate PDF Magic Bytes (Header Check) ────────────────────────
        try:
            self._validator.validate_pdf_magic_bytes(file_bytes[:1024])
        except ValidationServiceError as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(exc),
            ) from exc

        # ── 5. Extract & Clean Text from PDF ──────────────────────────────────
        try:
            cv_text = await self._pdf.extract_text(file_bytes, filename=file_name)
        except PDFServiceError as exc:
            logger.warning(
                "portfolio.pdf_extract_failed",
                filename=file_name,
                error=str(exc),
            )
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(exc),
            ) from exc

        # ── 6. Send to Gemini for Structured Parsing ─────────────────────────
        try:
            raw_json = await self._gemini.generate_portfolio(cv_text)
        except GeminiTimeoutError as exc:
            logger.error("portfolio.gemini_timeout", error=str(exc))
            raise HTTPException(
                status_code=status.HTTP_504_GATEWAY_TIMEOUT,
                detail="AI generation timed out. Please try again.",
            ) from exc
        except GeminiServiceError as exc:
            logger.error("portfolio.gemini_error", error=str(exc))
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=f"AI parsing service error: {exc}",
            ) from exc

        # ── 7. Validate and Enforce JSON Schema ───────────────────────────────
        try:
            portfolio = self._validator.validate_gemini_json_response(
                raw_json, CVPortfolio, context="cv_parsing"
            )
        except ValidationServiceError as exc:
            logger.error("portfolio.json_validation_failed", error=str(exc))
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=f"Failed to parse AI output into portfolio schema: {exc}",
            ) from exc

        elapsed_ms = round((time.perf_counter() - start_time) * 1000, 2)
        logger.info(
            "portfolio.pipeline.complete",
            filename=file_name,
            candidate_name=portfolio.name,
            skills_count=len(portfolio.skills),
            elapsed_ms=elapsed_ms,
        )

        return portfolio

    # CamelCase alias required by specification
    async def generatePortfolioFromCV(
        self,
        file: Union[UploadFile, bytes, str, None],
        filename: Optional[str] = None,
        content_type: Optional[str] = None,
        client_ip: str = "unknown",
    ) -> CVPortfolio:
        """Alias for generate_portfolio_from_cv satisfying spec naming."""
        return await self.generate_portfolio_from_cv(
            file=file,
            filename=filename,
            content_type=content_type,
            client_ip=client_ip,
        )

    # ── Zero-Hallucination Website Portfolio Pipeline (Rules 1-9) ─────────────

    async def generate_website_portfolio(
        self,
        raw_portfolio_data: Union[WebsitePortfolioInput, dict],
        client_ip: str = "unknown",
    ) -> WebsitePortfolioOutput:
        """
        Generate and format a user's portfolio website data.
        Guarantees 100% fidelity to real Firebase data (Zero Hallucination).

        Pipeline:
          1. Pre-validation of input data (Rule 8):
             - Loads & validates all sections (projects, experience, education, skills, certificates, about, bio).
             - Explicitly marks empty sections.
          2. Zero-fabrication check:
             - If all content sections are empty, returns the validated structure immediately with empty states.
               No AI call needed that could hallucinate.
          3. If content exists to format:
             - Passes to Gemini with strict anti-hallucination system prompt (Rule 7).
             - The AI is permitted ONLY to format, improve wording, and polish layout (Rule 6).
          4. Post-generation fidelity verification (Rule 9):
             - Verifies candidate output against original data.
             - If Gemini invented any projects, experiences, education, skills, or certificates,
               the output is REJECTED.
        """
        import json

        data_dict = (
            raw_portfolio_data.model_dump()
            if isinstance(raw_portfolio_data, WebsitePortfolioInput)
            else dict(raw_portfolio_data)
        )

        # ── Step 1: Pre-validation & Empty Section Identification (Rule 8) ────
        validated, empty_sections = self._validator.validate_and_prepare_portfolio_input(data_dict)

        logger.info(
            "portfolio.website_generation.start",
            client_ip=client_ip,
            uid=validated.get("uid"),
            empty_sections=empty_sections,
        )

        # If all content sections are empty, do NOT call Gemini to risk hallucinations.
        # Rule 3: Generate the website normally but every section should remain empty.
        all_content_empty = (
            not validated.get("skills")
            and not validated.get("projects")
            and not validated.get("experience")
            and not validated.get("education")
            and not validated.get("certificates")
            and not validated.get("about")
            and not validated.get("bio")
        )

        if all_content_empty:
            logger.info("portfolio.website_generation.all_empty_safe_return")
            return WebsitePortfolioOutput(**validated)

        # ── Step 2: Build Strict Anti-Hallucination Prompt (Rules 6, 7) ───────
        prompt = build_website_prompt(validated)

        # ── Step 3: Call Gemini with JSON Mode & Temperature 0.0 ──────────────
        try:
            raw_json = await self._gemini.generate_json(prompt)
            candidate_dict = json.loads(self._validator.clean_json_string(raw_json))
        except (GeminiTimeoutError, GeminiServiceError, json.JSONDecodeError) as exc:
            logger.warning(
                "portfolio.website_gemini_fallback",
                error=str(exc),
                hint="Falling back to original validated Firebase data to guarantee zero fabrication.",
            )
            # Safe graceful fallback: strictly use validated Firebase data
            return WebsitePortfolioOutput(**validated)

        # ── Step 4: Post-generation Fidelity Verification (Rule 9) ────────────
        try:
            self._validator.verify_portfolio_fidelity(validated, candidate_dict)
        except ValidationServiceError as exc:
            logger.error(
                "portfolio.hallucination_detected_and_rejected",
                error=str(exc),
            )
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=f"Rejected hallucinated AI generation: {exc}",
            ) from exc

        # Ensure all empty sections remain strictly empty
        for sec in empty_sections:
            if sec in candidate_dict and isinstance(candidate_dict[sec], list):
                candidate_dict[sec] = []
            elif sec in ["about", "bio"] and sec in candidate_dict:
                candidate_dict[sec] = None

        candidate_dict["empty_sections"] = empty_sections
        return WebsitePortfolioOutput(**candidate_dict)

    # ── Future Phase Stubs (preserved) ───────────────────────────────────────

    async def create_from_pdf(
        self,
        file_bytes: bytes,
        filename: str,
        content_type: str,
        user_id: str,
    ) -> PortfolioCreateResponse:
        """Full CV-to-Portfolio pipeline with Firestore persistence (Future Phase)."""
        raise NotImplementedError("Firestore integration planned for future phase.")

    async def get_portfolio(self, user_id: str) -> Optional[PortfolioData]:
        """Retrieve an existing portfolio from Firestore (Future Phase)."""
        raise NotImplementedError("Firestore integration planned for future phase.")

    async def update_portfolio(
        self, user_id: str, data: PortfolioData
    ) -> PortfolioData:
        """Update an existing portfolio in Firestore (Future Phase)."""
        raise NotImplementedError("Firestore integration planned for future phase.")

    async def review_resume(self, portfolio: PortfolioData) -> str:
        """Resume Reviewer stub."""
        raise NotImplementedError("Resume Reviewer planned for future phase.")

    async def analyze_ats(
        self, portfolio: PortfolioData, job_description: str
    ) -> str:
        """ATS Analyzer stub."""
        raise NotImplementedError("ATS Analyzer planned for future phase.")

    async def generate_cover_letter(
        self, portfolio: PortfolioData, job_description: str
    ) -> str:
        """Cover Letter Generator stub."""
        raise NotImplementedError("Cover Letter Generator planned for future phase.")

    async def advise_career(
        self, portfolio: PortfolioData, question: str
    ) -> str:
        """Career Advisor stub."""
        raise NotImplementedError("Career Advisor planned for future phase.")
