enum DiffType { added, removed, unchanged }

class DiffChunk {
  final String text;
  final DiffType type;

  const DiffChunk(this.text, this.type);

  bool get isAdded => type == DiffType.added;
  bool get isRemoved => type == DiffType.removed;
  bool get isUnchanged => type == DiffType.unchanged;

  @override
  String toString() => 'DiffChunk($type, "$text")';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiffChunk &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          type == other.type;

  @override
  int get hashCode => Object.hash(text, type);
}

class WordDiff {
  /// Splits text into tokens preserving words, whitespace, and punctuation.
  /// Matches jsdiff's word tokenization behavior.
  static List<String> tokenizeWordsWithSpace(String text) {
    if (text.isEmpty) return [];
    final regExp = RegExp(r'(\s+|[^\s\w]+|\w+)');
    final matches = regExp.allMatches(text);
    return matches.map((m) => m.group(0)!).toList();
  }

  /// Computes a word-by-word diff between [oldText] and [newText].
  /// [oldText] is typically the user's Spanish draft.
  /// [newText] is the official reference translation.
  /// Removed tokens are in oldText but not newText.
  /// Added tokens are in newText but not oldText.
  static List<DiffChunk> diffWordsWithSpace(String oldText, String newText) {
    if (oldText.isEmpty && newText.isEmpty) return [];
    if (oldText.isEmpty) {
      return [DiffChunk(newText, DiffType.added)];
    }
    if (newText.isEmpty) {
      return [DiffChunk(oldText, DiffType.removed)];
    }

    final oldTokens = tokenizeWordsWithSpace(oldText);
    final newTokens = tokenizeWordsWithSpace(newText);

    final n = oldTokens.length;
    final m = newTokens.length;

    // LCS dynamic programming table
    final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));

    for (var i = 0; i < n; i++) {
      for (var j = 0; j < m; j++) {
        if (oldTokens[i] == newTokens[j]) {
          dp[i + 1][j + 1] = dp[i][j] + 1;
        } else {
          final top = dp[i][j + 1];
          final left = dp[i + 1][j];
          dp[i + 1][j + 1] = top >= left ? top : left;
        }
      }
    }

    // Backtrack to find diff
    var i = n;
    var j = m;
    final rawChunks = <DiffChunk>[];

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && oldTokens[i - 1] == newTokens[j - 1]) {
        rawChunks.add(DiffChunk(oldTokens[i - 1], DiffType.unchanged));
        i--;
        j--;
      } else if (j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j])) {
        rawChunks.add(DiffChunk(newTokens[j - 1], DiffType.added));
        j--;
      } else if (i > 0 && (j == 0 || dp[i][j - 1] < dp[i - 1][j])) {
        rawChunks.add(DiffChunk(oldTokens[i - 1], DiffType.removed));
        i--;
      }
    }

    final reversed = rawChunks.reversed.toList();
    return _coalesceAdjacent(reversed);
  }

  /// Merges consecutive tokens of the same DiffType into single strings
  static List<DiffChunk> _coalesceAdjacent(List<DiffChunk> chunks) {
    if (chunks.isEmpty) return [];
    final result = <DiffChunk>[];
    var currentType = chunks.first.type;
    var buffer = StringBuffer(chunks.first.text);

    for (var k = 1; k < chunks.length; k++) {
      final chunk = chunks[k];
      if (chunk.type == currentType) {
        buffer.write(chunk.text);
      } else {
        result.add(DiffChunk(buffer.toString(), currentType));
        currentType = chunk.type;
        buffer = StringBuffer(chunk.text);
      }
    }
    result.add(DiffChunk(buffer.toString(), currentType));
    return result;
  }
}
