"""
ConnectHub AI Engine — AI Router
==================================

Placeholder for all AI-powered endpoints.

Phase 2 endpoints will include:
  - POST /ai/cv/parse       — Upload CV PDF, extract portfolio
  - POST /ai/resume/review  — AI resume review
  - POST /ai/ats/analyze    — ATS score against a job description
  - POST /ai/cover-letter   — Generate a tailored cover letter
  - POST /ai/career/advise  — Career advice from the AI advisor
  - POST /ai/github/import  — Import and analyse GitHub repositories

All endpoints will require Firebase authentication (Phase 2).
"""

from __future__ import annotations

from fastapi import APIRouter

router = APIRouter(prefix="/ai", tags=["AI"])


# ── Phase 2 endpoints will be added here ─────────────────────────────────────
# Example:
#
# @router.post("/cv/parse")
# async def parse_cv(
#     file: UploadFile = File(...),
#     current_user: str = Depends(get_current_user),
#     portfolio_svc: PortfolioService = Depends(get_portfolio_service),
# ) -> ApiResponse[PortfolioCreateResponse]:
#     ...
