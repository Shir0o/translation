# Issue 05: Lessons Learned Notebook Repository & File Exporters

Type: task
Status: resolved
Blocked by: 01

## Question

How should lessons be persisted locally with add/remove/view operations and exported to Markdown files and Anki-compatible CSV files using macOS file save pickers or local app directory saving?

## Answer

Implemented `LessonItem` model (`lib/models/lesson_model.dart`) and `LessonsRepository` (`lib/services/lessons_repository.dart`). Handled dual persistence (SharedPreferences with Application Support JSON file fallback), generated Markdown summaries and Anki flashcard CSVs with proper delimiter and quote escaping (`csv.encode`), and integrated `FilePicker.saveFile` for native macOS export dialogs. Verified with comprehensive unit tests.
