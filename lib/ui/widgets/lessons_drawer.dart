import 'package:flutter/material.dart';

import '../../models/lesson_model.dart';
import '../../services/lessons_repository.dart';
import '../theme/app_palette.dart';

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Exported to $path')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Exported Anki deck to $path')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Drawer(
      backgroundColor: palette.surface,
      width: MediaQuery.sizeOf(context).width < 540
          ? MediaQuery.sizeOf(context).width * 0.9
          : 500,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            // The manual-add form and the lesson cards share one scroll view
            // so a 320x568 window at 1.6x text scale cannot overflow.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  _buildManualAddSection(),
                  if (widget.lessons.isEmpty)
                    _buildEmptyState()
                  else
                    ...widget.lessons.map(
                      (item) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _buildLessonCard(item),
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

  Widget _buildHeader() {
    final AppPalette palette = context.palette;
    final Widget title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📓 Lessons Learned Notebook',
          style: TextStyle(
            color: palette.warningHeading,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Saved patterns, idioms, and grammar takeaways',
          style: TextStyle(color: palette.textMuted, fontSize: 11),
        ),
      ],
    );

    final Widget actions = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        OutlinedButton(
          onPressed: _exportMarkdown,
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.textBody,
            side: BorderSide(color: palette.borderStrong),
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: const Text('⬇ .MD', style: TextStyle(fontSize: 11)),
        ),
        OutlinedButton(
          onPressed: _exportAnkiCSV,
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.textBody,
            side: BorderSide(color: palette.borderStrong),
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: const Text('⬇ Anki', style: TextStyle(fontSize: 11)),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Narrow phones (and large text scales) stack the export actions
          // under the title instead of squeezing them into one row.
          if (constraints.maxWidth < 400) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 12), actions],
            );
          }
          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 8),
              actions,
            ],
          );
        },
      ),
    );
  }

  Widget _buildManualAddSection() {
    final AppPalette palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surfaceHeader,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isAddExpanded = !_isAddExpanded),
            child: ConstrainedBox(
              // Keeps the disclosure row at the 48dp minimum tap target with
              // the narrower real Roboto metrics.
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '+ Add Manual Lesson / Rule',
                        style: TextStyle(
                          color: palette.warningLabel,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _isAddExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: palette.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isAddExpanded) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMiniInput(
                    _enController,
                    'English trigger phrase...',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMiniInput(
                    _topicController,
                    'Category (e.g., Subjunctive)',
                  ),
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
                    textColor: palette.onErrorSoft,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMiniInput(
                    _rightController,
                    'Natural Spanish phrasing...',
                    textColor: palette.onSuccessSoft,
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
                  backgroundColor: palette.warning,
                  foregroundColor: palette.onWarning,
                  minimumSize: const Size(48, 48),
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
    );
  }

  Widget _buildEmptyState() {
    final AppPalette palette = context.palette;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'No lessons saved yet.\nClick "Save Lesson" on any AI critique card to build your personal Spanish study notebook.',
        textAlign: TextAlign.center,
        style: TextStyle(color: palette.textMuted, fontSize: 13, height: 1.5),
      ),
    );
  }

  Widget _buildLessonCard(LessonItem item) {
    final AppPalette palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceInset,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: palette.warningSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.warningSoftBorder),
                  ),
                  child: Text(
                    item.topic,
                    style: TextStyle(
                      color: palette.warningLabel,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.date,
                    style: TextStyle(color: palette.textMuted, fontSize: 11),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: InkWell(
                      onTap: () => widget.onDeleteLesson(item.id),
                      child: Center(
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: palette.textMuted,
                        ),
                      ),
                    ),
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
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: palette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🇬🇧 English:',
                          style: TextStyle(color: palette.info, fontSize: 10),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.english,
                          style: TextStyle(
                            color: palette.textBody,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (item.english.isNotEmpty &&
                  (item.userSpanish.isNotEmpty ||
                      item.naturalSpanish.isNotEmpty))
                const SizedBox(width: 6),
              if (item.userSpanish.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: palette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '❌ Avoid:',
                          style: TextStyle(color: palette.error, fontSize: 10),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.userSpanish,
                          style: TextStyle(
                            color: palette.onErrorSoft,
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
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: palette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✅ Natural:',
                          style: TextStyle(
                            color: palette.success,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.naturalSpanish,
                          style: TextStyle(
                            color: palette.onSuccessSoft,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (item.rule.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: TextStyle(color: palette.textBody, fontSize: 12),
                children: [
                  TextSpan(
                    text: 'Rule: ',
                    style: TextStyle(
                      color: palette.warningLabel,
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
    final AppPalette palette = context.palette;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textColor ?? palette.textPrimary, fontSize: 12),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: palette.textMuted, fontSize: 11),
        filled: true,
        fillColor: palette.surfaceInset,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: palette.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: palette.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
      ),
    );
  }
}
