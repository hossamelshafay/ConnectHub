"""
ConnectHub AI Engine — Upload Service
======================================

Production-grade file upload service responsible strictly for:
  - Validating upload requests (presence, extension, MIME type, size, integrity).
  - Generating cryptographically secure UUID4 filenames.
  - Safely writing validated files to temporary disk storage.
  - Recording audit metadata in-memory.
  - Returning sanitized public responses without exposing internal filesystem paths.

NOTE: This service strictly avoids PDF text extraction, OCR, AI parsing, or database writes.
"""

from __future__ import annotations

import time
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Union

from fastapi import HTTPException, UploadFile, status

from app.config.settings import Settings, get_settings
from app.core.logging import get_logger
from app.schemas.upload_schema import UploadMetadata, UploadResponse
from app.services.validation_service import ValidationService, ValidationServiceError

logger = get_logger(__name__)

CHUNK_SIZE = 64 * 1024  # 64 KB per read chunk


class UploadService:
    """
    Manages the lifecycle of uploaded CV files.

    Performs rigorous security validation, safe streaming storage,
    and in-memory session metadata tracking.
    """

    def __init__(
        self,
        settings: Optional[Settings] = None,
        validator: Optional[ValidationService] = None,
    ) -> None:
        self.settings: Settings = settings or get_settings()
        self.validator: ValidationService = validator or ValidationService()
        self._metadata_store: Dict[str, UploadMetadata] = {}
        # Ensure temporary storage directory exists immediately
        self._ensure_storage_directory()

    def _ensure_storage_directory(self) -> Path:
        """Create and return the validated storage directory path."""
        storage_dir = self.settings.upload_temp_dir_path
        storage_dir.mkdir(parents=True, exist_ok=True)
        return storage_dir

    def get_metadata(self, upload_id: str) -> Optional[UploadMetadata]:
        """Retrieve stored metadata for a given uploadId."""
        return self._metadata_store.get(upload_id)

    def list_metadata(self) -> List[UploadMetadata]:
        """List all in-memory metadata records."""
        return list(self._metadata_store.values())

    async def upload_cv(
        self,
        file: Union[UploadFile, str, None],
        client_ip: str = "unknown",
    ) -> UploadResponse:
        """
        Validate, store, and record metadata for an uploaded CV document.

        Args:
            file: The uploaded multipart file handle or string form field.
            client_ip: Remote IP of the requesting client for audit logging.

        Returns:
            UploadResponse containing safe, sanitized metadata.

        Raises:
            HTTPException(400): If validation fails (missing, empty, invalid extension,
                                invalid MIME type, corrupted structure).
            HTTPException(413): If file size exceeds configured limits.
        """
        start_time = time.perf_counter()
        upload_id = str(uuid.uuid4())
        stored_filename = f"{upload_id}.pdf"
        file_name_val = getattr(file, "filename", None)
        original_filename = file_name_val if file_name_val and str(file_name_val).strip() else "unknown"

        # ── 1. Log Upload Started ─────────────────────────────────────────────
        logger.info(
            "upload.started",
            upload_id=upload_id,
            original_filename=original_filename,
            client_ip=client_ip,
        )

        try:
            # ── 2. Check File Presence ────────────────────────────────────────
            if (
                file is None
                or isinstance(file, str)
                or not file_name_val
                or not str(file_name_val).strip()
            ):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="No file was provided in the upload request.",
                )

            # ── 3. Validate File Extension ────────────────────────────────────
            try:
                self.validator.validate_file_extension(
                    file.filename, self.settings.allowed_extensions_list
                )
            except ValidationServiceError as exc:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=str(exc),
                ) from exc

            # ── 4. Validate MIME Type ─────────────────────────────────────────
            try:
                self.validator.validate_mime_type(
                    file.content_type, self.settings.allowed_mime_types_list
                )
            except ValidationServiceError as exc:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=str(exc),
                ) from exc

            # ── 5. Stream Chunks & Validate File Size Before Saving ───────────
            chunks: List[bytes] = []
            total_bytes = 0
            max_bytes = self.settings.max_upload_size_bytes

            while True:
                chunk = await file.read(CHUNK_SIZE)
                if not chunk:
                    break
                total_bytes += len(chunk)

                if total_bytes > max_bytes:
                    raise HTTPException(
                        status_code=status.HTTP_413_CONTENT_TOO_LARGE,
                        detail=f"File size exceeds maximum allowed limit of {self.settings.max_upload_size_mb} MB.",
                    )
                chunks.append(chunk)

            # Check for empty file
            if total_bytes == 0:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Uploaded file is empty (0 bytes).",
                )

            content = b"".join(chunks)

            # ── 6. Security: Validate PDF Magic Bytes (%PDF-) ─────────────────
            try:
                self.validator.validate_pdf_magic_bytes(content[:1024])
            except ValidationServiceError as exc:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=str(exc),
                ) from exc

            # ── 7. Validate PDF Structural Integrity ──────────────────────────
            try:
                self.validator.validate_pdf_integrity(content)
            except ValidationServiceError as exc:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=str(exc),
                ) from exc

            # ── 8. Secure Disk Storage (Path Traversal Protection) ────────────
            storage_dir = self._ensure_storage_directory()
            target_path = (storage_dir / stored_filename).resolve()

            # Verify the resolved path is strictly within the allowed storage directory
            if not target_path.is_relative_to(storage_dir.resolve()):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid storage path resolution.",
                )

            # Write file safely
            target_path.write_bytes(content)

            # ── 9. Record In-Memory Metadata ──────────────────────────────────
            project_root = Path(__file__).resolve().parent.parent.parent
            try:
                relative_path = str(target_path.relative_to(project_root)).replace("\\", "/")
            except ValueError:
                relative_path = f"storage/uploads/{stored_filename}"

            metadata = UploadMetadata(
                upload_id=upload_id,
                original_file_name=Path(file.filename).name,
                stored_file_name=stored_filename,
                upload_timestamp=datetime.now(timezone.utc),
                file_size=total_bytes,
                mime_type=file.content_type or "application/pdf",
                absolute_path=str(target_path),
                relative_path=relative_path,
            )
            self._metadata_store[upload_id] = metadata

            # ── 10. Log Upload Success ────────────────────────────────────────
            duration_ms = round((time.perf_counter() - start_time) * 1000, 2)
            logger.info(
                "upload.success",
                upload_id=upload_id,
                original_filename=original_filename,
                generated_filename=stored_filename,
                size=total_bytes,
                duration=f"{duration_ms:.2f}ms",
                client_ip=client_ip,
            )

            # ── 11. Return Client-Safe Response ───────────────────────────────
            return metadata.to_response()

        except HTTPException as exc:
            duration_ms = round((time.perf_counter() - start_time) * 1000, 2)
            logger.warning(
                "upload.failed",
                upload_id=upload_id,
                original_filename=original_filename,
                generated_filename=stored_filename,
                size=locals().get("total_bytes", 0),
                duration=f"{duration_ms:.2f}ms",
                client_ip=client_ip,
                error=exc.detail,
            )
            raise

        except Exception as exc:
            duration_ms = round((time.perf_counter() - start_time) * 1000, 2)
            logger.error(
                "upload.failed",
                upload_id=upload_id,
                original_filename=original_filename,
                generated_filename=stored_filename,
                size=locals().get("total_bytes", 0),
                duration=f"{duration_ms:.2f}ms",
                client_ip=client_ip,
                error=str(exc),
            )
            raise
