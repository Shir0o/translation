import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translation/models/lesson_model.dart';
import 'package:translation/services/lessons_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LessonsRepository & Exporters', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    final testLessons = [
      const LessonItem(
        id: 101,
        date: '2026-10-14',
        topic: 'Prepositions',
        english: 'looking for an apartment',
        userSpanish: 'buscando por un apartamento',
        naturalSpanish: 'buscando un departamento',
        rule: 'Never put "por" after buscar.',
      ),
      const LessonItem(
        id: 102,
        date: '2026-10-14',
        topic: 'False Friends',
        english: 'I realized that',
        userSpanish: 'me realicé que',
        naturalSpanish: 'me di cuenta de que',
        rule: 'Realize = darse cuenta de que.',
      ),
    ];

    test('persists and reloads lessons via SharedPreferences', () async {
      final repo = LessonsRepository();
      await repo.saveLessons(testLessons);

      final loaded = await repo.loadLessons();
      expect(loaded.length, equals(2));
      expect(loaded.first.topic, equals('Prepositions'));
      expect(loaded.last.naturalSpanish, equals('me di cuenta de que'));
    });

    test('generates clean Markdown format', () {
      final md = LessonsRepository.exportToMarkdown(testLessons);
      expect(md, contains('# Spanish Translation Lessons Learned'));
      expect(md, contains('## Prepositions (2026-10-14)'));
      expect(md, contains('- **English Trigger:** "looking for an apartment"'));
      expect(md, contains('- **My Draft:** ~~buscando por un apartamento~~'));
      expect(md, contains('- **Natural Spanish:** **buscando un departamento**'));
      expect(md, contains('- **Takeaway:** Never put "por" after buscar.'));
    });

    test('generates valid Anki CSV with correct columns', () {
      final csv = LessonsRepository.exportToAnkiCSV(testLessons);
      expect(csv, contains('English Source,Natural Spanish,Avoid / My Mistake,Grammar Rule,Topic'));
      expect(csv, contains('looking for an apartment'));
      expect(csv, contains('buscando un departamento'));
      expect(csv, contains('Never put ""por"" after buscar.'));
    });
  });
}
