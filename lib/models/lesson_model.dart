class LessonItem {
  final int id;
  final String date;
  final String topic;
  final String english;
  final String userSpanish;
  final String naturalSpanish;
  final String rule;

  const LessonItem({
    required this.id,
    required this.date,
    required this.topic,
    required this.english,
    required this.userSpanish,
    required this.naturalSpanish,
    required this.rule,
  });

  factory LessonItem.fromJson(Map<String, dynamic> json) {
    return LessonItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? DateTime.now().millisecondsSinceEpoch,
      date: json['date'] as String? ?? '',
      topic: json['topic'] as String? ?? 'General',
      english: json['english'] as String? ?? '',
      userSpanish: json['userSpanish'] as String? ?? '',
      naturalSpanish: json['naturalSpanish'] as String? ?? '',
      rule: json['rule'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'topic': topic,
        'english': english,
        'userSpanish': userSpanish,
        'naturalSpanish': naturalSpanish,
        'rule': rule,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
