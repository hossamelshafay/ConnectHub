"""
ConnectHub AI Engine — Gemini AI Service
=========================================

Reusable Google Gemini client for all AI features across ConnectHub.

Responsibilities:
  - Initialization & authentication via API key
  - Dynamic discovery of supported models using Google GenAI SDK
  - Dynamic fallback chain construction without hardcoded model names
  - Startup diagnostics (SDK version, API version, model lists)
  - Pre-request logging ("Attempting model: <name>")
  - Immediate skip on 404 (Not Found) to the next available model
  - Sending text prompts (plain text responses)
  - Sending structured prompts (JSON-only responses)
  - Timeout enforcement & retry on transient errors
  - Detailed error messages listing all available models on failure

Uses the modern ``google-genai`` SDK (google.genai), not the deprecated
``google-generativeai`` package.
"""

from __future__ import annotations

import asyncio
import time
from datetime import datetime, timezone
from typing import Any, List, Optional, Set

from tenacity import (
    AsyncRetrying,
    retry_if_exception,
    stop_after_attempt,
    wait_exponential,
)

from app.config.settings import settings
from app.core.logging import get_logger

logger = get_logger(__name__)


class GeminiServiceError(Exception):
    """Raised when the Gemini service returns an unrecoverable error."""


class GeminiTimeoutError(GeminiServiceError):
    """Raised when a Gemini request exceeds the configured timeout."""


class GeminiService:
    """
    Reusable, async-first Google Gemini client using dynamic model discovery.

    Attributes:
        requested_model_name: Initial model name configured in settings.
        primary_model:        Currently selected primary model.
        fallback_models:      Ordered list of dynamic fallback models.
        all_available_models: All models discovered from the API key.
        supported_models:     Models from API that support ``generateContent``.
        timeout_seconds:      Per-request timeout in seconds.
        max_retries:          Number of retry attempts on transient failures per model.
    """

    def __init__(
        self,
        model_name: Optional[str] = None,
        timeout_seconds: Optional[int] = None,
        max_retries: Optional[int] = None,
    ) -> None:
        self.requested_model_name: str = model_name or settings.gemini_model
        self.model_name: str = self.requested_model_name
        self.timeout_seconds: int = timeout_seconds or settings.gemini_timeout_seconds
        self.max_retries: int = max_retries or settings.gemini_max_retries

        self._client: Any = None
        self._initialized: bool = False

        self.api_version: str = "v1beta"
        self.sdk_version: str = "unknown"
        self.all_available_models: List[str] = []
        self.supported_models: List[str] = []
        self.primary_model: str = ""
        self.fallback_models: List[str] = []
        self._dead_models: Set[str] = set()

    # ── Initialization & Discovery ──────────────────────────────────────────

    def initialize(self) -> None:
        """
        Configure the Gemini SDK, discover available models from the API key,
        filter those supporting generateContent, and build a dynamic fallback chain.

        Raises:
            GeminiServiceError: If GEMINI_API_KEY is missing or invalid.
        """
        if self._initialized:
            return

        api_key = settings.gemini_api_key
        if not api_key:
            raise GeminiServiceError(
                "GEMINI_API_KEY is not set. "
                "Add it to your .env file before using AI features."
            )

        from google import genai
        from google.genai import _api_client

        self._client = genai.Client(api_key=api_key)
        self.sdk_version = getattr(genai, "__version__", "unknown")
        self.api_version = getattr(_api_client, "DEFAULT_API_VERSION", "v1beta")

        # Discover all models available to this API key
        try:
            raw_models = list(self._client.models.list())
            self.all_available_models = [m.name for m in raw_models]
        except Exception as exc:
            logger.error("gemini.discovery_failed", error=str(exc))
            raise GeminiServiceError(
                f"Failed to query available models from Gemini API: {exc}"
            ) from exc

        # Filter only models that support generateContent
        self.supported_models = []
        for m in raw_models:
            actions = (
                getattr(m, "supported_actions", None)
                or getattr(m, "supported_generation_methods", None)
                or []
            )
            if "generateContent" in actions:
                self.supported_models.append(m.name)

        # Build fallback chain dynamically from supported models (no hardcoded names)
        self._build_fallback_chain()

        self._initialized = True

        # Print startup diagnostics as required
        self._print_startup_diagnostics()

    def _build_fallback_chain(self) -> None:
        """
        Dynamically constructs an ordered model chain from self.supported_models.
        General-purpose text models (flash/pro) are placed first, while
        specialized models (tts, image, etc.) are placed last.
        """
        if not self.supported_models:
            self.primary_model = self.requested_model_name
            self.fallback_models = []
            return

        def clean_name(name: str) -> str:
            return name.removeprefix("models/").lower()

        # Keywords of narrow/specialized models to deprioritize for text/json generation
        specialized_keywords = {
            "tts", "image", "audio", "music", "clip", "transcribe",
            "robotics", "computer-use", "banana", "live"
        }

        def is_general_model(name: str) -> bool:
            c = clean_name(name)
            return not any(kw in c for kw in specialized_keywords)

        general_models = [m for m in self.supported_models if is_general_model(m)]
        other_models = [m for m in self.supported_models if not is_general_model(m)]

        # Within general models, rank flash models first, then pro, then other general
        flash_models = [m for m in general_models if "flash" in clean_name(m)]
        pro_models = [m for m in general_models if "pro" in clean_name(m) and m not in flash_models]
        remaining_general = [
            m for m in general_models if m not in flash_models and m not in pro_models
        ]

        ordered_candidates = flash_models + pro_models + remaining_general + other_models

        # If user configured a specific model, prioritize it if it's supported
        req_clean = clean_name(self.requested_model_name)
        matched_requested: Optional[str] = None
        for candidate in ordered_candidates:
            if clean_name(candidate) == req_clean:
                matched_requested = candidate
                break

        if matched_requested:
            final_chain = [matched_requested] + [
                m for m in ordered_candidates if m != matched_requested
            ]
        else:
            final_chain = ordered_candidates

        self.primary_model = final_chain[0]
        self.model_name = self.primary_model
        self.fallback_models = final_chain[1:]

    def _print_startup_diagnostics(self) -> None:
        """Print required startup diagnostic information to console and logs."""
        print("\n" + "=" * 70)
        print("===== GEMINI AI ENGINE INITIALIZATION & DISCOVERY =====")
        print(f"API Version:    {self.api_version}")
        print(f"SDK Version:    {self.sdk_version}")
        print(f"Primary Model:  {self.primary_model}")
        print(f"Fallback Models ({len(self.fallback_models)} total):")
        for fb in self.fallback_models:
            print(f"  - {fb}")
        print("\n===== ALL AVAILABLE GEMINI MODELS FROM API =====")
        for m_name in self.all_available_models:
            tag = " [supports: generateContent]" if m_name in self.supported_models else ""
            print(f"  {m_name}{tag}")
        print("=" * 70 + "\n")

        logger.info(
            "gemini.initialized",
            api_version=self.api_version,
            sdk_version=self.sdk_version,
            primary_model=self.primary_model,
            fallback_models_count=len(self.fallback_models),
            total_models=len(self.all_available_models),
            supported_models=len(self.supported_models),
        )

    # ── Core Request Execution ──────────────────────────────────────────────

    async def _call(
        self,
        prompt: str,
        *,
        response_mime_type: str = "text/plain",
        temperature: float = 0.2,
    ) -> str:
        """
        Executes a prompt across the dynamic fallback chain.
        Skips 404 models immediately without retry delays.
        Logs 'Attempting model: <model_name>' before each candidate.
        """
        if not self._initialized:
            self.initialize()

        from google.genai import types

        config = types.GenerateContentConfig(
            temperature=temperature,
            response_mime_type=response_mime_type,
        )

        # Build current candidate list excluding known dead/404 models
        candidates = [self.primary_model] + self.fallback_models
        models_to_try = [m for m in candidates if m and m not in self._dead_models]

        # Deduplicate while preserving order
        seen: Set[str] = set()
        deduped_models: List[str] = []
        for m in models_to_try:
            if m not in seen:
                seen.add(m)
                deduped_models.append(m)
        models_to_try = deduped_models

        if not models_to_try:
            detailed_err = (
                f"No compatible Gemini models available for generation. "
                f"Available models returned by API ({len(self.all_available_models)}): "
                f"{self.all_available_models}"
            )
            print(f"[Gemini Error] {detailed_err}")
            logger.error("gemini.no_models_available", error=detailed_err)
            raise GeminiServiceError(detailed_err)

        last_exc: Optional[Exception] = None
        attempted_models: List[str] = []

        for candidate_model in models_to_try:
            attempted_models.append(candidate_model)

            # Requirement 8: Before every request log "Attempting model: <model_name>"
            print(f"Attempting model: {candidate_model}")
            logger.info(
                "gemini.attempting_model",
                stage="Attempting model",
                model=candidate_model,
                prompt_length=len(prompt),
                response_mime_type=response_mime_type,
            )

            req_start_time = time.perf_counter()

            async def _attempt(current_model: str) -> str:
                try:
                    response = await asyncio.wait_for(
                        self._client.aio.models.generate_content(
                            model=current_model,
                            contents=prompt,
                            config=config,
                        ),
                        timeout=self.timeout_seconds,
                    )
                    return response.text or ""
                except asyncio.TimeoutError as exc:
                    raise GeminiTimeoutError(
                        f"Gemini request timed out after {self.timeout_seconds}s on {current_model}"
                    ) from exc

            def _is_transient_retryable(exc: BaseException) -> bool:
                # Do not retry 404 or dead models on the same candidate
                if isinstance(exc, (GeminiTimeoutError, asyncio.TimeoutError)):
                    return False
                err_str = str(exc).upper()
                if "404" in err_str or "NOT_FOUND" in err_str:
                    return False
                if "503" in err_str or "UNAVAILABLE" in err_str:
                    return False
                return True

            try:
                result: str = ""
                async for attempt in AsyncRetrying(
                    retry=retry_if_exception(_is_transient_retryable),
                    stop=stop_after_attempt(self.max_retries),
                    wait=wait_exponential(multiplier=1, min=1, max=4),
                    reraise=True,
                ):
                    with attempt:
                        result = await _attempt(candidate_model)

                duration_ms = round((time.perf_counter() - req_start_time) * 1000, 2)
                iso_end = datetime.now(timezone.utc).isoformat()
                logger.info(
                    "gemini.response.received",
                    stage="Gemini response received",
                    timestamp=iso_end,
                    model=candidate_model,
                    execution_time_ms=duration_ms,
                    execution_time_sec=round(duration_ms / 1000, 2),
                    response_length=len(result),
                )
                print(
                    f"[Gemini Success] Model '{candidate_model}' succeeded in "
                    f"{round(duration_ms / 1000, 2)}s"
                )

                # Set successful model as primary for subsequent calls
                self.primary_model = candidate_model
                self.model_name = candidate_model
                return result

            except Exception as exc:
                duration_ms = round((time.perf_counter() - req_start_time) * 1000, 2)
                err_str = str(exc)

                # Requirement 9: If a model returns 404, immediately skip it
                if "404" in err_str or "NOT_FOUND" in err_str:
                    print(
                        f"[Gemini] Model '{candidate_model}' returned 404 NOT_FOUND. "
                        f"Skipping immediately to next available model."
                    )
                    logger.warning(
                        "gemini.model_404_skipped",
                        model=candidate_model,
                        execution_time_ms=duration_ms,
                        error=err_str[:200],
                    )
                    self._dead_models.add(candidate_model)
                    last_exc = exc
                    continue
                elif isinstance(exc, GeminiTimeoutError):
                    print(
                        f"[Gemini] Model '{candidate_model}' timed out after {self.timeout_seconds}s. "
                        f"Trying next fallback."
                    )
                    logger.warning(
                        "gemini.timeout_on_model",
                        failed_model=candidate_model,
                        execution_time_ms=duration_ms,
                        error=str(exc),
                    )
                    last_exc = exc
                    continue
                else:
                    print(
                        f"[Gemini] Model '{candidate_model}' failed: {err_str[:120]}. "
                        f"Trying next fallback."
                    )
                    logger.warning(
                        "gemini.model_fallback_triggered",
                        failed_model=candidate_model,
                        execution_time_ms=duration_ms,
                        error=err_str[:200],
                    )
                    last_exc = exc
                    continue

        # Requirement 10: Detailed error listing all available models
        detailed_error = (
            f"Gemini request failed across all attempted models: {attempted_models}. "
            f"All available models from API ({len(self.all_available_models)}): "
            f"{self.all_available_models}. Last error: {last_exc}"
        )
        print(f"[Gemini Critical Error] {detailed_error}")
        logger.error(
            "gemini.all_fallbacks_failed",
            attempted_models=attempted_models,
            available_models=self.all_available_models,
            error=str(last_exc),
            exc_type=type(last_exc).__name__,
        )
        raise GeminiServiceError(detailed_error) from last_exc

    # ── Public API ────────────────────────────────────────────────────────────

    async def generate_content(self, prompt: str) -> str:
        """Send a text prompt to Gemini and return the response text."""
        return await self._call(prompt, response_mime_type="text/plain", temperature=0.2)

    async def generate_json(self, prompt: str) -> str:
        """Send a structured prompt to Gemini and enforce a JSON-only response."""
        return await self._call(
            prompt, response_mime_type="application/json", temperature=0.0
        )

    async def generate_portfolio(self, raw_cv_text: str) -> str:
        """Generate structured portfolio JSON from raw CV text."""
        from app.prompts.portfolio_prompt import build_portfolio_prompt

        prompt = build_portfolio_prompt(raw_cv_text)
        return await self.generate_json(prompt)

    # ── Convenience helpers ───────────────────────────────────────────────────

    async def is_available(self) -> bool:
        """Ping Gemini with a minimal prompt to verify connectivity."""
        try:
            await self.generate_content("ping")
            return True
        except Exception:
            return False

    @property
    def is_initialized(self) -> bool:
        """True if the Gemini client has been initialized."""
        return self._initialized
