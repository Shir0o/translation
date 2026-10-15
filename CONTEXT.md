# Domain Context: LingoDiff Translation Coach

A bilingual English-to-Spanish (EN → ES) translation coach and interactive analysis workbench.

## Glossary

### Workspace
The primary three-pane interactive drafting area where the user inputs English source text, types their Spanish translation draft, and compares against an official or generated reference translation.

### English Pointer
An interactive verbatim substring anchor in the English source text corresponding to an identified translation mistake, unnatural nuance, or positive alternative. Selecting or hovering on a pointer highlights its associated Critique Card, and vice versa.

### Word Diff
In-memory tokenized word-by-word visual comparison between the user's Spanish draft and the reference Spanish translation, highlighting additions in green and omissions/deletions in red strikethrough.

### Critique Card
A structured feedback item produced by the AI Tutor evaluating a specific span of translation. Contains:
- `category`: Grammar/Meaning Error (`error`), Unnatural/Literal Phrasing (`unnatural`), or Valid Alternative (`valid_alternative`).
- `grammar_topic`: Grammatical tag (e.g., *Por vs. Para*, *Subjunctive*, *False Friend*).
- `explanation`: Detailed educational breakdown of the divergence.
- `lesson_takeaway`: Concise, actionable rule suitable for flashcard study.

### Lessons Learned Notebook
A persistent personal notebook of saved translation rules, mistakes, and takeaways. Supports tagging, manual rule creation, deletion, and exports to Markdown (`.md`) and Anki-compatible CSV (`.csv`).

### AI Tutor Provider
Pluggable LLM completion backend configured with local API credentials, supporting:
- Google Gemini API (native REST generateContent with JSON mode)
- DeepSeek API (OpenAI-compatible chat completions)
- OpenAI-compatible endpoints
