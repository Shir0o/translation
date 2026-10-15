import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_settings.dart';
import '../models/critique_model.dart';

class AITutorService {
  final http.Client _client;

  AITutorService({http.Client? client}) : _client = client ?? http.Client();

  static const String systemPrompt = '''
You are an expert bilingual English-to-Spanish translation coach.
Compare:
1) ORIGINAL ENGLISH
2) USER'S SPANISH TRANSLATION
3) OFFICIAL SPANISH TRANSLATION (if blank, generate a natural reference translation in "generated_official_spanish").

Return ONLY valid JSON with this exact structure:
{
  "overall_score": "e.g., 82 / 100 — Strong grammar, minor literal phrasing",
  "summary": "1-2 sentence encouraging overview of their translation quality.",
  "generated_official_spanish": "Natural Spanish translation if the user left Official Spanish blank",
  "critiques": [
    {
      "english_segment": "EXACT verbatim substring copied from ORIGINAL ENGLISH that corresponds to this point",
      "user_spanish": "Exact substring from the user's Spanish",
      "official_spanish": "Corresponding phrase from the official Spanish (or ideal natural phrasing)",
      "category": "error" | "unnatural" | "valid_alternative",
      "grammar_topic": "Short tag (e.g., Por vs Para, Subjunctive, False Friend, Word Order)",
      "explanation": "Clear, concise explanation of WHY the user's translation is wrong, unnatural/literal, or why it's actually a valid alternative even though it differs from the official text.",
      "lesson_takeaway": "A 1-sentence actionable rule the student can save to their flashcards/notes."
    }
  ]
}
IMPORTANT: "english_segment" MUST be an exact case-matching substring of ORIGINAL ENGLISH so the UI can highlight it accurately.
''';

  /// Generates the critique from LLM backend
  Future<AITutorResponse> analyzeTranslation({
    required String englishText,
    required String userSpanish,
    required String officialSpanish,
    required AISettings settings,
  }) async {
    final apiKey = settings.apiKey.trim();
    if (apiKey.isEmpty) {
      throw StateError('Please enter your API Key in Settings to run AI analysis.');
    }

    final userPrompt = '''
ORIGINAL ENGLISH:
$englishText

USER'S SPANISH TRANSLATION:
$userSpanish

OFFICIAL SPANISH TRANSLATION:
${officialSpanish.trim().isEmpty ? '(Not provided - please generate one)' : officialSpanish}
''';

    switch (settings.provider) {
      case AIProvider.gemini:
        return _callGemini(englishText, userPrompt, settings);
      case AIProvider.deepseek:
        return _callOpenAICompatible(
          userPrompt: userPrompt,
          endpoint: 'https://api.deepseek.com/chat/completions',
          settings: settings,
        );
      case AIProvider.openai:
        return _callOpenAICompatible(
          userPrompt: userPrompt,
          endpoint: 'https://api.openai.com/v1/chat/completions',
          settings: settings,
        );
    }
  }

  Future<AITutorResponse> _callGemini(
    String englishText,
    String userPrompt,
    AISettings settings,
  ) async {
    final model = settings.model.trim().isNotEmpty
        ? settings.model.trim()
        : 'gemini-2.5-flash';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${settings.apiKey.trim()}',
    );

    final payload = {
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': [
        {
          'parts': [
            {'text': userPrompt}
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.2,
      }
    };

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      final errorBody = _tryParseJson(response.body);
      final errorMsg = errorBody?['error']?['message'] ?? response.body;
      throw Exception('Gemini API Error (${response.statusCode}): $errorMsg');
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = jsonMap['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No candidate response returned from Gemini.');
    }

    final parts = candidates[0]['content']?['parts'] as List<dynamic>?;
    final text = parts != null && parts.isNotEmpty ? parts[0]['text'] as String : null;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini candidate part returned empty text.');
    }

    return _parseAITutorJson(text);
  }

  Future<AITutorResponse> _callOpenAICompatible({
    required String userPrompt,
    required String endpoint,
    required AISettings settings,
  }) async {
    final url = Uri.parse(endpoint);
    final model = settings.model.trim().isNotEmpty
        ? settings.model.trim()
        : (settings.provider == AIProvider.deepseek ? 'deepseek-chat' : 'gpt-4o-mini');

    final payload = {
      'model': model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt}
      ],
      'response_format': {'type': 'json_object'},
      'temperature': 0.2,
    };

    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${settings.apiKey.trim()}',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      final errorBody = _tryParseJson(response.body);
      final errorMsg = errorBody?['error']?['message'] ?? response.body;
      throw Exception('API Error (${response.statusCode}): $errorMsg');
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = jsonMap['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('No choices returned in API response.');
    }

    final content = choices[0]['message']?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw Exception('Empty content returned from LLM choice.');
    }

    return _parseAITutorJson(content);
  }

  AITutorResponse _parseAITutorJson(String rawJson) {
    var cleaned = rawJson.trim();
    // Strip markdown code fences if LLM wrapped it
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    final decoded = jsonDecode(cleaned) as Map<String, dynamic>;
    return AITutorResponse.fromJson(decoded);
  }

  Map<String, dynamic>? _tryParseJson(String text) {
    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Returns the pre-canned demo analysis for instant offline testing
  static AITutorResponse getDemoResponse() {
    return AITutorResponse(
      overallScore: '76 / 100 — Good structure, a few English calques',
      summary:
          "Your tense progression is solid, but watch out for false friends ('realizar' vs 'darse cuenta') and literal English prepositions ('buscar por').",
      generatedOfficialSpanish:
          'Llevo tres meses buscando un departamento nuevo, pero todavía no he encontrado nada que se ajuste a mi presupuesto. El viernes pasado me di cuenta de que, si me mudara un poco más lejos del centro, podría ahorrar mucho dinero en el alquiler.',
      critiques: [
        const CritiqueItem(
          englishSegment:
              'I have been looking for a new apartment for three months',
          userSpanish:
              'He estado buscando por un nuevo apartamento por tres meses',
          officialSpanish: 'Llevo tres meses buscando un departamento nuevo',
          category: CritiqueCategory.error,
          grammarTopic: "Prepositions & 'Llevar + Gerundio'",
          explanation:
              "1) 'Buscar' already means 'to look for'—adding 'por' ('buscar por') is an English calque. Never put 'por' after buscar. 2) For ongoing actions over a duration, native speakers strongly prefer 'Llevo [time] + gerundio' over 'He estado + gerundio'.",
          lessonTakeaway:
              "Use 'buscar [algo]' (never 'buscar por'), and use 'llevar + [tiempo] + gerundio' to express 'have been doing for [time]'.",
        ),
        const CritiqueItem(
          englishSegment: 'fits my budget',
          userSpanish: 'cabe mi presupuesto',
          officialSpanish: 'se ajuste a mi presupuesto',
          category: CritiqueCategory.unnatural,
          grammarTopic: 'Vocab Nuance (Caber vs. Ajustarse) + Subjunctive',
          explanation:
              "'Caber' is for physical volume (fitting inside a box or car) and requires 'en'. For abstract limits like a budget or schedule, use 'ajustarse a' or 'adaptarse a'. Also, because the antecedent is negative ('no he encontrado nada que...'), the verb must be in the subjunctive ('se ajuste' / 'quepa').",
          lessonTakeaway:
              "After negative antecedents ('nada que...'), always use the subjunctive. For budgets/plans, use 'ajustarse a' instead of 'caber'.",
        ),
        const CritiqueItem(
          englishSegment: 'I realized that',
          userSpanish: 'me realicé que',
          officialSpanish: 'me di cuenta de que',
          category: CritiqueCategory.error,
          grammarTopic: 'False Friend (Realizar vs. Darse cuenta de)',
          explanation:
              "Classic false friend! 'Realizar' means to carry out, accomplish, or fulfill a project. To mean 'realize' in the mental sense (coming to understand something), always use 'darse cuenta de que'.",
          lessonTakeaway:
              "'Realize' (mental awareness) = 'darse cuenta de que'. 'Realizar' = to carry out/accomplish.",
        ),
        const CritiqueItem(
          englishSegment: 'on rent',
          userSpanish: 'en la renta',
          officialSpanish: 'en el alquiler',
          category: CritiqueCategory.validAlternative,
          grammarTopic: 'Regional Vocabulary (Renta vs. Alquiler)',
          explanation:
              "The official translation uses 'el alquiler', which is standard across Spain and much of South America, but 'la renta' is completely natural and standard in Mexico and the US. Your choice here is 100% valid!",
          lessonTakeaway:
              "Both 'la renta' (Mexico/LatAm) and 'el alquiler' (Spain/South America) are natural translations for housing rent.",
        ),
      ],
    );
  }
}
