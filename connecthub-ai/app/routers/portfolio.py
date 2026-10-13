"""
ConnectHub AI Engine — Portfolio Router
=========================================

Endpoints for portfolio management and CV processing.

Phase 3:
  - POST /portfolio/upload-cv — Upload a CV PDF, extract text, parse via Gemini,
                               and return structured portfolio JSON.
"""

from __future__ import annotations

from typing import Union

from fastapi import APIRouter, Depends, File, Request, UploadFile, status

from app.config.settings import settings
from app.dependencies.services import get_portfolio_service
from app.schemas.api_response import ApiResponse
from app.schemas.cv_portfolio_schema import CVPortfolio
from app.schemas.error_response import ErrorResponse
from app.schemas.website_schema import WebsitePortfolioInput, WebsitePortfolioOutput
from app.services.portfolio_service import PortfolioService

router = APIRouter(prefix="/portfolio", tags=["Portfolio"])


@router.post(
    "/upload-cv",
    response_model=ApiResponse[CVPortfolio],
    status_code=status.HTTP_200_OK,
    summary="Upload and parse a CV (PDF) into a structured portfolio",
    description=(
        "Upload a CV document in PDF format. The engine validates the file, extracts "
        "and normalizes plain text with PyMuPDF, parses it into structured portfolio data "
        "using Gemini 2.5 Flash, and validates the output against the portfolio schema.\n\n"
        "Returns the complete structured portfolio JSON."
    ),
    openapi_extra={
        "requestBody": {
            "required": True,
            "content": {
                "multipart/form-data": {
                    "schema": {
                        "type": "object",
                        "properties": {
                            "file": {
                                "type": "string",
                                "format": "binary",
                                "description": "CV file in PDF format (maximum 10MB).",
                            }
                        },
                        "required": ["file"],
                    }
                }
            },
        }
    },
    responses={
        status.HTTP_200_OK: {
            "description": "CV parsed and portfolio generated successfully.",
        },
        status.HTTP_400_BAD_REQUEST: {
            "description": "Validation failed (missing file, invalid format, corrupted PDF, no readable text).",
            "model": ErrorResponse,
        },
        status.HTTP_413_CONTENT_TOO_LARGE: {
            "description": "File size exceeds configured limit.",
            "model": ErrorResponse,
        },
        status.HTTP_502_BAD_GATEWAY: {
            "description": "AI service or response validation error.",
            "model": ErrorResponse,
        },
        status.HTTP_504_GATEWAY_TIMEOUT: {
            "description": "AI generation timed out.",
            "model": ErrorResponse,
        },
    },
)
async def upload_cv(
    request: Request,
    file: Union[UploadFile, str, None] = File(
        None,
        description="CV file in PDF format (maximum 10MB).",
    ),
    portfolio_service: PortfolioService = Depends(get_portfolio_service),
) -> ApiResponse[CVPortfolio]:
    """
    Handle CV upload and AI parsing request.
    Delegates pipeline execution to PortfolioService.
    """
    client_ip = request.client.host if request.client else "unknown"
    portfolio_data = await portfolio_service.generate_portfolio_from_cv(
        file=file,
        client_ip=client_ip,
    )
    return ApiResponse[CVPortfolio](
        success=True,
        message="CV parsed and portfolio generated successfully.",
        data=portfolio_data,
        version=settings.version,
    )


@router.post(
    "/generate-website",
    response_model=ApiResponse[WebsitePortfolioOutput],
    status_code=status.HTTP_200_OK,
    summary="Generate / format portfolio website data strictly from Firebase data without hallucinations",
    description=(
        "Formats and structures existing user portfolio data for website presentation. "
        "Adheres strictly to the Zero-Hallucination Policy: missing or empty sections "
        "remain completely empty. Never fabricates work experience, projects, skills, "
        "education, or certificates."
    ),
    responses={
        status.HTTP_200_OK: {
            "description": "Website portfolio formatted successfully.",
        },
        status.HTTP_502_BAD_GATEWAY: {
            "description": "AI hallucination detected and rejected or service failure.",
            "model": ErrorResponse,
        },
    },
)
async def generate_website(
    request: Request,
    payload: WebsitePortfolioInput,
    portfolio_service: PortfolioService = Depends(get_portfolio_service),
) -> ApiResponse[WebsitePortfolioOutput]:
    """
    Handle portfolio website generation / formatting request.
    Delegates to PortfolioService with strict fidelity verification.
    """
    client_ip = request.client.host if request.client else "unknown"
    result = await portfolio_service.generate_website_portfolio(
        raw_portfolio_data=payload,
        client_ip=client_ip,
    )
    return ApiResponse[WebsitePortfolioOutput](
        success=True,
        message="Portfolio website data generated successfully with zero fabrication.",
        data=result,
        version=settings.version,
    )

