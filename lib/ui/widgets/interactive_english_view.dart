import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/pointers/english_pointer_mapper.dart';
import '../../models/critique_model.dart';

class InteractiveEnglishView extends StatefulWidget {
  final String englishText;
  final List<CritiqueItem> critiques;
  final int? activeIndex;
  final ValueChanged<int?> onPointerHover;
  final ValueChanged<int> onPointerSelected;

  const InteractiveEnglishView({
    super.key,
    required this.englishText,
    required this.critiques,
    required this.activeIndex,
    required this.onPointerHover,
    required this.onPointerSelected,
  });

  @override
  State<InteractiveEnglishView> createState() => _InteractiveEnglishViewState();
}

class _InteractiveEnglishViewState extends State<InteractiveEnglishView> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final segments = widget.critiques.map((c) => c.englishSegment).toList();
    final locatedPointers = EnglishPointerMapper.locatePointers(
      widget.englishText,
      segments,
    );

    if (locatedPointers.isEmpty) {
      return SelectableText(
        widget.englishText,
        style: const TextStyle(
          color: Color(0xFFF1F5F9),
          fontSize: 15,
          height: 1.6,
        ),
      );
    }

    final spans = <InlineSpan>[];
    var lastIndex = 0;

    for (final ptr in locatedPointers) {
      // Plain text before this pointer
      if (ptr.start > lastIndex) {
        spans.add(TextSpan(
          text: widget.englishText.substring(lastIndex, ptr.start),
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 15,
            height: 1.6,
          ),
        ));
      }

      final critique = widget.critiques[ptr.index];
      final isActive = widget.activeIndex == ptr.index;

      final tapRecognizer = TapGestureRecognizer()
        ..onTap = () => widget.onPointerSelected(ptr.index);
      _recognizers.add(tapRecognizer);

      final (badgeBg, borderCol, textCol) = _getCategoryColors(critique.category, isActive);

      spans.add(TextSpan(
        text: ' [#${ptr.index + 1} ${ptr.text}] ',
        recognizer: tapRecognizer,
        style: TextStyle(
          color: isActive ? const Color(0xFF38BDF8) : textCol,
          backgroundColor: isActive ? const Color(0x6638BDF8) : badgeBg,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          height: 1.8,
        ),
      ));

      lastIndex = ptr.end;
    }

    // Remaining trailing text
    if (lastIndex < widget.englishText.length) {
      spans.add(TextSpan(
        text: widget.englishText.substring(lastIndex),
        style: const TextStyle(
          color: Color(0xFFCBD5E1),
          fontSize: 15,
          height: 1.6,
        ),
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }

  (Color bg, Color border, Color text) _getCategoryColors(
    CritiqueCategory category,
    bool isActive,
  ) {
    switch (category) {
      case CritiqueCategory.error:
        return (
          const Color(0x3DF43F5E),
          const Color(0x66F43F5E),
          const Color(0xFFFDA4AF),
        );
      case CritiqueCategory.validAlternative:
        return (
          const Color(0x3D10B981),
          const Color(0x6610B981),
          const Color(0xFF6EE7B7),
        );
      case CritiqueCategory.unnatural:
        return (
          const Color(0x3DF59E0B),
          const Color(0x66F59E0B),
          const Color(0xFFFDE68A),
        );
    }
  }
}
