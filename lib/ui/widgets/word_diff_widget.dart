import 'package:flutter/material.dart';

import '../../core/diff/word_diff.dart';
import '../theme/app_palette.dart';

class WordDiffWidget extends StatelessWidget {
  final List<DiffChunk> diffChunks;
  final bool hasOfficialText;

  const WordDiffWidget({
    super.key,
    required this.diffChunks,
    required this.hasOfficialText,
  });

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;

    if (!hasOfficialText) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.border),
        ),
        child: Text(
          'No official reference text provided. Paste an official translation in Panel 3 or run AI Tutor to generate a reference comparison.',
          style: TextStyle(
            color: palette.textMuted,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'VISUAL WORD DIFF (YOUR SPANISH VS. OFFICIAL REFERENCE)',
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: palette.diffRemovedBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Your phrasing removed',
                      style: TextStyle(
                        color: palette.diffRemovedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: palette.diffAddedBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Official phrasing added',
                      style: TextStyle(
                        color: palette.diffAddedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surfaceInset,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.border),
            ),
            child: SelectableText.rich(
              TextSpan(
                children: diffChunks.map((chunk) {
                  if (chunk.isAdded) {
                    return TextSpan(
                      text: chunk.text,
                      style: TextStyle(
                        color: palette.diffAddedText,
                        backgroundColor: palette.diffAddedBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1.8,
                      ),
                    );
                  } else if (chunk.isRemoved) {
                    return TextSpan(
                      text: chunk.text,
                      style: TextStyle(
                        color: palette.diffRemovedText,
                        backgroundColor: palette.diffRemovedBackground,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 15,
                        height: 1.8,
                      ),
                    );
                  } else {
                    return TextSpan(
                      text: chunk.text,
                      style: TextStyle(
                        color: palette.diffPlainText,
                        fontSize: 15,
                        height: 1.8,
                      ),
                    );
                  }
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
