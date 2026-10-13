"""
ConnectHub AI Engine — Website Portfolio Generation Tests
=========================================================

Tests strict Zero-Hallucination Policy:
  - Empty portfolio returns completely empty sections with zero fabrication.
  - Partially empty portfolio keeps missing sections empty (Rule 4).
  - Validation catches and rejects hallucinated projects, experience, skills, education, certificates (Rule 9).
"""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient
from unittest.mock import AsyncMock, patch

from app.main import app
from app.services.validation_service import ValidationService, ValidationServiceError

client = TestClient(app)


def test_empty_portfolio_website_generation():
    """Rule 3: Brand new user with empty portfolio gets clean website data with empty sections."""
    payload = {
        "uid": "user_empty_123",
        "username": "newuser",
        "name": "New User",
        "skills": [],
        "projects": [],
        "experience": [],
        "education": [],
        "certificates": [],
    }
    response = client.post("/portfolio/generate-website", json=payload)
    assert response.status_code == 200
    res_data = response.json()
    assert res_data["success"] is True
    data = res_data["data"]
    assert data["skills"] == []
    assert data["projects"] == []
    assert data["experience"] == []
    assert data["education"] == []
    assert data["certificates"] == []
    assert "projects" in data["empty_sections"]
    assert "experience" in data["empty_sections"]
    assert "skills" in data["empty_sections"]
    assert "education" in data["empty_sections"]
    assert "certificates" in data["empty_sections"]


def test_partial_portfolio_preserves_empty_sections():
    """Rule 4: When only some sections contain data, missing sections remain strictly empty."""
    payload = {
        "uid": "user_partial_456",
        "name": "Alex Smith",
        "bio": "Mobile Engineer",
        "skills": ["Flutter", "Dart"],
        "education": [
            {
                "institution": "Cairo University",
                "degree": "B.Sc. Computer Science",
            }
        ],
        "projects": [],
        "experience": [],
        "certificates": [],
    }
    response = client.post("/portfolio/generate-website", json=payload)
    assert response.status_code == 200
    data = response.json()["data"]
    assert data["name"] == "Alex Smith"
    assert data["bio"] == "Mobile Engineer"
    assert data["skills"] == ["Flutter", "Dart"]
    assert len(data["education"]) == 1
    # Missing sections must remain strictly empty
    assert data["projects"] == []
    assert data["experience"] == []
    assert data["certificates"] == []
    assert "projects" in data["empty_sections"]
    assert "experience" in data["empty_sections"]


def test_validation_service_fidelity_rejects_hallucinations():
    """Rule 9: Verification rejects output if AI invents data not in Firebase."""
    validator = ValidationService()

    original = {
        "projects": [],
        "experience": [],
        "skills": ["Python"],
        "education": [],
        "certificates": [],
    }

    # Case 1: AI fabricated projects
    fake_projects = {
        "projects": [{"title": "Fake E-Commerce App"}],
        "experience": [],
        "skills": ["Python"],
        "education": [],
        "certificates": [],
    }
    with pytest.raises(ValidationServiceError, match="Gemini invented projects"):
        validator.verify_portfolio_fidelity(original, fake_projects)

    # Case 2: AI fabricated experience
    fake_exp = {
        "projects": [],
        "experience": [{"company": "Google", "position": "Staff Engineer"}],
        "skills": ["Python"],
        "education": [],
        "certificates": [],
    }
    with pytest.raises(ValidationServiceError, match="Gemini invented work experience"):
        validator.verify_portfolio_fidelity(original, fake_exp)

    # Case 3: AI fabricated skills
    fake_skills = {
        "projects": [],
        "experience": [],
        "skills": ["Python", "Quantum Computing", "Rust"],
        "education": [],
        "certificates": [],
    }
    with pytest.raises(ValidationServiceError, match="Gemini fabricated skill"):
        validator.verify_portfolio_fidelity(original, fake_skills)
