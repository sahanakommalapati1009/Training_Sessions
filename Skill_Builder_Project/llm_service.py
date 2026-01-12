import json
import os
import time
from typing import Any, Dict, List, Optional
from dotenv import load_dotenv # type: ignore

load_dotenv()

def _require_env(name: str) -> str:
    val = os.getenv(name, "").strip()
    if not val:
        raise RuntimeError(
            f"{name} is missing. Add it to your .env file (same folder as app.py) or export it."
        )
    return val


def _get_client():
    from openai import OpenAI  # type: ignore
    api_key = _require_env("OPENAI_API_KEY")
    return OpenAI(api_key=api_key)


def _json_from_text(text: str) -> Any:
    """
    Robust JSON parsing: strips code fences and tries to parse JSON object/array.
    """
    t = text.strip()
    if t.startswith("```"):
        t = t.strip("`")
        t = t.replace("json\n", "", 1).strip()
    return json.loads(t)


def _call_openai_json(prompt: str, model: str = "gpt-4o-mini", timeout_s: int = 60) -> Any:
    client = _get_client()
    t0 = time.time()
    resp = client.responses.create(
        model=model,
        input=[
            {
                "role": "system",
                "content": (
                    "You are a strict JSON generator. "
                    "Return ONLY valid JSON. No markdown. No extra text."
                ),
            },
            {"role": "user", "content": prompt},
        ],
        temperature=0.2,
        max_output_tokens=1200,
    )
    dt = time.time() - t0
    out_text = resp.output_text.strip()
    data = _json_from_text(out_text)
    return data, dt


def generate_subtopics(topic: str, n: int = 8, model: str = "gpt-4o-mini") -> Dict[str, Any]:
    prompt = f"""
    Return JSON with this schema:
    {{
    "topic": "...",
    "subtopics": ["...", "..."]  // exactly {n} items
    }}

    Topic: {topic}

    Rules:
    - Subtopics must be concise (3 to 7 words each).
    - No numbering like "1)".
    - English only.
    """
    data, seconds = _call_openai_json(prompt, model=model)
    subs = data.get("subtopics", [])
    if not isinstance(subs, list):
        subs = []
    subs = [str(s).strip() for s in subs if str(s).strip()]
    subs = subs[:n]
    return {"topic": topic, "subtopics": subs, "seconds": seconds, "source": "openai"}


def generate_note(topic: str, subtopic: str, model: str = "gpt-4o-mini") -> Dict[str, Any]:
    prompt = f"""
    Return JSON with this schema:
    {{
    "subtopic": "...",
    "summary": "...",
    "key_points": ["...", "...", "..."],
    "example": {{
        "description": "...",
        "code": "..."
    }},
    "extra_tips": ["...", "..."]
    }}

    Topic: {topic}
    Subtopic: {subtopic}

    Rules:
    - English only.
    - Keep summary <= 2 sentences.
    - key_points: 3 to 5 bullets.
    - code: must be valid code for the topic context (if programming).
    """
    data, seconds = _call_openai_json(prompt, model=model)
    data["seconds"] = seconds
    return data


def generate_quiz(topic: str, subtopics: List[str], n: int = 10, model: str = "gpt-4o-mini") -> Dict[str, Any]:
    subs = ", ".join(subtopics[:12])
    prompt = f"""
    Return JSON with this schema:
    {{
    "topic": "...",
    "questions": [
        {{
        "q": "...",
        "choices": {{"A":"...","B":"...","C":"...","D":"..."}},
        "answer": "A",
        "explanation": "..."
        }}
    ]
    }}

    Topic: {topic}
    Subtopics: {subs}

    Rules:
    - English only.
    - Exactly {n} questions.
    - Mix difficulty: easy/medium/hard.
    - Each explanation must be 1-2 sentences.
    - answer must be one of A/B/C/D.
    """
    data, seconds = _call_openai_json(prompt, model=model)
    qs = data.get("questions", [])
    if not isinstance(qs, list):
        qs = []
    data["questions"] = qs[:n]
    data["seconds"] = seconds
    return data
