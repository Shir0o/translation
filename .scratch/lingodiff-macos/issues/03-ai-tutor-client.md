# Issue 03: AI Tutor Multi-Provider Client & JSON Schema Parser

Type: task
Status: resolved
Blocked by: 01

## Question

How should the AI client support Gemini REST API (with `systemInstruction` and `responseMimeType: application/json`), DeepSeek, and OpenAI endpoints, safely handling network failures, JSON parsing of critique models, and fallback generation of missing official reference translations?

## Answer

Created `AITutorService` (`lib/services/ai_tutor_service.dart`), `CritiqueModel` (`lib/models/critique_model.dart`), and `AISettings` (`lib/models/ai_settings.dart`). Supported Google Gemini via its native v1beta `generateContent` REST endpoint with structured JSON mode and system instruction, as well as OpenAI/DeepSeek chat completion endpoints. Included robust code-fence cleanup, error message propagation, and an offline demo runner (`AITutorService.getDemoResponse()`). Verified with automated unit tests.
