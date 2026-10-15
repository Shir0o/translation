import 'package:flutter_test/flutter_test.dart';
import 'package:translation/core/diff/word_diff.dart';

void main() {
  group('WordDiff tokenization & diffing', () {
    test('tokenizes words, punctuation, and whitespace accurately', () {
      final tokens = WordDiff.tokenizeWordsWithSpace('Hello, world! 123');
      expect(tokens, equals(['Hello', ',', ' ', 'world', '!', ' ', '123']));
    });

    test('handles empty inputs', () {
      expect(WordDiff.diffWordsWithSpace('', ''), isEmpty);
      expect(
        WordDiff.diffWordsWithSpace('', 'Added text'),
        equals([const DiffChunk('Added text', DiffType.added)]),
      );
      expect(
        WordDiff.diffWordsWithSpace('Removed text', ''),
        equals([const DiffChunk('Removed text', DiffType.removed)]),
      );
    });

    test('correctly identifies word replacement, addition, and deletion', () {
      const userText = 'He estado buscando por un nuevo apartamento';
      const officialText = 'Llevo tres meses buscando un departamento nuevo';

      final diff = WordDiff.diffWordsWithSpace(userText, officialText);
      expect(diff.isNotEmpty, isTrue);

      // Verify that reconstructing unchanged + removed equals userText
      final reconstructedOld = diff
          .where((c) => c.isUnchanged || c.isRemoved)
          .map((c) => c.text)
          .join();
      expect(reconstructedOld, equals(userText));

      // Verify that reconstructing unchanged + added equals officialText
      final reconstructedNew = diff
          .where((c) => c.isUnchanged || c.isAdded)
          .map((c) => c.text)
          .join();
      expect(reconstructedNew, equals(officialText));
    });
  });
}
