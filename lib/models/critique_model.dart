enum CritiqueCategory {
  error,
  unnatural,
  validAlternative;

  static CritiqueCategory fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'error':
        return CritiqueCategory.error;
      case 'valid_alternative':
      case 'validalternative':
      case 'valid':
        return CritiqueCategory.validAlternative;
      case 'unnatural':
      default:
        return CritiqueCategory.unnatural;
    }
  }

  String get label {
    switch (this) {
      case CritiqueCategory.error:
        return 'Grammar / Meaning Error';
      case CritiqueCategory.unnatural:
        return 'Unnatural / Literal Phrasing';
      case CritiqueCategory.validAlternative:
        return 'Valid Alternative';
    }
  }
}

class CritiqueItem {
  final String englishSegment;
  final String userSpanish;
  final String officialSpanish;
  final CritiqueCategory category;
  final String grammarTopic;
  final String explanation;
  final String lessonTakeaway;

  const CritiqueItem({
    required this.englishSegment,
    required this.userSpanish,
    required this.officialSpanish,
    required this.category,
    required this.grammarTopic,
    required this.explanation,
    required this.lessonTakeaway,
  });

  factory CritiqueItem.fromJson(Map<String, dynamic> json) {
    return CritiqueItem(
      englishSegment: json['english_segment'] as String? ?? '',
      userSpanish: json['user_spanish'] as String? ?? '',
      officialSpanish: json['official_spanish'] as String? ?? '',
      category: CritiqueCategory.fromString(json['category'] as String?),
      grammarTopic: json['grammar_topic'] as String? ?? 'Translation Nuance',
      explanation: json['explanation'] as String? ?? '',
      lessonTakeaway: json['lesson_takeaway'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'english_segment': englishSegment,
        'user_spanish': userSpanish,
        'official_spanish': officialSpanish,
        'category': category.name,
        'grammar_topic': grammarTopic,
        'explanation': explanation,
        'lesson_takeaway': lessonTakeaway,
      };
}

class AITutorResponse {
  final String overallScore;
  final String summary;
  final String? generatedOfficialSpanish;
  final List<CritiqueItem> critiques;

  const AITutorResponse({
    required this.overallScore,
    required this.summary,
    this.generatedOfficialSpanish,
    required this.critiques,
  });

  factory AITutorResponse.fromJson(Map<String, dynamic> json) {
    final rawCritiques = json['critiques'] as List<dynamic>? ?? [];
    return AITutorResponse(
      overallScore: json['overall_score'] as String? ?? 'Evaluated',
      summary: json['summary'] as String? ?? '',
      generatedOfficialSpanish: json['generated_official_spanish'] as String?,
      critiques: rawCritiques
          .whereType<Map<String, dynamic>>()
          .map(CritiqueItem.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'overall_score': overallScore,
        'summary': summary,
        'generated_official_spanish': generatedOfficialSpanish,
        'critiques': critiques.map((c) => c.toJson()).toList(),
      };
}
