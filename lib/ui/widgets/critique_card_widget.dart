import 'package:flutter/material.dart';

import '../../models/critique_model.dart';
import '../theme/app_palette.dart';

class CritiqueCardWidget extends StatelessWidget {
  final int index;
  final CritiqueItem item;
  final bool isHighlighted;
  final VoidCallback onJumpToEnglish;
  final VoidCallback onSaveLesson;
  final bool isSaved;
  final ValueChanged<bool> onHover;

  const CritiqueCardWidget({
    super.key,
    required this.index,
    required this.item,
    required this.isHighlighted,
    required this.onJumpToEnglish,
    required this.onSaveLesson,
    required this.isSaved,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final (badgeBg, borderCol, textCol) = _getCategoryStyles(
      palette,
      item.category,
    );

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted ? palette.surfaceRaised : palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted ? palette.info : borderCol,
            width: isHighlighted ? 2.0 : 1.0,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: palette.info.withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : palette.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Badge, Topic Tag, Save Button
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderCol),
                  ),
                  child: Text(
                    '#${index + 1} · ${item.category.label}',
                    style: TextStyle(
                      color: textCol,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surfaceRaised,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: palette.borderStrong),
                  ),
                  child: Text(
                    item.grammarTopic,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onSaveLesson,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isSaved
                        ? palette.success
                        : palette.warningLabel,
                    side: BorderSide(
                      color: isSaved
                          ? palette.successSoftBorder
                          : palette.warningSoftBorder,
                    ),
                    backgroundColor: isSaved
                        ? palette.successSoft
                        : palette.warningSoft,
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  icon: Icon(
                    isSaved
                        ? Icons.check_circle_outline
                        : Icons.bookmark_add_outlined,
                    size: 14,
                  ),
                  label: Text(
                    isSaved ? 'Saved to Lessons' : 'Save Lesson',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3-Way Comparison Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 750;
                final tiles = [
                  // 1. English Pointer Box
                  InkWell(
                    onTap: onJumpToEnglish,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: palette.surfaceInset,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: palette.infoSoftBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  '🇬🇧 English Source Pointer',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: palette.info,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '↗ Jump',
                                style: TextStyle(
                                  color: palette.info,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"${item.englishSegment}"',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. User Spanish Box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: palette.surfaceInset,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: palette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✍️ Your Spanish',
                          style: TextStyle(
                            color: palette.error,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.userSpanish,
                          style: TextStyle(
                            color: palette.onErrorSoft,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Official / Ideal Spanish Box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: palette.surfaceInset,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: palette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📖 Official / Natural Spanish',
                          style: TextStyle(
                            color: palette.success,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.officialSpanish,
                          style: TextStyle(
                            color: palette.onSuccessSoft,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];

                if (isNarrow) {
                  return Column(
                    children: tiles
                        .map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: w,
                          ),
                        )
                        .toList(),
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: tiles[0]),
                    const SizedBox(width: 8),
                    Expanded(child: tiles[1]),
                    const SizedBox(width: 8),
                    Expanded(child: tiles[2]),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            // Why Explanation
            Text.rich(
              TextSpan(
                style: TextStyle(
                  color: palette.textBody,
                  fontSize: 13.5,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Why: ',
                    style: TextStyle(
                      color: palette.onPrimarySoft,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: item.explanation),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Distilled Takeaway
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: palette.warningSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.warningSoftBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      '💡 Takeaway: ',
                      style: TextStyle(
                        color: palette.warningLabel,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.lessonTakeaway,
                      style: TextStyle(
                        color: palette.onWarningSoft,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color bg, Color border, Color text) _getCategoryStyles(
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
