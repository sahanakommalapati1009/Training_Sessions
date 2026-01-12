import io
import json
from datetime import datetime
from typing import Dict
from reportlab.lib.pagesizes import letter # type: ignore
from reportlab.pdfgen import canvas # type: ignore


def build_py_file(topic: str, notes_by_subtopic: Dict[str, dict]) -> bytes:
    lines = []
    lines.append(f'"""{topic} - Notes')
    lines.append(f"Generated: {datetime.now().isoformat()}")
    lines.append('"""')
    lines.append("")
    for sub, note in notes_by_subtopic.items():
        lines.append("#" + "-" * 70)
        lines.append(f"# {sub}")
        lines.append("#" + "-" * 70)
        lines.append("")
        lines.append(f"# Summary: {note.get('summary','')}")
        lines.append("")
        lines.append("# Key points:")
        for kp in note.get("key_points", [])[:10]:
            lines.append(f"# - {kp}")
        lines.append("")
        ex = note.get("example", {}) or {}
        if ex.get("description"):
            lines.append(f"# Example: {ex.get('description')}")
        code = ex.get("code", "").rstrip()
        if code:
            lines.append(code)
        lines.append("")
        tips = note.get("extra_tips", []) or []
        if tips:
            lines.append("# Extra tips:")
            for t in tips[:10]:
                lines.append(f"# - {t}")
        lines.append("")

    return ("\n".join(lines)).encode("utf-8")


def build_ipynb_file(topic: str, notes_by_subtopic: Dict[str, dict]) -> bytes:
    cells = []
    cells.append(
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [f"# {topic}\n", f"_Generated: {datetime.now().isoformat()}_\n"],
        }
    )

    for sub, note in notes_by_subtopic.items():
        md = []
        md.append(f"## {sub}\n")
        md.append(f"**Summary:** {note.get('summary','')}\n\n")
        md.append("**Key points:**\n")
        for kp in note.get("key_points", [])[:10]:
            md.append(f"- {kp}\n")
        md.append("\n")
        tips = note.get("extra_tips", []) or []
        if tips:
            md.append("**Extra tips:**\n")
            for t in tips[:10]:
                md.append(f"- {t}\n")
            md.append("\n")

        cells.append({"cell_type": "markdown", "metadata": {}, "source": md})

        ex = note.get("example", {}) or {}
        if ex.get("description"):
            cells.append(
                {
                    "cell_type": "markdown",
                    "metadata": {},
                    "source": [f"**Example:** {ex.get('description')}\n"],
                }
            )

        code = (ex.get("code") or "").rstrip()
        if code:
            cells.append(
                {
                    "cell_type": "code",
                    "execution_count": None,
                    "metadata": {},
                    "outputs": [],
                    "source": [code + "\n"],
                }
            )

    nb = {
        "cells": cells,
        "metadata": {
            "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"},
            "language_info": {"name": "python", "version": "3.x"},
        },
        "nbformat": 4,
        "nbformat_minor": 5,
    }

    return json.dumps(nb, ensure_ascii=False, indent=2).encode("utf-8")


def build_pdf_file(topic: str, notes_by_subtopic: Dict[str, dict]) -> bytes:
    buf = io.BytesIO()
    c = canvas.Canvas(buf, pagesize=letter)
    width, height = letter
    x, y = 50, height - 50

    def draw_line(text: str):
        nonlocal y
        if y < 60:
            c.showPage()
            y = height - 50
        c.drawString(x, y, text[:110])
        y -= 14

    c.setFont("Helvetica-Bold", 14)
    draw_line(topic)
    c.setFont("Helvetica", 10)
    draw_line(f"Generated: {datetime.now().isoformat()}")
    draw_line("")

    for sub, note in notes_by_subtopic.items():
        c.setFont("Helvetica-Bold", 12)
        draw_line(sub)
        c.setFont("Helvetica", 10)
        draw_line(f"Summary: {note.get('summary','')}")
        draw_line("Key points:")
        for kp in note.get("key_points", [])[:10]:
            draw_line(f" - {kp}")
        ex = note.get("example", {}) or {}
        if ex.get("description"):
            draw_line(f"Example: {ex.get('description')}")
        tips = note.get("extra_tips", []) or []
        if tips:
            draw_line("Extra tips:")
            for t in tips[:10]:
                draw_line(f" - {t}")
        draw_line("")

    c.save()
    return buf.getvalue()