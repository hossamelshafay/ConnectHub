"""
ConnectHub AI Engine — Website Portfolio Schemas
=================================================

Pydantic schemas for portfolio website generation and validation.
Strictly guarantees faithful representation of Firebase data.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field


class WebsitePortfolioInput(BaseModel):
    """
    Incoming portfolio data loaded from Firebase or user session.
    """

    uid: str = Field(default="", description="Firebase UID of the user")
    username: Optional[str] = Field(default=None, description="Username")
    profile_slug: Optional[str] = Field(default=None, description="URL profile slug")
    name: Optional[str] = Field(default=None, description="Full name")
    headline: Optional[str] = Field(default=None, description="Professional headline")
    bio: Optional[str] = Field(default=None, description="Short bio")
    about: Optional[str] = Field(default=None, description="About summary")
    location: Optional[str] = Field(default=None, description="Location")
    email: Optional[str] = Field(default=None, description="Contact email")
    phone: Optional[str] = Field(default=None, description="Contact phone")
    profile_image: Optional[str] = Field(default=None, description="Profile picture URL")
    resume_url: Optional[str] = Field(default=None, description="Resume download URL")
    skills: List[str] = Field(default_factory=list, description="List of user skills")
    projects: List[Dict[str, Any]] = Field(
        default_factory=list, description="List of projects from Firebase"
    )
    experience: List[Dict[str, Any]] = Field(
        default_factory=list, description="List of experience items from Firebase"
    )
    education: List[Dict[str, Any]] = Field(
        default_factory=list, description="List of education records from Firebase"
    )
    certificates: List[Dict[str, Any]] = Field(
        default_factory=list, description="List of certificates from Firebase"
    )


class WebsitePortfolioOutput(BaseModel):
    """
    Validated portfolio website output guaranteed to have zero hallucinations.
    """

    uid: str = Field(default="", description="Firebase UID of the user")
    username: Optional[str] = Field(default=None, description="Username")
    profile_slug: Optional[str] = Field(default=None, description="URL profile slug")
    name: Optional[str] = Field(default=None, description="Full name")
    headline: Optional[str] = Field(default=None, description="Professional headline")
    bio: Optional[str] = Field(default=None, description="Short bio")
    about: Optional[str] = Field(default=None, description="About summary")
    location: Optional[str] = Field(default=None, description="Location")
    email: Optional[str] = Field(default=None, description="Contact email")
    phone: Optional[str] = Field(default=None, description="Contact phone")
    profile_image: Optional[str] = Field(default=None, description="Profile picture URL")
    resume_url: Optional[str] = Field(default=None, description="Resume download URL")
    skills: List[str] = Field(default_factory=list, description="Faithful list of skills")
    projects: List[Dict[str, Any]] = Field(
        default_factory=list, description="Faithful list of projects"
    )
    experience: List[Dict[str, Any]] = Field(
        default_factory=list, description="Faithful list of work experiences"
    )
    education: List[Dict[str, Any]] = Field(
        default_factory=list, description="Faithful list of education entries"
    )
    certificates: List[Dict[str, Any]] = Field(
        default_factory=list, description="Faithful list of certificates"
    )
    empty_sections: List[str] = Field(
        default_factory=list, description="List of sections explicitly identified as empty"
    )
