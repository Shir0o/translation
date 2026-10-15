# Issue 06: Full macOS Desktop Shell, Responsive Panes, & Keyboard Shortcuts

Type: prototype
Status: resolved
Blocked by: 02, 03, 04, 05

## Question

How should the overall macOS workspace integrate the 2-column/3-column responsive layout, blurred reference toggle, settings modal/dialog, demo exercise loader, keyboard shortcuts (e.g. `Cmd+Enter` to analyze), and titlebar styling into a polished macOS desktop experience?

## Answer

Integrated into `lib/main.dart` with full desktop responsiveness and macOS styling:
1. Multi-pane workspace supporting both 2-column stacked and 3-column side-by-side view.
2. Official reference translation blur toggle (`🙈 Blur while typing: On/Off`).
3. Word-by-word visual diffing in-memory without external calls.
4. AI Tutor critique generation supporting Gemini JSON mode, DeepSeek, and OpenAI with `Cmd+Enter` keyboard shortcut.
5. Bidirectional pointer highlighting: clicking an English pointer scrolls to and flashes the critique card; hovering or clicking a critique card jumps to the English phrase.
6. Lessons Learned Notebook drawer with manual rule addition, removal, and native export dialogs for `.md` and Anki `.csv`.
7. Verified with end-to-end widget tests and built clean native macOS binary `build/macos/Build/Products/Debug/translation.app`.
