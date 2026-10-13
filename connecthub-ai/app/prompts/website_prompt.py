"""
ConnectHub AI Engine — Website Portfolio Prompt Builder
=======================================================

Builds the structured Gemini prompt for formatting / enhancing portfolio
website presentation data strictly from validated Firebase records.

Adheres strictly to the ZERO-HALLUCINATION POLICY:
- If a section is marked empty, it MUST remain empty.
- Never invent projects, experiences, educations, certificates, or skills.
- The AI's responsibility is ONLY formatting, layout, wording improvements,
  and professional writing style of existing content.
"""

from __future__ import annotations

import json
from typing import Any, Dict


WEBSITE_SYSTEM_INSTRUCTIONS = """You are a professional portfolio website formatting engine.
CRITICAL CONSTRAINTS (ZERO-HALLUCINATION POLICY):
1. You must ONLY use the provided portfolio data.
2. Never invent, guess, or infer any information.
3. If any section is empty, keep it empty.
4. Do NOT generate sample data under any circumstances.
5. Do NOT generate fictional projects.
6. Do NOT generate fictional work experience.
7. Do NOT generate fictional education.
8. Do NOT generate fictional skills.
9. Do NOT generate fictional certificates.
10. If there is insufficient information, explicitly render the section as empty.
11. The AI's responsibility is ONLY:
    - formatting
    - layout
    - wording improvements
    - professional writing style
    The AI must NOT create factual information.
12. Return ONLY a valid JSON object matching the exact input structure. No markdown fences (no ```json```), no intro or outro."""


def build_website_prompt(validated_portfolio: Dict[str, Any]) -> str:
    """
    Build a Gemini prompt for formatting a user's portfolio website data.
    Ensures empty sections are explicitly marked and strictly maintained.
    """
    portfolio_json = json.dumps(validated_portfolio, indent=2, ensure_ascii=False)
    return (
        f"{WEBSITE_SYSTEM_INSTRUCTIONS}\n\n"
        f"STRICT INSTRUCTIONS FOR EMPTY SECTIONS:\n"
        f"- If 'projects' is empty ([]), output must have 'projects': [].\n"
        f"- If 'experience' is empty ([]), output must have 'experience': [].\n"
        f"- If 'education' is empty ([]), output must have 'education': [].\n"
        f"- If 'certificates' is empty ([]), output must have 'certificates': [].\n"
        f"- If 'skills' is empty ([]), output must have 'skills': [].\n"
        f"- If 'bio' or 'about' is empty or null, keep it as empty string or null.\n\n"
        f"INPUT PORTFOLIO DATA TO FORMAT:\n"
        f"---\n"
        f"{portfolio_json}\n"
        f"---\n\n"
        f"Return the formatted JSON object now."
    )
