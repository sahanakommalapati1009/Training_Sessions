from datetime import datetime
import streamlit as st # type: ignore
from core.state import start_learning, kick_off_subtopics, generation_tick
from exports.builders import build_py_file, build_ipynb_file, build_pdf_file
from data.database import save_progress, load_progress, load_saved_notes, save_notes
import json

def show_home():
    st.title("🎯 Personal Skill Builder AI")
    st.caption("Flow: Generate Subtopics → Learn auto-generates Notes → Quiz auto-pre-generates → Progress.")
    topic = st.text_input("Enter a topic you want to learn", value=st.session_state.topic)
    c1, c2 = st.columns([1, 1])
    with c1:
        if st.button("Generate subtopics", use_container_width=True):
            if topic.strip():
                start_learning(topic)
                kick_off_subtopics(topic)
                st.success("Subtopics generated. Go to Learn.")
            else:
                st.warning("Please enter a topic.")
    with c2:
        if st.button("Reset", use_container_width=True):
            start_learning("")
            st.success("Reset done.")

    if st.session_state.topic and st.session_state.subtopics:
        st.subheader("Current Topic")
        st.write(f"**Topic:** {st.session_state.topic}")
        st.write(f"**Last subtopics generation time:** {st.session_state.subtopics_time:.2f}s")
        st.write("**Subtopics:**")
        for s in st.session_state.subtopics:
            st.write(f"- {s}")


def show_learn():
    st.title("📚 Learn")
    topic = st.session_state.topic.strip()
    if not topic:
        st.info("Go to Home and generate subtopics first.")
        return
    generation_tick()
    st.write(f"**Topic:** {topic}")
    # Progress bar for notes
    total = st.session_state.notes_total or len(st.session_state.subtopics)
    done = st.session_state.notes_done
    if total > 0:
        st.success(f"Notes progress: {done}/{total}")
        st.progress(min(done / total, 1.0))
    st.subheader("Subtopics and Notes")
    # Render each subtopic ONCE (no duplication)
    for sub in st.session_state.subtopics:
        note = st.session_state.notes_by_subtopic.get(sub)
        with st.expander(sub, expanded=False):
            if not note:
                st.write("Generating notes...")
            else:
                st.markdown(f"**Summary:** {note.get('summary','')}")
                st.markdown("**Key points:**")
                for kp in note.get("key_points", [])[:10]:
                    st.write(f"- {kp}")
                ex = note.get("example", {}) or {}
                if ex.get("code"):
                    st.markdown("**Example:**")
                    st.code(ex.get("code", ""), language="python")
                tips = note.get("extra_tips", []) or []
                if tips:
                    st.markdown("**Extra tips:**")
                    for t in tips[:10]:
                        st.write(f"- {t}")

    # Export area (only if at least 1 note exists)
    if st.session_state.notes_by_subtopic:
        if st.button("Save to my notes", use_container_width=True):
            item = {
                "timestamp": datetime.now().isoformat(timespec="seconds"),
                "topic": topic,
                "subtopics_json": json.dumps(st.session_state.subtopics, ensure_ascii=False),
                "notes_json": json.dumps(st.session_state.notes_by_subtopic, ensure_ascii=False),
            }
            save_notes(item)
            st.success("Saved to My Notes.")

        st.divider()
        st.subheader("Export Notes")

        notes_by_subtopic = st.session_state.notes_by_subtopic
        safe_topic = (topic or "notes").replace(" ", "_").lower()

        c1, c2, c3 = st.columns(3)

        with c1:
            py_bytes = build_py_file(topic, notes_by_subtopic)
            st.download_button(
                "Download .py",
                data=py_bytes,
                file_name=f"{safe_topic}_notes.py",
                mime="text/x-python",
                use_container_width=True,
            )

        with c2:
            ipynb_bytes = build_ipynb_file(topic, notes_by_subtopic)
            st.download_button(
                "Download .ipynb",
                data=ipynb_bytes,
                file_name=f"{safe_topic}_notes.ipynb",
                mime="application/x-ipynb+json",
                use_container_width=True,
            )

        with c3:
            pdf_bytes = build_pdf_file(topic, notes_by_subtopic)
            st.download_button(
                "Download PDF",
                data=pdf_bytes,
                file_name=f"{safe_topic}_notes.pdf",
                mime="application/pdf",
                use_container_width=True,
            )

    # Quiz readiness
    st.divider()
    if st.session_state.quiz is None:
        st.warning("Quiz is being generated (or not started yet). Keep this page open; it will appear soon.")
    else:
        st.success("Quiz is ready. Go to Quiz tab.")


def show_quiz():
    st.title("📝 Quiz")
    topic = st.session_state.topic.strip()
    if not topic:
        st.info("Go to Home and start a topic first.")
        return

    st.write(f"**Topic:** {topic}")

    quiz = st.session_state.quiz
    if not quiz or not quiz.get("questions"):
        st.warning("Quiz not ready yet. Go to Learn tab (it triggers auto-generation) and come back.")
        return

    questions = quiz["questions"]
    st.success("Quiz is ready (pre-generated).")

    # Render quiz form
    with st.form("quiz_form"):
        answers = {}
        for idx, q in enumerate(questions, start=1):
            st.markdown(f"**Q{idx}. {q.get('q','')}**")
            choices = q.get("choices", {})
            options = [f"A) {choices.get('A','')}", f"B) {choices.get('B','')}", f"C) {choices.get('C','')}", f"D) {choices.get('D','')}"]
            pick = st.radio("Select one:", options, key=f"q_{idx}")
            answers[idx] = pick[0]  # 'A'/'B'/'C'/'D'
            st.write("")

        submitted = st.form_submit_button("Submit Quiz", use_container_width=True)

    if submitted:
        correct = 0
        review = []
        for idx, q in enumerate(questions, start=1):
            chosen = answers.get(idx)
            ans = q.get("answer", "").strip().upper()
            ok = (chosen == ans)
            correct += 1 if ok else 0
            review.append(
                {
                    "q": q.get("q", ""),
                    "chosen": chosen,
                    "answer": ans,
                    "ok": ok,
                    "explanation": q.get("explanation", ""),
                }
            )

        score_pct = (correct / len(questions)) * 100 if questions else 0
        st.success(f"Score: {correct}/{len(questions)} ({score_pct:.1f}%)")

        with st.expander("Review answers", expanded=True):
            for i, r in enumerate(review, start=1):
                icon = "✅" if r["ok"] else "❌"
                st.markdown(f"**{icon} Q{i}. {r['q']}**")
                st.write(f"Your answer: **{r['chosen']}**")
                st.write(f"Correct answer: **{r['answer']}**")
                st.write(f"Explanation: {r['explanation']}")
                st.write("---")

        # Save to progress
        item = {
            "timestamp": datetime.now().isoformat(timespec="seconds"),
            "topic": topic,
            "score": correct,
            "total": len(questions),
            "percent": score_pct,
        }

        st.session_state.progress_log.append(item)
        save_progress(item)

st.success("Saved to Progress tab.")


def show_progress():
    st.title("📈 Progress")

    db_items = load_progress()

    if not db_items:
        st.info("No saved quiz attempts yet.")
        return

    for item in db_items:
        st.write(
            f"- **{item['timestamp']}** | Topic: **{item['topic']}** | "
            f"Score: **{item['score']}/{item['total']}** ({item['percent']:.1f}%)"
        )


def show_my_notes():
    st.title("📒 My Notes")

    items = load_saved_notes()

    if not items:
        st.info("No saved notes yet. Go to Learn and click 'Save to my notes'.")
        return

    for item in items:
        with st.expander(f"{item['topic']}  |  {item['timestamp']}", expanded=False):
            subtopics = []
            notes_by_subtopic = {}

            try:
                subtopics = json.loads(item["subtopics_json"])
                notes_by_subtopic = json.loads(item["notes_json"])
            except Exception:
                st.warning("Saved notes data is corrupted or unreadable.")
                continue

            st.write("**Subtopics:**")
            for s in subtopics:
                st.write(f"- {s}")

            st.divider()
            st.write("**Notes:**")

            for sub in subtopics:
                note = notes_by_subtopic.get(sub)
                if not note:
                    continue
                with st.expander(sub, expanded=False):
                    st.markdown(f"**Summary:** {note.get('summary','')}")
                    st.markdown("**Key points:**")
                    for kp in note.get("key_points", [])[:10]:
                        st.write(f"- {kp}")
                    ex = note.get("example", {}) or {}
                    if ex.get("code"):
                        st.markdown("**Example:**")
                        st.code(ex.get("code", ""), language="python")
                    tips = note.get("extra_tips", []) or []
                    if tips:
                        st.markdown("**Extra tips:**")
                        for t in tips[:10]:
                            st.write(f"- {t}")
