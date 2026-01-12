import streamlit as st # type: ignore
from data.database import init_db
from core.state import init_state
from ui.pages import show_home, show_learn, show_quiz, show_progress, show_my_notes


def main():
    st.set_page_config(page_title="Personal Skill Builder AI", layout="wide")
    init_db()
    init_state()
    page = st.sidebar.radio("Go to", ["Home", "Learn", "My Notes", "Quiz", "Progress"])

    if page == "Home":
        show_home()
    elif page == "Learn":
        show_learn()
    elif page == "My Notes":
        show_my_notes()
    elif page == "Quiz":
        show_quiz()
    else:
        show_progress()


if __name__ == "__main__":
    main()
