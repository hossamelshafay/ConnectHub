"""
ConnectHub AI Engine — Health Check Test
=========================================
"""

from __future__ import annotations

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_check() -> None:
    """GET /health should return 200 with the expected JSON payload."""
    response = client.get("/health")

    assert response.status_code == 200

    body = response.json()
    assert body["status"] == "ok"
    assert body["service"] == "ConnectHub AI Engine"
    assert body["version"] == "1.0.0"


def test_health_check_content_type() -> None:
    """GET /health response should have JSON content-type."""
    response = client.get("/health")
    assert "application/json" in response.headers.get("content-type", "")
