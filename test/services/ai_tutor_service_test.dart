import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:translation/models/ai_settings.dart';
import 'package:translation/models/critique_model.dart';
import 'package:translation/services/ai_tutor_service.dart';

void main() {
  group('AITutorService & CritiqueModel', () {
    test('parses demo response accurately', () {
      final demo = AITutorService.getDemoResponse();
      expect(demo.critiques.length, equals(4));
      expect(demo.critiques[0].category, equals(CritiqueCategory.error));
      expect(demo.critiques[1].category, equals(CritiqueCategory.unnatural));
      expect(demo.critiques[3].category, equals(CritiqueCategory.validAlternative));
      expect(demo.generatedOfficialSpanish, isNotNull);
    });

    test('successfully parses mock Gemini JSON response', () async {
      final mockJson = jsonEncode({
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text': jsonEncode({
                    'overall_score': '90 / 100 — Excellent',
                    'summary': 'Very natural phrasing with minor stylistic note.',
                    'critiques': [
                      {
                        'english_segment': 'for three months',
                        'user_spanish': 'por tres meses',
                        'official_spanish': 'durante tres meses',
                        'category': 'unnatural',
                        'grammar_topic': 'Prepositions',
                        'explanation': 'Use durante instead of por.',
                        'lesson_takeaway': 'Prefer durante for duration.'
                      }
                    ]
                  })
                }
              ]
            }
          }
        ]
      });

      final mockClient = MockClient((request) async {
        expect(request.url.host, equals('generativelanguage.googleapis.com'));
        return http.Response(mockJson, 200, headers: {'content-type': 'application/json'});
      });

      final service = AITutorService(client: mockClient);
      final result = await service.analyzeTranslation(
        englishText: 'I have waited for three months.',
        userSpanish: 'He esperado por tres meses.',
        officialSpanish: '',
        settings: const AISettings(
          provider: AIProvider.gemini,
          apiKey: 'test-gemini-key',
          model: 'gemini-2.5-flash',
        ),
      );

      expect(result.overallScore, contains('90 / 100'));
      expect(result.critiques.length, equals(1));
      expect(result.critiques.first.englishSegment, equals('for three months'));
    });
  });
}
