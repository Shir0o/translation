import 'package:flutter/material.dart';
import '../../models/critique_model.dart';

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
    final (badgeBg, borderCol, textCol) = _getCategoryStyles(item.category);

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted ? const Color(0xFF38BDF8) : borderCol,
            width: isHighlighted ? 2.0 : 1.0,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderCol.withValues(alpha: 0.5)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Text(
                    item.grammarTopic,
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onSaveLesson,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isSaved ? const Color(0xFF6EE7B7) : const Color(0xFFFCD34D),
                    side: BorderSide(
                      color: isSaved
                          ? const Color(0x6610B981)
                          : const Color(0x66F59E0B),
                    ),
                    backgroundColor: isSaved
                        ? const Color(0x2210B981)
                        : const Color(0x22F59E0B),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: Icon(
                    isSaved ? Icons.check_circle_outline : Icons.bookmark_add_outlined,
                    size: 14,
                  ),
                  label: Text(
                    isSaved ? 'Saved to Lessons' : 'Save Lesson',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3-Way Comparison Grid
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 750;
              final tiles = [
                // 1. English Pointer Box
                InkWell(
                  onTap: onJumpToEnglish,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x4D38BDF8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '🇬🇧 English Source Pointer',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '↗ Jump',
                              style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"${item.englishSegment}"',
                          style: const TextStyle(
                            color: Color(0xFFF8FAFC),
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
                    color: const Color(0xFF020617),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✍️ Your Spanish',
                        style: TextStyle(
                          color: Color(0xFFFB7185),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.userSpanish,
                        style: const TextStyle(
                          color: Color(0xFFFECDD3),
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
                    color: const Color(0xFF020617),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📖 Official / Natural Spanish',
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.officialSpanish,
                        style: const TextStyle(
                          color: Color(0xFFA7F3D0),
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
                      .map((w) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: w,
                          ))
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
            }),
            const SizedBox(height: 12),

            // Why Explanation
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 13.5,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'Why: ',
                    style: TextStyle(
                      color: Color(0xFFA5B4FC),
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
                color: const Color(0x22F59E0B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x4DF59E0B)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Takeaway: ',
                    style: TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.lessonTakeaway,
                      style: const TextStyle(
                        color: Color(0xFFFDE68A),
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

  (Color bg, Color border, Color text) _getCategoryStyles(CritiqueCategory category) {
    switch (category) {
      case CritiqueCategory.error:
        return (
          const Color(0x33F43F5E),
          const Color(0x66F43F5E),
          const Color(0xFFFDA4AF),
        );
      case CritiqueCategory.validAlternative:
        return (
          const Color(0x3310B981),
          const Color(0x6610B981),
          const Color(0xFF6EE7B7),
        );
      case CritiqueCategory.unnatural:
        return (
          const Color(0x33F59E0B),
          const Color(0x66F59E0B),
          const Color(0xFFFDE68A),
        );
    }
  }
}
