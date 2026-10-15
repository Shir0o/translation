# Wayfinder Map: LingoDiff Flutter macOS App

## Destination

A complete, production-grade native Flutter macOS desktop application for **LingoDiff Studio** that translates English paragraphs, provides in-memory visual word diffing against official translations, runs AI tutor critiques with interactive bidirectional English pointers, and manages a persistent Lessons Learned Notebook with Markdown/Anki CSV export.

## Notes

- Domain: Language learning, translation pedagogy, macOS desktop UX, Flutter.
- Skills to consult: `domain-modeling`, `grilling`, `flutter-build-responsive-layout`, `flutter-use-http-package`, `better-interface`.
- Architecture decisions locked:
  - State management: `flutter_riverpod`
  - Persistence: `shared_preferences` + local JSON file storage in Application Support
  - UI Theme: Dark slate-950 modern aesthetic with macOS desktop affordances (shortcuts, native menus)

## Decisions so far

<!-- index of closed tickets: - [<closed ticket title>](link): <one-line gist> -->

- [Scaffold Flutter macOS Project and Core Dependencies](.scratch/lingodiff-macos/issues/01-scaffold-flutter-macos-project.md): Initialized Flutter macOS app with Riverpod, HTTP, storage, CSV/file picker, and network entitlements. Verified build passes.
- [Word-by-Word Diff Algorithm in Pure Dart](.scratch/lingodiff-macos/issues/02-word-diff-engine.md): Implemented LCS-based tokenizer and coalesced word diff algorithm in pure Dart with full test coverage.
- [AI Tutor Multi-Provider Client & JSON Schema Parser](.scratch/lingodiff-macos/issues/03-ai-tutor-client.md): Implemented multi-provider LLM service (Gemini JSON mode, DeepSeek, OpenAI) and data models with full test coverage.
- [Lessons Learned Notebook Repository & File Exporters](.scratch/lingodiff-macos/issues/05-lessons-notebook-and-exports.md): Implemented local persistence and Markdown / Anki CSV file export helpers with full test coverage.
- [Interactive English Pointer Highlighting & Bidirectional Card Sync](.scratch/lingodiff-macos/issues/04-interactive-english-pointer-sync.md): Implemented pointer mapper, interactive rich-text span view, and synchronized critique cards.
- [Full macOS Desktop Shell, Responsive Panes, & Keyboard Shortcuts](.scratch/lingodiff-macos/issues/06-macos-desktop-ui-integration.md): Integrated the complete desktop workspace, topbar actions, settings modal, demo exercise, drawer, and macOS binary compilation.

## Not yet specified

- Audio / Text-to-speech pronunciation for English pointers and Spanish phrases.
- Custom custom API base URLs for local LLMs (e.g., Ollama / vLLM).
- Split-pane draggable divider resizing.

## Out of scope

- Mobile layout adaptations (iOS/Android specific navigation bars/drawers); this effort focuses on native macOS desktop.
- Cloud sync / multi-device user account authentication.
