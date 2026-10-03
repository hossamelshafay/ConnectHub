"""
ConnectHub AI Engine — Portfolio Schemas
=========================================

Pydantic v2 schemas for portfolio data structures.

Phase 1: Skeleton structure only.
Phase 2 (AI CV Agent): Full field definitions will be added here once
the CV parsing workflow is implemented.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field


class PortfolioSkill(BaseModel):
    """A single skill entry extracted from a CV."""

    name: str = Field(description="Skill name, e.g. 'Python'")
    level: Optional[str] = Field(
        default=None,
        description="Proficiency level: beginner | intermediate | advanced | expert",
    )


class PortfolioExperience(BaseModel):
    """A single work experience entry extracted from a CV."""

    title: str = Field(description="Job title")
    company: str = Field(description="Company name")
    start_date: Optional[str] = Field(default=None, description="Start date (free-form)")
    end_date: Optional[str] = Field(
        default=None, description="End date or 'Present'"
    )
    description: Optional[str] = Field(
        default=None, description="Role summary / achievements"
    )


class PortfolioEducation(BaseModel):
    """A single education entry extracted from a CV."""

    institution: str = Field(description="School or university name")
    degree: Optional[str] = Field(default=None, description="Degree or qualification")
    field_of_study: Optional[str] = Field(default=None, description="Major / specialization")
    graduation_year: Optional[str] = Field(default=None, description="Graduation year")


class PortfolioData(BaseModel):
    """
    Core portfolio data model.

    This schema will be populated by the AI CV Agent in Phase 2.
    For now it serves as the authoritative structural contract between
    the Gemini service, validation layer, and Firestore persistence.
    """

    # ── Identity ──────────────────────────────────────────────────────────────
    full_name: Optional[str] = Field(default=None, description="Candidate full name")
    email: Optional[str] = Field(default=None, description="Contact email address")
    phone: Optional[str] = Field(default=None, description="Contact phone number")
    linkedin_url: Optional[str] = Field(
        default=None, description="LinkedIn profile URL"
    )
    github_url: Optional[str] = Field(
        default=None, description="GitHub profile URL"
    )
    website_url: Optional[str] = Field(
        default=None, description="Personal website or portfolio URL"
    )

    # ── Summary ───────────────────────────────────────────────────────────────
    summary: Optional[str] = Field(
        default=None, description="Professional summary / objective statement"
    )

    # ── Content ───────────────────────────────────────────────────────────────
    skills: List[PortfolioSkill] = Field(
        default_factory=list, description="Extracted skills"
    )
    experience: List[PortfolioExperience] = Field(
        default_factory=list, description="Work experience entries"
    )
    education: List[PortfolioEducation] = Field(
        default_factory=list, description="Education entries"
    )
    certifications: List[str] = Field(
        default_factory=list, description="Certification names"
    )
    languages: List[str] = Field(
        default_factory=list, description="Spoken languages"
    )

    # ── Raw / metadata ────────────────────────────────────────────────────────
    raw_text: Optional[str] = Field(
        default=None,
        description="Raw extracted PDF text (stored for debugging; not displayed)",
    )
    metadata: Dict[str, Any] = Field(
        default_factory=dict,
        description="Arbitrary metadata attached during processing",
    )


class PortfolioCreateRequest(BaseModel):
    """Request payload for portfolio creation (Phase 2: will include file upload)."""

    user_id: str = Field(description="Firebase UID of the authenticated user")


class PortfolioCreateResponse(BaseModel):
    """Response payload returned after a portfolio is created or updated."""

    portfolio_id: str = Field(description="Firestore document ID of the portfolio")
    user_id: str = Field(description="Firebase UID of the owner")
    status: str = Field(
        default="pending",
        description="Processing status: pending | processing | complete | failed",
    )
    portfolio: Optional[PortfolioData] = Field(
        default=None,
        description="Populated portfolio data (present when status is 'complete')",
    )
