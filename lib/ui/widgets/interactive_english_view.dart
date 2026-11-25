import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/pointers/english_pointer_mapper.dart';
import '../../models/critique_model.dart';
import '../theme/app_palette.dart';

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

    final AppPalette palette = context.palette;
    final segments = widget.critiques.map((c) => c.englishSegment).toList();
    final locatedPointers = EnglishPointerMapper.locatePointers(
      widget.englishText,
      segments,
    );

    if (locatedPointers.isEmpty) {
      return SelectableText(
        widget.englishText,
        style: TextStyle(color: palette.textBody, fontSize: 15, height: 1.6),
      );
    }

    final spans = <InlineSpan>[];
    var lastIndex = 0;

    for (final ptr in locatedPointers) {
      // Plain text before this pointer
      if (ptr.start > lastIndex) {
        spans.add(
          TextSpan(
            text: widget.englishText.substring(lastIndex, ptr.start),
            style: TextStyle(
              color: palette.textBody,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        );
      }

      final critique = widget.critiques[ptr.index];
      final isActive = widget.activeIndex == ptr.index;

      final tapRecognizer = TapGestureRecognizer()
        ..onTap = () => widget.onPointerSelected(ptr.index);
      _recognizers.add(tapRecognizer);

      final (badgeBg, _, textCol) = _getCategoryColors(
        palette,
        critique.category,
      );

      spans.add(
        TextSpan(
          text: ' [#${ptr.index + 1} ${ptr.text}] ',
          recognizer: tapRecognizer,
          style: TextStyle(
            color: isActive ? palette.pointerActiveText : textCol,
            backgroundColor: isActive
                ? palette.pointerActiveBackground
                : badgeBg,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            height: 1.8,
          ),
        ),
      );

      lastIndex = ptr.end;
    }

    // Remaining trailing text
    if (lastIndex < widget.englishText.length) {
      spans.add(
        TextSpan(
          text: widget.englishText.substring(lastIndex),
          style: TextStyle(color: palette.textBody, fontSize: 15, height: 1.6),
        ),
      );
    }

    return Text.rich(TextSpan(children: spans));
  }

  (Color bg, Color border, Color text) _getCategoryColors(
    AppPalette palette,
    CritiqueCategory category,
  ) {
    switch (category) {
      case CritiqueCategory.error:
        return (
          palette.errorSoft,
          palette.errorSoftBorder,
          palette.onErrorSoft,
        );
      case CritiqueCategory.validAlternative:
        return (
          palette.successSoft,
          palette.successSoftBorder,
          palette.onSuccessSoft,
        );
      case CritiqueCategory.unnatural:
        return (
          palette.warningSoft,
          palette.warningSoftBorder,
          palette.onWarningSoft,
        );
    }
  }
}
