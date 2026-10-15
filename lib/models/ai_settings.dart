enum AIProvider {
  gemini,
  deepseek,
  openai;

  static AIProvider fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'deepseek':
        return AIProvider.deepseek;
      case 'openai':
        return AIProvider.openai;
      case 'gemini':
      default:
        return AIProvider.gemini;
    }
  }

  String get displayName {
    switch (this) {
      case AIProvider.gemini:
        return 'Google Gemini API';
      case AIProvider.deepseek:
        return 'DeepSeek API';
      case AIProvider.openai:
        return 'OpenAI Compatible API';
    }
  }

  String get defaultModel {
    switch (this) {
      case AIProvider.gemini:
        return 'gemini-2.5-flash';
      case AIProvider.deepseek:
        return 'deepseek-chat';
      case AIProvider.openai:
        return 'gpt-4o-mini';
    }
  }
}

class AISettings {
  final AIProvider provider;
  final String apiKey;
  final String model;

  const AISettings({
    this.provider = AIProvider.gemini,
    this.apiKey = '',
    this.model = 'gemini-2.5-flash',
  });

  AISettings copyWith({
    AIProvider? provider,
    String? apiKey,
    String? model,
  }) {
    return AISettings(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
    );
  }
}
