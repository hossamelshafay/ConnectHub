"""
ConnectHub AI Engine — Phase 3: CV Parsing Pipeline Tests
===========================================================

Comprehensive test suite covering:
  - Valid CV upload & parsing (mocked Gemini, 200 OK, full schema verified)
  - Missing file rejection (400 Bad Request)
  - Empty file rejection (0 bytes, 400 Bad Request)
  - Invalid MIME type rejection (400 Bad Request)
  - Invalid file extension rejection (400 Bad Request)
  - Oversized upload rejection (> MAX_UPLOAD_SIZE_MB, 413 Payload Too Large)
  - Corrupted PDF structure rejection (400 Bad Request)
  - Disguised executable rejection (%PDF- header check, 400 Bad Request)
  - Blank / unscannable PDF rejection (no extractable text, 400 Bad Request)
  - Gemini service failure handling (502 Bad Gateway)
  - Gemini timeout handling (504 Gateway Timeout)
  - Invalid JSON output from Gemini (502 Bad Gateway)
  - Markdown-wrapped JSON from Gemini (properly stripped & parsed)
  - Partial fields from Gemini (safe defaults filled)
  - OpenAPI / Swagger documentation schema verification
"""

from __future__ import annotations

import io
import json
from typing import Generator
from unittest.mock import AsyncMock, patch

import pymupdf
import pytest
from fastapi.testclient import TestClient

from app.config.settings import get_settings
from app.dependencies.services import get_portfolio_service
from app.main import app
from app.schemas.cv_portfolio_schema import CVPortfolio
from app.services.gemini_service import (
    GeminiService,
    GeminiServiceError,
    GeminiTimeoutError,
)
from app.services.portfolio_service import PortfolioService

client = TestClient(app)

MOCK_PARSED_PORTFOLIO = {
    "name": "Jane Smith",
    "title": "Senior Backend Engineer",
    "headline": "Building distributed cloud systems with Python and Kubernetes",
    "summary": "5+ years developing robust backend services and microservices.",
    "location": "Cairo, Egypt",
    "email": "jane.smith@example.com",
    "phone": "+20 100 123 4567",
    "website": "https://janesmith.dev",
    "github": "https://github.com/janesmith",
    "linkedin": "https://linkedin.com/in/janesmith",
    "skills": ["Python", "FastAPI", "Docker", "PostgreSQL", "Kubernetes"],
    "projects": [
        {
            "title": "CloudHub",
            "description": "Distributed cloud orchestration platform.",
            "techStack": ["Python", "FastAPI", "Docker"],
            "github": "https://github.com/janesmith/cloudhub",
            "liveDemo": "https://cloudhub.example.com",
        }
    ],
    "experience": [
        {
            "company": "Tech Innovations",
            "position": "Senior Backend Engineer",
            "startDate": "Jan 2021",
            "endDate": "Present",
            "description": "Architected event-driven microservices processing 1M daily events.",
        }
    ],
    "education": [
        {
            "institution": "Cairo University",
            "degree": "B.Sc.",
            "field": "Computer Science",
            "startDate": "2015",
            "endDate": "2019",
        }
    ],
    "certificates": [
        {
            "title": "AWS Certified Solutions Architect",
            "issuer": "Amazon Web Services",
            "date": "2023",
            "url": "https://aws.amazon.com/verify/123",
        }
    ],
}


def create_pdf_with_text(text: str = "") -> bytes:
    """Helper: create an in-memory PDF with readable text."""
    doc = pymupdf.open()
    page = doc.new_page()
    content = text or (
        "Jane Smith\n"
        "Senior Backend Engineer\n"
        "Cairo, Egypt | jane.smith@example.com | +20 100 123 4567\n"
        "https://github.com/janesmith | https://linkedin.com/in/janesmith\n\n"
        "Summary:\n"
        "5+ years developing robust backend services and microservices.\n\n"
        "Skills:\n"
        "Python, FastAPI, Docker, PostgreSQL, Kubernetes\n\n"
        "Experience:\n"
        "Tech Innovations - Senior Backend Engineer (Jan 2021 - Present)\n"
        "Architected event-driven microservices processing 1M daily events.\n\n"
        "Education:\n"
        "Cairo University - B.Sc. Computer Science (2015 - 2019)\n"
    )
    page.insert_text((50, 72), content)
    pdf_bytes = doc.tobytes()
    doc.close()
    return pdf_bytes


# ─── 1. Valid CV Upload & Parsing Tests ──────────────────────────────────────

def test_upload_cv_valid(monkeypatch: pytest.MonkeyPatch) -> None:
    """Valid CV upload should extract text, call Gemini, and return structured portfolio."""
    pdf_bytes = create_pdf_with_text()

    # Mock Gemini to return structured JSON
    async def mock_generate_portfolio(raw_cv_text: str) -> str:
        return json.dumps(MOCK_PARSED_PORTFOLIO)

    svc = get_portfolio_service()
    monkeypatch.setattr(svc._gemini, "generate_portfolio", mock_generate_portfolio)

    files = {"file": ("my_resume.pdf", io.BytesIO(pdf_bytes), "application/pdf")}
    response = client.post("/portfolio/upload-cv", files=files)

    assert response.status_code == 200
    body = response.json()

    assert body["success"] is True
    assert body["message"] == "CV parsed and portfolio generated successfully."
    assert body["version"] == "1.0.0"

    data = body["data"]
    assert data["name"] == "Jane Smith"
    assert data["title"] == "Senior Backend Engineer"
    assert "FastAPI" in data["skills"]
    assert len(data["projects"]) == 1
    assert data["projects"][0]["title"] == "CloudHub"
    assert data["projects"][0]["techStack"] == ["Python", "FastAPI", "Docker"]
    assert len(data["experience"]) == 1
    assert data["experience"][0]["company"] == "Tech Innovations"
    assert data["experience"][0]["startDate"] == "Jan 2021"
    assert len(data["education"]) == 1
    assert data["education"][0]["institution"] == "Cairo University"
    assert len(data["certificates"]) == 1


def test_upload_cv_markdown_fences_stripped(monkeypatch: pytest.MonkeyPatch) -> None:
    """Markdown code fences (```json ... ```) from Gemini must be stripped cleanly."""
    pdf_bytes = create_pdf_with_text()

    async def mock_generate_portfolio(raw_cv_text: str) -> str:
        return f"```json\n{json.dumps(MOCK_PARSED_PORTFOLIO)}\n```"

    svc = get_portfolio_service()
    monkeypatch.setattr(svc._gemini, "generate_portfolio", mock_generate_portfolio)

    files = {"file": ("my_resume.pdf", io.BytesIO(pdf_bytes), "application/pdf")}
    response = client.post("/portfolio/upload-cv", files=files)

    assert response.status_code == 200
    body = response.json()
    assert body["success"] is True
    assert body["data"]["name"] == "Jane Smith"


def test_upload_cv_partial_defaults_filled(monkeypatch: pytest.MonkeyPatch) -> None:
    """If Gemini returns partial fields, safe defaults should populate the missing fields."""
    pdf_bytes = create_pdf_with_text()

    # Gemini returns only name and skills
    partial = {"name": "Alex", "skills": ["Python"]}

    async def mock_generate_portfolio(raw_cv_text: str) -> str:
        return json.dumps(partial)

    svc = get_portfolio_service()
    monkeypatch.setattr(svc._gemini, "generate_portfolio", mock_generate_portfolio)

    files = {"file": ("my_resume.pdf", io.BytesIO(pdf_bytes), "application/pdf")}
    response = client.post("/portfolio/upload-cv", files=files)

    assert response.status_code == 200
    data = response.json()["data"]
    assert data["name"] == "Alex"
    assert data["skills"] == ["Python"]
    assert data["title"] == ""
    assert data["projects"] == []
    assert data["experience"] == []
    assert data["education"] == []
    assert data["certificates"] == []


# ─── 2. Missing File Tests ───────────────────────────────────────────────────

def test_upload_cv_missing_file_no_body() -> None:
    """Request with no body / multipart must be rejected with 400 Bad Request."""
    response = client.post("/portfolio/upload-cv")
    assert response.status_code == 400
    body = response.json()
    assert body["success"] is False
    assert body["error"] == "bad_request"
    assert "no file was provided" in body["message"].lower()


def test_upload_cv_empty_filename() -> None:
    """File upload with empty filename must be rejected with 400 Bad Request."""
    pdf_bytes = create_pdf_with_text()
    files = {"file": ("", io.BytesIO(pdf_bytes), "application/pdf")}
    response = client.post("/portfolio/upload-cv", files=files)
    assert response.status_code == 400
    body = response.json()
    assert body["success"] is False
    assert "no file was provided" in body["message"].lower()


# ─── 3. Empty File Tests (0 Bytes) ───────────────────────────────────────────

def test_upload_cv_empty_file() -> None:
    """A 0-byte file must be rejected with 400 Bad Request."""
    files = {"file": ("empty.pdf", io.BytesIO(b""), "application/pdf")}
    response = client.post("/portfolio/upload-cv", files=files)
    assert response.status_code == 400
    body = response.json()
    assert body["success"] is False
    assert "empty" in body["message"].lower()


# ─── 4. Invalid MIME Type Tests ──────────────────────────────────────────────

@pytest.mark.parametrize(
    "invalid_mime",
    [
        "text/plain",
        "image/png",
        "image/jpeg",
        "application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "application/octet-stream",
    ],
)
def test_upload_cv_invalid_mime(invalid_mime: str) -> None:
    """Files with non-PDF MIME types must be rejected with 400 Bad Request."""
    pdf_bytes = create_pdf_with_text()
    files = {"file": ("document.pdf", io.BytesIO(pdf_bytes), invalid_mime)}
    response = client.post("/portfolio/upload-cv", files=files)
    assert response.status_code == 400
    body = response.json()
    assert body["success"] is False
    assert "invalid mime type" in body["message"].lower()


# ─── 5. Invalid Extension Tests ──────────────────────────────────────────────

@pytest.mark.parametrize(
    "invalid_filename",
    [
        "resume.docx",
        "resume.doc",
        "resume.txt",
        "resume.png",
        "resume.exe",
        "resume.sh",
        "resume",
    ],
)
def test_upload_cv_invalid_extension(invalid_filename: str) -> None:
    """Files without .pdf extension must be rejected with 400 Bad Request."""
    pdf_bytes = create_pdf_with_text()
    files = {"file": (invalid_filename, io.BytesIO(pdf_bytes), "application/pdf")}
    response = client.post("/portfolio/upload-cv", files=files)
    assert response.status_code == 400
    body = response.json()
    assert body["success"] is False
    assert "invalid file extension" in body["message"].lower()


# ─── 6. Oversized Upload Tests ───────────────────────────────────────────────

def test_upload_cv_oversized(monkeypatch: pytest.MonkeyPatch) -> None:
    """Uploading a file exceeding MAX_UPLOAD_SIZE_MB must return 413 Payload Too Large."""
    svc = get_portfolio_service()
    monkeypatch.setattr(svc._settings, "max_upload_size_mb", 1)

    # 1 MB + 100 KB payload
    oversized_data = b"%PDF-1.4 " + (b"A" * (1024 * 1024 + 100))
    files = {"file": ("big_resume.pdf", io.BytesIO(oversized_data), "application/pdf")}

    response = client.post("/portfolio/upload-cv", files=files)
    assert response.status_code == 413
    body = response.json()
    assert body["success"] is False
    assert body["error"] == "payload_too_large"


# ─── 7. Corrupted Upload & Disguised Executable Tests ────────────────────────

def test_upload_cv_fake_pdf_executable() -> None:
    """An executable disguised as a PDF (e.g. MZ header) must be rejected with 400."""
    fake_exe_content = b"MZ\x90\x00\x03\x00\x00\x00\x04\x00\x00\x00\xff\xff\x00\x00"
    files = {"file": ("trojan.pdf", io.BytesIO(fake_exe_content), "application/pdf")}
    response = client.post("/portfolio/upload-cv", files=files)
    assert response.status_code == 400
    body = response.json()
    assert body["success"] is False
    assert "pdf standard" in body["message"].lower() or "pdf header" in body["message"].lower()


def test_upload_cv_corrupted_pdf_structure() -> None:
    """A file starting with %PDF- but with completely corrupted body must be rejected with 400."""
    corrupted_content = b"%PDF-1.4\ncorrupted binary garbage \x00\xff\xfe\x01\x02\x03"
    files = {"file": ("corrupted.pdf", io.BytesIO(corrupted_content), "application/pdf")}
    response = client.post("/portfolio/upload-cv", files=files)
    assert response.status_code == 400
    body = response.json()
    assert body["success"] is False
    assert "corrupted" in body["message"].lower() or "unreadable" in body["message"].lower()


def test_upload_cv_unscannable_empty_pdf() -> None:
    """A PDF with zero extractable text (e.g. blank page) must return 400."""
    doc = pymupdf.open()
    doc.new_page()
    blank_bytes = doc.tobytes()
    doc.close()

    files = {"file": ("blank.pdf", io.BytesIO(blank_bytes), "application/pdf")}
    response = client.post("/portfolio/upload-cv", files=files)
    assert response.status_code == 400
    body = response.json()
    assert body["success"] is False
    assert "no extractable text" in body["message"].lower() or "too short" in body["message"].lower()


# ─── 8. AI / Gemini Failure Handling Tests ───────────────────────────────────

def test_upload_cv_gemini_service_error(monkeypatch: pytest.MonkeyPatch) -> None:
    """When Gemini raises GeminiServiceError, router must return 502 Bad Gateway."""
    pdf_bytes = create_pdf_with_text()

    async def mock_generate_portfolio(raw_cv_text: str) -> str:
        raise GeminiServiceError("API quota exceeded or network failure")

    svc = get_portfolio_service()
    monkeypatch.setattr(svc._gemini, "generate_portfolio", mock_generate_portfolio)

    files = {"file": ("resume.pdf", io.BytesIO(pdf_bytes), "application/pdf")}
    response = client.post("/portfolio/upload-cv", files=files)

    assert response.status_code == 502
    body = response.json()
    assert body["success"] is False
    assert "ai parsing service error" in body["message"].lower()


def test_upload_cv_gemini_timeout(monkeypatch: pytest.MonkeyPatch) -> None:
    """When Gemini times out, router must return 504 Gateway Timeout."""
    pdf_bytes = create_pdf_with_text()

    async def mock_generate_portfolio(raw_cv_text: str) -> str:
        raise GeminiTimeoutError("Request timed out after 60s")

    svc = get_portfolio_service()
    monkeypatch.setattr(svc._gemini, "generate_portfolio", mock_generate_portfolio)

    files = {"file": ("resume.pdf", io.BytesIO(pdf_bytes), "application/pdf")}
    response = client.post("/portfolio/upload-cv", files=files)

    assert response.status_code == 504
    body = response.json()
    assert body["success"] is False
    assert "timed out" in body["message"].lower()


def test_upload_cv_invalid_json_from_gemini(monkeypatch: pytest.MonkeyPatch) -> None:
    """When Gemini returns broken JSON, router must return 502 Bad Gateway."""
    pdf_bytes = create_pdf_with_text()

    async def mock_generate_portfolio(raw_cv_text: str) -> str:
        return "This is completely invalid JSON { not real json ... "

    svc = get_portfolio_service()
    monkeypatch.setattr(svc._gemini, "generate_portfolio", mock_generate_portfolio)

    files = {"file": ("resume.pdf", io.BytesIO(pdf_bytes), "application/pdf")}
    response = client.post("/portfolio/upload-cv", files=files)

    assert response.status_code == 502
    body = response.json()
    assert body["success"] is False
    assert "failed to parse ai output" in body["message"].lower()


# ─── 9. Swagger / OpenAPI Documentation Tests ────────────────────────────────

def test_openapi_schema_contains_portfolio_fields() -> None:
    """Verify that Swagger OpenAPI documentation reflects the complete CVPortfolio schema."""
    response = client.get("/openapi.json")
    assert response.status_code == 200
    openapi = response.json()

    # Route must exist
    paths = openapi.get("paths", {})
    assert "/portfolio/upload-cv" in paths
    endpoint = paths["/portfolio/upload-cv"]["post"]

    # Status 200 response documented
    assert "200" in endpoint["responses"]

    # Schemas must define CVPortfolio and nested models
    components = openapi.get("components", {}).get("schemas", {})
    assert "CVPortfolio" in components
    props = components["CVPortfolio"]["properties"]
    assert "name" in props
    assert "title" in props
    assert "headline" in props
    assert "summary" in props
    assert "skills" in props
    assert "projects" in props
    assert "experience" in props
    assert "education" in props
    assert "certificates" in props
