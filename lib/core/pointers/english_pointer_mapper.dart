class PointerSegment {
  final int index;
  final int start;
  final int end;
  final String text;

  const PointerSegment({
    required this.index,
    required this.start,
    required this.end,
    required this.text,
  });
}

class EnglishPointerMapper {
  /// Locates occurrences of critique segments in the English source text,
  /// avoiding overlaps so each character maps cleanly to at most one pointer.
  static List<PointerSegment> locatePointers(
    String fullEnglish,
    List<String> segments,
  ) {
    if (fullEnglish.isEmpty || segments.isEmpty) return [];

    final located = <PointerSegment>[];
    final occupied = List<bool>.filled(fullEnglish.length, false);

    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i].trim();
      if (seg.isEmpty) continue;

      var searchStart = 0;
      while (searchStart < fullEnglish.length) {
        final matchIdx = fullEnglish.indexOf(seg, searchStart);
        if (matchIdx == -1) break;

        final endIdx = matchIdx + seg.length;
        // Check if any character in this range is already occupied
        final isFree = !occupied.sublist(matchIdx, endIdx).contains(true);
        if (isFree) {
          for (var k = matchIdx; k < endIdx; k++) {
            occupied[k] = true;
          }
          located.add(PointerSegment(
            index: i,
            start: matchIdx,
            end: endIdx,
            text: seg,
          ));
          break; // move to next segment
        } else {
          searchStart = matchIdx + 1;
        }
      }
    }

    // Sort by start index
    located.sort((a, b) => a.start.compareTo(b.start));
    return located;
  }
}
