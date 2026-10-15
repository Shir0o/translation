import 'package:flutter_test/flutter_test.dart';
import 'package:translation/core/pointers/english_pointer_mapper.dart';

void main() {
  group('EnglishPointerMapper', () {
    const fullText =
        'I have been looking for a new apartment for three months, but I still have not found anything that fits my budget. Last Friday, I realized that if I moved a little further, I could save on rent.';

    test('locates segments correctly in text', () {
      final segments = [
        'I have been looking for a new apartment for three months',
        'fits my budget',
        'I realized that',
        'on rent'
      ];

      final pointers = EnglishPointerMapper.locatePointers(fullText, segments);
      expect(pointers.length, equals(4));

      // Pointer 0
      final p0 = pointers.firstWhere((p) => p.index == 0);
      expect(p0.start, equals(0));
      expect(p0.text, equals('I have been looking for a new apartment for three months'));

      // Check that substrings match exactly
      for (final p in pointers) {
        expect(fullText.substring(p.start, p.end), equals(p.text));
      }
    });

    test('prevents overlapping segment collisions', () {
      const text = 'Repeat word word word end';
      final pointers = EnglishPointerMapper.locatePointers(text, ['word', 'word']);
      expect(pointers.length, equals(2));
      expect(pointers[0].start != pointers[1].start, isTrue);
    });
  });
}
