import 'package:flutter/material.dart';
import '../../models/lesson_model.dart';
import '../../services/lessons_repository.dart';

class LessonsDrawer extends StatefulWidget {
  final List<LessonItem> lessons;
  final ValueChanged<LessonItem> onAddManualLesson;
  final ValueChanged<int> onDeleteLesson;

  const LessonsDrawer({
    super.key,
    required this.lessons,
    required this.onAddManualLesson,
    required this.onDeleteLesson,
  });

  @override
  State<LessonsDrawer> createState() => _LessonsDrawerState();
}

class _LessonsDrawerState extends State<LessonsDrawer> {
  bool _isAddExpanded = false;
  final _enController = TextEditingController();
  final _topicController = TextEditingController();
  final _wrongController = TextEditingController();
  final _rightController = TextEditingController();
  final _ruleController = TextEditingController();

  @override
  void dispose() {
    _enController.dispose();
    _topicController.dispose();
    _wrongController.dispose();
    _rightController.dispose();
    _ruleController.dispose();
    super.dispose();
  }

  void _submitManualLesson() {
    final en = _enController.text.trim();
    final rule = _ruleController.text.trim();
    if (en.isEmpty && rule.isEmpty) return;

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final lesson = LessonItem(
      id: now.millisecondsSinceEpoch,
      date: dateStr,
      topic: _topicController.text.trim().isEmpty
          ? 'Custom Note'
          : _topicController.text.trim(),
      english: en,
      userSpanish: _wrongController.text.trim(),
      naturalSpanish: _rightController.text.trim(),
      rule: rule,
    );

    widget.onAddManualLesson(lesson);

    _enController.clear();
    _topicController.clear();
    _wrongController.clear();
    _rightController.clear();
    _ruleController.clear();
    setState(() => _isAddExpanded = false);
  }

  Future<void> _exportMarkdown() async {
    if (widget.lessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No lessons to export yet.')),
      );
      return;
    }
    final content = LessonsRepository.exportToMarkdown(widget.lessons);
    final path = await LessonsRepository.saveExportDialog(
      defaultFileName: 'spanish-lessons-learned.md',
      fileContent: content,
      extension: 'md',
    );
    if (mounted && path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to $path')),
      );
    }
  }

  Future<void> _exportAnkiCSV() async {
    if (widget.lessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No lessons to export yet.')),
      );
      return;
    }
    final content = LessonsRepository.exportToAnkiCSV(widget.lessons);
    final path = await LessonsRepository.saveExportDialog(
      defaultFileName: 'spanish-lessons-anki.csv',
      fileContent: content,
      extension: 'csv',
    );
    if (mounted && path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported Anki deck to $path')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      width: 500,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📓 Lessons Learned Notebook',
                        style: TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Saved patterns, idioms, and grammar takeaways',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: _exportMarkdown,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE2E8F0),
                      side: const BorderSide(color: Color(0xFF334155)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('⬇ .MD', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    onPressed: _exportAnkiCSV,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE2E8F0),
                      side: const BorderSide(color: Color(0xFF334155)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('⬇ Anki', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),

            // Manual Add Collapsible Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF151F32),
                border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => _isAddExpanded = !_isAddExpanded),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '+ Add Manual Lesson / Rule',
                          style: TextStyle(
                            color: Color(0xFFFCD34D),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          _isAddExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF64748B),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  if (_isAddExpanded) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniInput(_enController, 'English trigger phrase...'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMiniInput(
                              _topicController, 'Category (e.g., Subjunctive)'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniInput(
                            _wrongController,
                            'Avoid / literal mistake...',
                            textColor: const Color(0xFFFDA4AF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMiniInput(
                            _rightController,
                            'Natural Spanish phrasing...',
                            textColor: const Color(0xFF6EE7B7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildMiniInput(
                      _ruleController,
                      'Core takeaway / grammar rule...',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitManualLesson,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Save to Notebook',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Lessons List
            Expanded(
              child: widget.lessons.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No lessons saved yet.\nClick "Save Lesson" on any AI critique card to build your personal Spanish study notebook.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.lessons.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final item = widget.lessons[idx];
                        return _buildLessonCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(LessonItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x22F59E0B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x4DF59E0B)),
                ),
                child: Text(
                  item.topic,
                  style: const TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    item.date,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => widget.onDeleteLesson(item.id),
                    child: const Icon(Icons.delete_outline,
                        size: 16, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.english.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🇬🇧 English:',
                            style: TextStyle(color: Color(0xFF38BDF8), fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(item.english,
                            style: const TextStyle(
                                color: Color(0xFFE2E8F0), fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              if (item.english.isNotEmpty &&
                  (item.userSpanish.isNotEmpty || item.naturalSpanish.isNotEmpty))
                const SizedBox(width: 6),
              if (item.userSpanish.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('❌ Avoid:',
                            style: TextStyle(color: Color(0xFFFB7185), fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(
                          item.userSpanish,
                          style: const TextStyle(
                            color: Color(0xFFFECDD3),
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (item.naturalSpanish.isNotEmpty) ...[
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✅ Natural:',
                            style: TextStyle(color: Color(0xFF34D399), fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(item.naturalSpanish,
                            style: const TextStyle(
                                color: Color(0xFFA7F3D0), fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (item.rule.isNotEmpty) ...[
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                children: [
                  const TextSpan(
                    text: 'Rule: ',
                    style: TextStyle(
                      color: Color(0xFFFCD34D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: item.rule),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniInput(
    TextEditingController controller,
    String hint, {
    Color? textColor,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textColor ?? const Color(0xFFF1F5F9), fontSize: 12),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
    );
  }
}
