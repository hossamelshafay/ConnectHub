"""
ConnectHub AI Engine — Upload Service Unit Tests
==================================================

Tests for the standalone UploadService (Phase 2.1 temporary storage).
"""

from __future__ import annotations

import asyncio
import io
from pathlib import Path

import pytest
from fastapi import HTTPException, UploadFile

from app.config.settings import get_settings
from app.dependencies.services import get_upload_service

VALID_PDF_BYTES = (
    b"%PDF-1.4\n"
    b"1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n"
    b"2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n"
    b"3 0 obj<</Type/Page/MediaBox[0 0 612 792]/Parent 2 0 R>>endobj\n"
    b"xref\n"
    b"0 4\n"
    b"0000000000 65535 f \n"
    b"0000000009 00000 n \n"
    b"0000000052 00000 n \n"
    b"0000000101 00000 n \n"
    b"trailer<</Size 4/Root 1 0 R>>\n"
    b"startxref\n"
    b"178\n"
    b"%%EOF\n"
)


def test_upload_service_store_file() -> None:
    """UploadService stores valid PDF and tracks metadata."""
    async def _run() -> None:
        upload_svc = get_upload_service()
        upload_file = UploadFile(
            file=io.BytesIO(VALID_PDF_BYTES),
            filename="cv_sample.pdf",
            headers={"content-type": "application/pdf"},
        )

        resp = await upload_svc.upload_cv(upload_file, client_ip="127.0.0.1")
        assert resp.upload_id is not None
        assert resp.original_file_name == "cv_sample.pdf"
        assert resp.mime_type == "application/pdf"
        assert resp.size == len(VALID_PDF_BYTES)

        # Clean up created file
        stored_path = get_settings().upload_temp_dir_path / resp.stored_file_name
        assert stored_path.exists()
        stored_path.unlink(missing_ok=True)

    asyncio.run(_run())


def test_upload_service_rejects_empty() -> None:
    """UploadService rejects 0-byte file."""
    async def _run() -> None:
        upload_svc = get_upload_service()
        upload_file = UploadFile(
            file=io.BytesIO(b""),
            filename="empty.pdf",
            headers={"content-type": "application/pdf"},
        )

        with pytest.raises(HTTPException) as exc_info:
            await upload_svc.upload_cv(upload_file)
        assert exc_info.value.status_code == 400

    asyncio.run(_run())
