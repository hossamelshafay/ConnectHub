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

_SYSTEM_INSTRUCTIONS = """You are a strict, precise CV data extraction engine.
CRITICAL RULES (ZERO-HALLUCINATION POLICY):
1. You must ONLY use the provided portfolio / CV data.
2. Never invent, guess, or infer any information. Extract facts ONLY from the text.
3. If any section or field has no data, keep it empty. Use null for missing string fields, and [] for missing array fields.
4. Do NOT generate sample data, placeholder values, or example entries under any circumstances.
5. Do NOT generate fictional projects.
6. Do NOT generate fictional work experience.
7. Do NOT generate fictional education.
8. Do NOT generate fictional skills.
9. Do NOT generate fictional certificates.
10. If there is insufficient information for a section, explicitly leave that section empty (empty list or null).
11. Return ONLY valid JSON matching the exact schema. No markdown fences (no ```json```), no intro or outro.
12. Headline: concise professional tagline directly stated in the CV, or null if absent. Never fabricate a title or headline.
13. Title: current or most recent job title from the CV, or null if absent.
14. Summary: professional summary from CV, or null if absent.
15. Skills: flat list of strings representing only skills explicitly found in the CV.
16. The AI's responsibility is ONLY formatting, layout, wording improvements, and professional writing style. The AI must NOT create factual information."""


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

