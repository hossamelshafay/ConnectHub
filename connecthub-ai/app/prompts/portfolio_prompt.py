"""
ConnectHub AI Engine — Portfolio Prompt Builder
================================================

Builds the structured Gemini prompt for CV → Portfolio extraction.

The prompt instructs Gemini to:
  - Return ONLY valid JSON (no markdown, no explanation, no comments).
  - Fill every field in the schema with extracted values.
  - Use null / empty-string / empty-array defaults for missing fields.
  - Never invent or hallucinate data not present in the CV.

Usage:
    from app.prompts.portfolio_prompt import build_portfolio_prompt

    prompt = build_portfolio_prompt(cv_text)
    json_str = await gemini_service.generate_content(prompt)
"""

import re

# Compact JSON schema to minimize input token count while retaining exact fields
_OUTPUT_SCHEMA = '{"name":"","title":"","headline":"","summary":"","location":"","email":"","phone":"","website":"","github":"","linkedin":"","skills":[],"projects":[{"title":"","description":"","techStack":[],"github":"","liveDemo":""}],"experience":[{"company":"","position":"","startDate":"","endDate":"","description":""}],"education":[{"institution":"","degree":"","field":"","startDate":"","endDate":""}],"certificates":[{"title":"","issuer":"","date":"","url":""}]}'

_SYSTEM_INSTRUCTIONS = """You are a precise CV data extraction engine.
RULES:
1. Return ONLY valid JSON matching the exact schema. No markdown fences (no ```json```), no intro or outro.
2. Extract facts ONLY from the CV text. Never hallucinate or invent data.
3. Use null for missing string fields. Use [] for missing array fields.
4. Skills: flat list of strings.
5. Dates: string format as found in CV (e.g. "2020 - 2023", "Present").
6. Headline: concise professional tagline (max 15 words).
7. Title: current or most recent job title.
8. Summary: professional summary from CV, or null if absent.
9. Strip excessive whitespace and clean text values."""


def build_portfolio_prompt(cv_text: str) -> str:
    """
    Build an optimized Gemini prompt for CV -> Portfolio extraction.
    Collapses redundant blank lines to minimize token usage.
    """
    clean_cv = re.sub(r"\n{3,}", "\n\n", cv_text.strip())
    return (
        f"{_SYSTEM_INSTRUCTIONS}\n\n"
        f"OUTPUT SCHEMA (fill every field):\n{_OUTPUT_SCHEMA}\n\n"
        f"CV TEXT TO EXTRACT FROM:\n---\n{clean_cv}\n---\n\n"
        f"Return the JSON object now."
    )

