# LingoDiff Studio (macOS)

An AI-powered bilingual English → Spanish (EN → ES) translation coach and side-by-side interactive workbench built in Flutter for macOS.

![macOS Desktop Support](https://img.shields.io/badge/Platform-macOS%20Desktop-black?logo=apple)
![Flutter](https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

---

## Features

- **Side-by-Side 3-Pane Drafting Workspace**:
  - Panel 1: Original English source text with interactive pointer mode.
  - Panel 2: Student Spanish translation drafting area.
  - Panel 3: Official / reference Spanish translation with privacy blur toggle (`🙈 Blur while typing`).
- **In-Memory Word-by-Word Diff Engine**:
  - Pure Dart LCS (Longest Common Subsequence) diff algorithm.
  - Color-coded tokens highlighting added, removed, and matching phrases without external cloud calls.
- **Multi-Provider AI Tutoring**:
  - Direct integration with **Google Gemini** (structured JSON mode & system instruction), **DeepSeek**, and **OpenAI-compatible** APIs.
  - Generates detailed grammar critique cards, explanations of false friends, and flashcard takeaways.
  - Includes an offline **Demo Exercise** to test features immediately without an API key.
- **Bidirectional Interactive English Pointers**:
  - Highlights verbatim English segments linked to translation errors or stylistic nuances.
  - Clicking an English pointer automatically scrolls to and focuses its critique card.
  - Hovering/clicking a critique card highlights the associated English text.
- **Lessons Learned Notebook**:
  - Save critique rules directly from feedback cards or manually record translation tips.
  - Export notebook to **Markdown (`.md`)** notes or **Anki-compatible CSV (`.csv`)** flashcard decks.
- **Native macOS Desktop Ergonomics**:
  - Dark Slate-950 aesthetic.
  - `Cmd + Enter` keyboard shortcut to trigger AI analysis.
  - Native macOS file save dialogs via `FilePicker`.

---

## Getting Started

### Prerequisites

- macOS 12+ (Apple Silicon or Intel)
- [Flutter SDK](https://flutter.dev/docs/get-started/install/macos) (version 3.24 or higher recommended)
- Xcode (for building macOS native binary)

### Running Locally

1. Clone this repository:
   ```bash
   git clone https://github.com/Shir0o/translation.git
   cd translation
   ```

2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```

3. Run on macOS:
   ```bash
   flutter run -d macos
   ```

### Running Tests

```bash
flutter test
```

### Building macOS Application

```bash
flutter build macos --release
```
The compiled application will be located at `build/macos/Build/Products/Release/translation.app`.

### Packaging macOS Disk Images (.dmg)

To package standalone `.dmg` installers for Apple Silicon (M chips), Intel (x86_64), and Universal systems:

```bash
./scripts/package_macos_dmg.sh
```

Packaged installers and SHA256 checksums will be generated in `dist/`:
- `LingoDiff-macOS-arm64.dmg` (Apple Silicon M1/M2/M3/M4)
- `LingoDiff-macOS-x86_64.dmg` (Intel x86_64)
- `LingoDiff-macOS-universal.dmg` (Universal binary)
- `SHA256SUMS.txt`

---

## Configuration

Click the **⚙️ API Key** button in the top navigation bar to select your preferred AI provider:
- **Google Gemini**: Set your Gemini API key (default model: `gemini-2.5-flash`).
- **DeepSeek**: Set your DeepSeek API key (default model: `deepseek-chat`).
- **OpenAI Compatible**: Set your API key and model name (default: `gpt-4o-mini`).

Keys are stored locally in your Mac's secure user preferences.

---

## License

This project is open-source under the [MIT License](LICENSE).
