import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson_model.dart';

class LessonsRepository {
  static const String _storageKey = 'lingodiff_lessons';

  /// Loads saved lessons from SharedPreferences (or fallback local JSON)
  Future<List<LessonItem>> loadLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(LessonItem.fromJson)
            .toList();
      } catch (_) {}
    }

    // Secondary fallback: local file in ApplicationDocumentsDirectory
    try {
      final file = await _getFallbackFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final decoded = jsonDecode(content) as List<dynamic>;
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(LessonItem.fromJson)
            .toList();
      }
    } catch (_) {}

    return [];
  }

  /// Saves the complete list of lessons to persistent storage
  Future<void> saveLessons(List<LessonItem> lessons) async {
    final jsonList = lessons.map((l) => l.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonString);

    try {
      final file = await _getFallbackFile();
      await file.writeAsString(jsonString);
    } catch (_) {}
  }

  Future<File> _getFallbackFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/lingodiff_lessons.json');
  }

  /// Generates clean Markdown documentation string
  static String exportToMarkdown(List<LessonItem> lessons) {
    if (lessons.isEmpty) return '# Spanish Translation Lessons Learned\n\nNo lessons recorded yet.\n';
    final buffer = StringBuffer('# Spanish Translation Lessons Learned\n\n');
    for (final l in lessons) {
      buffer.writeln('## ${l.topic} (${l.date})');
      buffer.writeln('- **English Trigger:** "${l.english}"');
      buffer.writeln('- **My Draft:** ~~${l.userSpanish}~~');
      buffer.writeln('- **Natural Spanish:** **${l.naturalSpanish}**');
      buffer.writeln('- **Takeaway:** ${l.rule}\n');
    }
    return buffer.toString();
  }

  /// Generates CSV compatible with Anki flashcard import
  static String exportToAnkiCSV(List<LessonItem> lessons) {
    final rows = <List<dynamic>>[
      ['English Source', 'Natural Spanish', 'Avoid / My Mistake', 'Grammar Rule', 'Topic']
    ];
    for (final l in lessons) {
      rows.add([l.english, l.naturalSpanish, l.userSpanish, l.rule, l.topic]);
    }
    return csv.encode(rows);
  }

  /// Prompts user with macOS save dialog to write export file
  static Future<String?> saveExportDialog({
    required String defaultFileName,
    required String fileContent,
    required String extension,
  }) async {
    final bytes = utf8.encode(fileContent);
    final outputUri = await FilePicker.saveFile(
      dialogTitle: 'Export Lessons',
      fileName: defaultFileName,
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: [extension],
    );

    if (outputUri != null) {
      return outputUri.toFilePath();
    }
    return null;
  }
}
