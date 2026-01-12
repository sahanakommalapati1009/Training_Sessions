import streamlit as st # type: ignore
from llm_service import generate_note, generate_quiz, generate_subtopics
from data.database import load_progress


def init_state():
    defaults = {
        "topic": "",
        "subtopics": [],
        "subtopics_time": None,
        "notes_by_subtopic": {}, 
        "notes_total": 0,
        "notes_done": 0,
        "quiz": None,
        "quiz_time": None,
        "generation_phase": None,  
        "note_index": 0,
        "quiz_requested_n": 10,
        "progress_log": [], 
    }
    # ensure all keys exist
    for k, v in defaults.items():
        if k not in st.session_state:
            st.session_state[k] = v
    if not st.session_state.progress_log:
        st.session_state.progress_log = load_progress()



def start_learning(topic: str):
    st.session_state.topic = topic.strip()
    st.session_state.subtopics = []
    st.session_state.subtopics_time = None
    st.session_state.notes_by_subtopic = {}
    st.session_state.notes_total = 0
    st.session_state.notes_done = 0
    st.session_state.quiz = None
    st.session_state.quiz_time = None
    st.session_state.generation_phase = None
    st.session_state.note_index = 0


def kick_off_subtopics(topic: str):
    with st.spinner("Generating subtopics..."):
        r = generate_subtopics(topic, n=8)
    st.session_state.subtopics = r["subtopics"]
    st.session_state.subtopics_time = r["seconds"]
    st.session_state.notes_total = len(st.session_state.subtopics)
    st.session_state.generation_phase = "notes"
    st.session_state.note_index = 0
    st.session_state.notes_done = 0

def generation_tick():
    """
    Runs ONE unit of work per rerun:
    - If phase == notes: generate next note
    - If phase == quiz: generate quiz once
    """
    topic = st.session_state.topic.strip()
    subtopics = st.session_state.subtopics

    if not topic or not subtopics:
        return

    if st.session_state.generation_phase == "notes":
        i = st.session_state.note_index
        if i >= len(subtopics):
            st.session_state.generation_phase = "quiz"
            st.rerun()
            return

        sub = subtopics[i]
        note = generate_note(topic, sub)
        st.session_state.notes_by_subtopic[sub] = note
        st.session_state.note_index += 1
        st.session_state.notes_done = len(st.session_state.notes_by_subtopic)
        st.rerun()

    if st.session_state.generation_phase == "quiz":
        if st.session_state.quiz is None:
            with st.spinner("Pre-generating quiz (OpenAI)..."):
                q = generate_quiz(
                    topic,
                    subtopics=subtopics,
                    n=int(st.session_state.quiz_requested_n),
                )
            st.session_state.quiz = q
            st.session_state.quiz_time = q.get("seconds")
        st.session_state.generation_phase = None
        st.rerun()
