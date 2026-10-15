import 'package:flutter/material.dart';
import '../../core/diff/word_diff.dart';

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
    if (!hasOfficialText) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: const Text(
          'No official reference text provided. Paste an official translation in Panel 3 or run AI Tutor to generate a reference comparison.',
          style: TextStyle(
            color: Color(0xFF64748B),
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
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
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
              const Text(
                'VISUAL WORD DIFF (YOUR SPANISH VS. OFFICIAL REFERENCE)',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x33F43F5E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Your phrasing removed',
                      style: TextStyle(
                        color: Color(0xFFFDA4AF),
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x3310B981),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Official phrasing added',
                      style: TextStyle(
                        color: Color(0xFF6EE7B7),
                        fontSize: 11,
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
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: SelectableText.rich(
              TextSpan(
                children: diffChunks.map((chunk) {
                  if (chunk.isAdded) {
                    return TextSpan(
                      text: chunk.text,
                      style: const TextStyle(
                        color: Color(0xFF6EE7B7),
                        backgroundColor: Color(0x4410B981),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1.8,
                      ),
                    );
                  } else if (chunk.isRemoved) {
                    return TextSpan(
                      text: chunk.text,
                      style: const TextStyle(
                        color: Color(0xFFFDA4AF),
                        backgroundColor: Color(0x44F43F5E),
                        decoration: TextDecoration.lineThrough,
                        fontSize: 15,
                        height: 1.8,
                      ),
                    );
                  } else {
                    return TextSpan(
                      text: chunk.text,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
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
