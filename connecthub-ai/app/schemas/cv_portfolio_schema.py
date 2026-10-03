"""
ConnectHub AI Engine — CV Portfolio Schema (Gemini Output Contract)
====================================================================

Pydantic v2 models that define the EXACT structure Gemini must produce.

These schemas are:
  - The authoritative source of truth for the AI output contract.
  - Used to validate and coerce Gemini's JSON response.
  - Safe to return directly to API consumers (no internal fields).
  - Resilient: all string fields automatically coerce `null` to `""`,
    and list fields coerce `null` to `[]`.

Phase 3: CV Parsing & AI Portfolio Generation.
"""

from __future__ import annotations

from typing import List, Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator


class CVProject(BaseModel):
    """A project entry extracted from the CV."""

    model_config = ConfigDict(populate_by_name=True)

    title: str = Field(default="", description="Project name or title")
    description: str = Field(default="", description="Brief project description")
    tech_stack: List[str] = Field(
        default_factory=list,
        alias="techStack",
        description="Technologies and tools used in the project",
    )
    github: str = Field(default="", description="GitHub repository URL")
    live_demo: str = Field(
        default="",
        alias="liveDemo",
        description="Live demo or deployment URL",
    )

    @field_validator("title", "description", "github", "live_demo", mode="before")
    @classmethod
    def _coerce_str(cls, v: object) -> str:
        return "" if v is None else str(v).strip()

    @field_validator("tech_stack", mode="before")
    @classmethod
    def _coerce_list(cls, v: object) -> List[str]:
        if not isinstance(v, list):
            return []
        return [str(x).strip() for x in v if x is not None and str(x).strip()]


class CVExperience(BaseModel):
    """A work experience entry extracted from the CV."""

    model_config = ConfigDict(populate_by_name=True)

    company: str = Field(default="", description="Company or organization name")
    position: str = Field(default="", description="Job title or position")
    start_date: str = Field(
        default="",
        alias="startDate",
        description="Employment start date (free-form string)",
    )
    end_date: str = Field(
        default="",
        alias="endDate",
        description="Employment end date or 'Present'",
    )
    description: str = Field(
        default="", description="Role responsibilities and achievements"
    )

    @field_validator("company", "position", "start_date", "end_date", "description", mode="before")
    @classmethod
    def _coerce_str(cls, v: object) -> str:
        return "" if v is None else str(v).strip()


class CVEducation(BaseModel):
    """An education entry extracted from the CV."""

    model_config = ConfigDict(populate_by_name=True)

    institution: str = Field(default="", description="School, university, or institution name")
    degree: str = Field(default="", description="Degree type, e.g. B.Sc., M.Sc., PhD")
    field: str = Field(default="", description="Field of study or major")
    start_date: str = Field(
        default="",
        alias="startDate",
        description="Enrollment start date (free-form string)",
    )
    end_date: str = Field(
        default="",
        alias="endDate",
        description="Graduation date or expected graduation date",
    )

    @field_validator("institution", "degree", "field", "start_date", "end_date", mode="before")
    @classmethod
    def _coerce_str(cls, v: object) -> str:
        return "" if v is None else str(v).strip()


class CVCertificate(BaseModel):
    """A certificate or credential extracted from the CV."""

    model_config = ConfigDict(populate_by_name=True)

    title: str = Field(default="", description="Certificate or credential name")
    issuer: str = Field(default="", description="Issuing organization or platform")
    date: str = Field(default="", description="Issue date (free-form string)")
    url: str = Field(default="", description="Verification URL")

    @field_validator("title", "issuer", "date", "url", mode="before")
    @classmethod
    def _coerce_str(cls, v: object) -> str:
        return "" if v is None else str(v).strip()


class CVPortfolio(BaseModel):
    """
    Complete structured portfolio extracted from a CV by Gemini.

    This is the canonical output schema for the AI CV parsing pipeline.
    Every field has a safe default so partial Gemini responses never
    raise validation errors.
    """

    model_config = ConfigDict(
        populate_by_name=True,
        json_schema_extra={
            "example": {
                "name": "Jane Smith",
                "title": "Senior Backend Engineer",
                "headline": "Building scalable backend systems with Python and Kubernetes",
                "summary": "5+ years of experience in distributed systems and cloud architecture.",
                "location": "Cairo, Egypt",
                "email": "jane@example.com",
                "phone": "+20 100 000 0000",
                "website": "https://janesmith.dev",
                "github": "https://github.com/janesmith",
                "linkedin": "https://linkedin.com/in/janesmith",
                "skills": ["Python", "FastAPI", "Docker", "PostgreSQL"],
                "projects": [],
                "experience": [],
                "education": [],
                "certificates": [],
            }
        },
    )

    # ── Identity ──────────────────────────────────────────────────────────────
    name: str = Field(default="", description="Full name of the candidate")
    title: str = Field(
        default="", description="Current or most recent job title"
    )
    headline: str = Field(
        default="", description="Short professional tagline (max 15 words)"
    )
    summary: str = Field(
        default="", description="Professional summary or objective statement"
    )
    location: str = Field(default="", description="City, Country")
    email: str = Field(default="", description="Primary email address")
    phone: str = Field(default="", description="Primary phone number")
    website: str = Field(default="", description="Personal website or portfolio URL")
    github: str = Field(default="", description="GitHub profile URL")
    linkedin: str = Field(default="", description="LinkedIn profile URL")

    # ── Content ───────────────────────────────────────────────────────────────
    skills: List[str] = Field(
        default_factory=list,
        description="Flat list of skills and technologies",
    )
    projects: List[CVProject] = Field(
        default_factory=list, description="Personal and professional projects"
    )
    experience: List[CVExperience] = Field(
        default_factory=list, description="Work experience entries"
    )
    education: List[CVEducation] = Field(
        default_factory=list, description="Education entries"
    )
    certificates: List[CVCertificate] = Field(
        default_factory=list, description="Certificates and credentials"
    )

    @field_validator("skills", mode="before")
    @classmethod
    def _coerce_skills(cls, v: object) -> List[str]:
        """Accept a list of strings or dicts with 'name' key (graceful coercion)."""
        if not isinstance(v, list):
            return []
        result: List[str] = []
        for item in v:
            if isinstance(item, str):
                result.append(item.strip())
            elif isinstance(item, dict):
                name = item.get("name") or item.get("skill") or ""
                if name:
                    result.append(str(name).strip())
        return [s for s in result if s]

    @field_validator(
        "name", "title", "headline", "summary", "location",
        "email", "phone", "website", "github", "linkedin",
        mode="before"
    )
    @classmethod
    def _coerce_none_to_empty(cls, v: object) -> str:
        """Convert None values from Gemini to empty strings."""
        if v is None:
            return ""
        return str(v).strip()

    @field_validator("projects", "experience", "education", "certificates", mode="before")
    @classmethod
    def _coerce_none_list_to_empty(cls, v: object) -> list:
        """Convert None list values from Gemini to empty lists."""
        if v is None or not isinstance(v, list):
            return []
        return v
