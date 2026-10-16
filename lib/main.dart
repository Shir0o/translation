import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/diff/word_diff.dart';
import 'models/ai_settings.dart';
import 'models/critique_model.dart';
import 'models/lesson_model.dart';
import 'services/ai_tutor_service.dart';
import 'services/lessons_repository.dart';
import 'ui/widgets/critique_card_widget.dart';
import 'ui/widgets/interactive_english_view.dart';
import 'ui/widgets/lessons_drawer.dart';
import 'ui/widgets/settings_dialog.dart';
import 'ui/widgets/word_diff_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LingoDiffApp()));
}

class LingoDiffApp extends StatelessWidget {
  const LingoDiffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LingoDiff Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0F1A),
        fontFamily: '.AppleSystemUIFont',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          surface: Color(0xFF0F172A),
        ),
      ),
      home: const WorkspaceScreen(),
    );
  }
}

class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  final _englishController = TextEditingController();
  final _userSpanishController = TextEditingController();
  final _officialSpanishController = TextEditingController();
  final _scrollController = ScrollController();

  final _aiService = AITutorService();
  final _lessonsRepo = LessonsRepository();

  bool _isThreeColumn = false;
  bool _isOfficialBlurred = false;
  bool _isEnglishInteractive = false;
  bool _isLoading = false;

  int? _hoveredPointerIndex;
  List<DiffChunk> _diffChunks = [];
  AITutorResponse? _aiResult;
  List<LessonItem> _savedLessons = [];
  AISettings _aiSettings = const AISettings();

  final Map<int, GlobalKey> _cardKeys = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final lessons = await _lessonsRepo.loadLessons();
    final prefs = await SharedPreferences.getInstance();

    final provider = AIProvider.fromString(prefs.getString('lingodiff_provider'));
    final key = prefs.getString('lingodiff_api_key') ?? '';
    final model = prefs.getString('lingodiff_model') ?? provider.defaultModel;

    if (mounted) {
      setState(() {
        _savedLessons = lessons;
        _aiSettings = AISettings(provider: provider, apiKey: key, model: model);
      });
    }
  }

  Future<void> _saveAiSettings(AISettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lingodiff_provider', settings.provider.name);
    await prefs.setString('lingodiff_api_key', settings.apiKey);
    await prefs.setString('lingodiff_model', settings.model);
    setState(() => _aiSettings = settings);
  }

  @override
  void dispose() {
    _englishController.dispose();
    _userSpanishController.dispose();
    _officialSpanishController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadSampleExercise() {
    const sampleEn =
        'I have been looking for a new apartment for three months, but I still haven\'t found anything that fits my budget. Last Friday, I realized that if I moved a little further from downtown, I could save a lot of money on rent.';
    const sampleUserEs =
        'He estado buscando por un nuevo apartamento por tres meses, pero todavía no he encontrado nada que cabe mi presupuesto. El viernes pasado, me realicé que si me mudaba un poco más lejos del centro, podría ahorrar mucho dinero en la renta.';
    const sampleOfficialEs =
        'Llevo tres meses buscando un departamento nuevo, pero todavía no he encontrado nada que se ajuste a mi presupuesto. El viernes pasado me di cuenta de que, si me mudara un poco más lejos del centro, podría ahorrar mucho dinero en el alquiler.';

    _englishController.text = sampleEn;
    _userSpanishController.text = sampleUserEs;
    _officialSpanishController.text = sampleOfficialEs;

    final demoCritiques = AITutorService.getDemoResponse();

    setState(() {
      _isEnglishInteractive = true;
      _diffChunks = WordDiff.diffWordsWithSpace(sampleUserEs, sampleOfficialEs);
      _aiResult = demoCritiques;
      _cardKeys.clear();
      for (var i = 0; i < demoCritiques.critiques.length; i++) {
        _cardKeys[i] = GlobalKey();
      }
    });
  }

  void _clearWorkspace() {
    setState(() {
      _englishController.clear();
      _userSpanishController.clear();
      _officialSpanishController.clear();
      _isEnglishInteractive = false;
      _diffChunks = [];
      _aiResult = null;
      _cardKeys.clear();
      _hoveredPointerIndex = null;
    });
  }

  void _runWordDiffOnly() {
    final userEs = _userSpanishController.text.trim();
    final officialEs = _officialSpanishController.text.trim();

    if (userEs.isEmpty) {
      _showToast('Please type your Spanish translation draft first.');
      return;
    }

    setState(() {
      _diffChunks = WordDiff.diffWordsWithSpace(userEs, officialEs);
    });
  }

  Future<void> _runAIAnalysis() async {
    final enText = _englishController.text.trim();
    final userEs = _userSpanishController.text.trim();
    final officialEs = _officialSpanishController.text.trim();

    if (enText.isEmpty || userEs.isEmpty) {
      _showToast('Please enter both English source text and your Spanish translation.');
      return;
    }

    if (_aiSettings.apiKey.isEmpty) {
      _openSettingsDialog();
      _showToast('Please set your API key in Settings (or use Load Demo Exercise).');
      return;
    }

    setState(() {
      _isLoading = true;
      _diffChunks = WordDiff.diffWordsWithSpace(userEs, officialEs);
    });

    try {
      final res = await _aiService.analyzeTranslation(
        englishText: enText,
        userSpanish: userEs,
        officialSpanish: officialEs,
        settings: _aiSettings,
      );

      if (mounted) {
        if (officialEs.isEmpty && res.generatedOfficialSpanish != null) {
          _officialSpanishController.text = res.generatedOfficialSpanish!;
          _diffChunks = WordDiff.diffWordsWithSpace(userEs, res.generatedOfficialSpanish!);
        }

        setState(() {
          _aiResult = res;
          _isEnglishInteractive = true;
          _cardKeys.clear();
          for (var i = 0; i < res.critiques.length; i++) {
            _cardKeys[i] = GlobalKey();
          }
        });
      }
    } catch (e) {
      if (mounted) _showToast('AI Tutor Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToCard(int index) {
    setState(() => _hoveredPointerIndex = index);
    final key = _cardKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  void _saveLessonFromCard(int index) async {
    final critique = _aiResult?.critiques[index];
    if (critique == null) return;

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final lesson = LessonItem(
      id: now.millisecondsSinceEpoch,
      date: dateStr,
      topic: critique.grammarTopic,
      english: critique.englishSegment,
      userSpanish: critique.userSpanish,
      naturalSpanish: critique.officialSpanish,
      rule: critique.lessonTakeaway.isNotEmpty
          ? critique.lessonTakeaway
          : critique.explanation,
    );

    final updated = [lesson, ..._savedLessons];
    setState(() => _savedLessons = updated);
    await _lessonsRepo.saveLessons(updated);
    _showToast('Lesson saved to Notebook!');
  }

  void _deleteLesson(int id) async {
    final updated = _savedLessons.where((l) => l.id != id).toList();
    setState(() => _savedLessons = updated);
    await _lessonsRepo.saveLessons(updated);
  }

  void _addManualLesson(LessonItem lesson) async {
    final updated = [lesson, ..._savedLessons];
    setState(() => _savedLessons = updated);
    await _lessonsRepo.saveLessons(updated);
    _showToast('Lesson added to Notebook!');
  }

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => SettingsDialog(
        initialSettings: _aiSettings,
        onSave: _saveAiSettings,
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _runAIAnalysis,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          key: scaffoldKey,
          endDrawer: LessonsDrawer(
            lessons: _savedLessons,
            onAddManualLesson: _addManualLesson,
            onDeleteLesson: _deleteLesson,
          ),
          appBar: _buildTopBar(scaffoldKey),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Input Workspace Panes
                    _buildWorkspacePanes(),
                    const SizedBox(height: 16),

                    // Actions Bar
                    _buildActionBar(),
                    const SizedBox(height: 24),

                    // Loading State
                    if (_isLoading) _buildLoadingCard(),

                    // Results: Word Diff + AI Critique Cards
                    if (_diffChunks.isNotEmpty || _aiResult != null) ...[
                      if (_diffChunks.isNotEmpty) ...[
                        WordDiffWidget(
                          diffChunks: _diffChunks,
                          hasOfficialText:
                              _officialSpanishController.text.trim().isNotEmpty,
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (_aiResult != null) _buildAiResultsSection(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar(GlobalKey<ScaffoldState> scaffoldKey) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('⇄', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LingoDiff Studio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'EN → ES Side-by-Side Translation & AI Tutor (macOS)',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              OutlinedButton(
                onPressed: _loadSampleExercise,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE2E8F0),
                  side: const BorderSide(color: Color(0xFF334155)),
                  backgroundColor: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('✨ Load Demo Exercise', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => setState(() => _isThreeColumn = !_isThreeColumn),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE2E8F0),
                  side: const BorderSide(color: Color(0xFF334155)),
                  backgroundColor: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  _isThreeColumn ? '📐 3-Column View: On' : '📐 3-Column View: Off',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFCD34D),
                  side: const BorderSide(color: Color(0x66F59E0B)),
                  backgroundColor: const Color(0x22F59E0B),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📓 Lessons Learned',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_savedLessons.length}',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _openSettingsDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE2E8F0),
                  side: const BorderSide(color: Color(0xFF334155)),
                  backgroundColor: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.settings, size: 14),
                label: Text(
                  _aiSettings.apiKey.isNotEmpty
                      ? 'API Ready (${_aiSettings.provider.name})'
                      : 'Set API Key',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspacePanes() {
    final panel1 = _buildPanelCard(
      title: '1. ORIGINAL ENGLISH',
      titleColor: const Color(0xFF38BDF8),
      trailing: _isEnglishInteractive
          ? Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0x3338BDF8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x6638BDF8)),
                  ),
                  child: const Text(
                    '🎯 Interactive Pointer Mode',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _isEnglishInteractive = false),
                  child: const Text(
                    'Edit Source',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            )
          : null,
      child: _isEnglishInteractive && _aiResult != null
          ? InteractiveEnglishView(
              englishText: _englishController.text,
              critiques: _aiResult!.critiques,
              activeIndex: _hoveredPointerIndex,
              onPointerHover: (idx) => setState(() => _hoveredPointerIndex = idx),
              onPointerSelected: _scrollToCard,
            )
          : TextField(
              controller: _englishController,
              maxLines: null,
              style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 14, height: 1.6),
              decoration: const InputDecoration(
                hintText: 'Paste the original English paragraph here...',
                hintStyle: TextStyle(color: Color(0xFF64748B)),
                border: InputBorder.none,
              ),
            ),
    );

    final panel2 = _buildPanelCard(
      title: '2. YOUR SPANISH TRANSLATION',
      titleColor: const Color(0xFF34D399),
      trailing: const Text(
        'Type manually',
        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
      ),
      child: TextField(
        controller: _userSpanishController,
        maxLines: null,
        style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 14, height: 1.6),
        decoration: const InputDecoration(
          hintText: 'Escribe tu traducción al español aquí...',
          hintStyle: TextStyle(color: Color(0xFF64748B)),
          border: InputBorder.none,
        ),
      ),
    );

    final panel3 = _buildPanelCard(
      title: '3. OFFICIAL / REFERENCE SPANISH TRANSLATION',
      titleColor: const Color(0xFFA78BFA),
      trailing: InkWell(
        onTap: () => setState(() => _isOfficialBlurred = !_isOfficialBlurred),
        child: Text(
          _isOfficialBlurred ? '🙈 Blur while typing: On' : '👁️ Blur while typing: Off',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
        ),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _officialSpanishController,
            maxLines: null,
            style: TextStyle(
              color: const Color(0xFFF1F5F9),
              fontSize: 14,
              height: 1.6,
              background: _isOfficialBlurred
                  ? (Paint()..color = const Color(0xFF475569))
                  : null,
            ),
            decoration: const InputDecoration(
              hintText:
                  'Paste official Spanish translation here (or leave blank to let the AI generate one)...',
              hintStyle: TextStyle(color: Color(0xFF64748B)),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );

    if (_isThreeColumn) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: panel1),
          const SizedBox(width: 12),
          Expanded(child: panel2),
          const SizedBox(width: 12),
          Expanded(child: panel3),
        ],
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: panel1),
            const SizedBox(width: 12),
            Expanded(child: panel2),
          ],
        ),
        const SizedBox(height: 12),
        panel3,
      ],
    );
  }

  Widget _buildPanelCard({
    required String title,
    required Color titleColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF151F32),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _isLoading ? null : _runAIAnalysis,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.school_outlined, size: 16),
                label: const Text(
                  '🎓 Run AI Tutor & Pointer Diff  (⌘+Enter)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _runWordDiffOnly,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE2E8F0),
                  side: const BorderSide(color: Color(0xFF334155)),
                  backgroundColor: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.search, size: 16),
                label: const Text(
                  '🔍 Quick Word Diff Only (Offline)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: _clearWorkspace,
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF94A3B8)),
                child: const Text('Clear All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildLegendDot(const Color(0xFFF43F5E), 'Grammar Error'),
              _buildLegendDot(const Color(0xFFF59E0B), 'Unnatural / Literal'),
              _buildLegendDot(const Color(0xFF10B981), 'Valid Alternative'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF6366F1)),
          SizedBox(height: 14),
          Text(
            'Analyzing your translation against the English source and official reference...',
            style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4),
          Text(
            'Mapping unnatural phrasings and grammar pointers back to English',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildAiResultsSection() {
    final ai = _aiResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  '🎯 AI Teaching Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x334F46E5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x664F46E5)),
                  ),
                  child: Text(
                    ai.overallScore,
                    style: const TextStyle(
                      color: Color(0xFFA5B4FC),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x330284C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x660284C7)),
              ),
              child: const Text(
                '💡 Hover or click any card below to highlight the exact English phrase in Panel 1.',
                style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11),
              ),
            ),
          ],
        ),
        if (ai.summary.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(ai.summary, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        ],
        const SizedBox(height: 16),
        ...ai.critiques.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final isSaved = _savedLessons.any((l) =>
              l.english == item.englishSegment &&
              l.naturalSpanish == item.officialSpanish);

          return Padding(
            key: _cardKeys[idx],
            padding: const EdgeInsets.only(bottom: 12),
            child: CritiqueCardWidget(
              index: idx,
              item: item,
              isHighlighted: _hoveredPointerIndex == idx,
              isSaved: isSaved,
              onHover: (hovered) {
                setState(() => _hoveredPointerIndex = hovered ? idx : null);
              },
              onJumpToEnglish: () {
                setState(() => _hoveredPointerIndex = idx);
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              onSaveLesson: () => _saveLessonFromCard(idx),
            ),
          );
        }),
      ],
    );
  }
}
