// AFK UI/UX audit harness for LingoDiff Studio.
//
// What this suite covers
// ----------------------
// * Responsive matrices: phone light/dark (390x844), a 320x568 phone at 1.6x
//   text scale, a narrow 800x600 desktop window, and a 1440x900 macOS
//   desktop window.
// * A real click-through with `tester.tap`: demo exercise -> interactive
//   pointer view -> edit-source toggle -> save lesson -> notebook drawer ->
//   manual add form -> delete; settings dialog (provider + API key); the
//   "Run AI Tutor without an API key" gate; quick offline word diff; clear
//   workspace; notebook export with an empty notebook.
// * Zero uncaught widget exceptions / RenderFlex overflows at every step.
// * Accessibility: labelled tappable controls, Android 48x48dp tap targets,
//   and WCAG AA (4.5:1 normal text / 3:1 large text) text contrast.
// * Layout goldens, written ONLY under `--update-goldens` (see below).
//
// Running
// -------
//   flutter test test/ui_ux_audit_test.dart                    # verify
//   flutter test --update-goldens test/ui_ux_audit_test.dart   # write goldens
//
// Goldens
// -------
// Baseline files live in `test/goldens/`. They are written only when Flutter
// sets `autoUpdateGoldenFiles` (i.e. only with `--update-goldens`). On a
// normal run, a missing baseline prints a skip notice instead of creating a
// file, so a fresh checkout still reports the behavioural audit.
//
// Font-rendering constraints
// --------------------------
// `flutter test` only ships the Ahem test font, and the app asks for the local
// ".AppleSystemUIFont" family, which is not registered in the test font
// manager. Text therefore renders as solid Ahem blocks in the goldens. That is
// intentional: goldens assert layout geometry, wrapping, density and colour,
// not glyph shapes. Ahem is also wider than the real system font, which makes
// these tests a useful worst case for overflow.
//
// macOS desktop notes
// -------------------
// * The app targets macOS. The desktop matrices use a 1440x900 logical window
//   (typical 13-15" MacBook) and an 800x600 resized window.
// * The workspace panes are side-by-side/three-column at >= 700 logical px and
//   stack below that; the 320x568 and 390x844 matrices exercise the stacked
//   layout.
// * The header is pinned above the workspace and wraps its actions, so no
//   action may sit outside the viewport at any matrix size. `_auditState`
//   asserts every header action is fully visible, unclipped and >= 48x48dp
//   without scrolling the header; `_tapHeaderAction` taps it directly.
// * The notebook drawer is capped at 500 logical px wide (90% on phones), and
//   the settings dialog is max 460 px wide and scrolls when height-limited.
// * File export uses a native macOS save panel (file_picker), which cannot run
//   in a widget test; the empty-notebook export path (snackbar, no plugin
//   call) is covered instead.
// * The app's Cmd+Enter shortcut is exercised on the desktop matrix; it opens
//   the settings dialog when the demo is loaded but no API key is set.
//
// Theme note (audit finding)
// --------------------------
// `LingoDiffApp` hard-codes a dark `ThemeData` and exposes no `ThemeMode` or
// light theme. The "light" matrices therefore put the platform in light mode
// while the app keeps rendering its dark-only palette, so the light and dark
// goldens are visually identical. The distinct captures remain in place so a
// future light theme is audited automatically.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translation/main.dart';

/// Phone matrix size (iPhone-class logical pixels).
const Size _phoneSize = Size(390, 844);

/// Small phone + 1.6x platform text scale.
const Size _smallSize = Size(320, 568);

/// Narrow desktop window (panes still side-by-side at 800 wide).
const Size _narrowDesktopSize = Size(800, 600);

/// Typical macOS laptop window.
const Size _macDesktopSize = Size(1440, 900);

/// Directory that holds the golden baselines (relative to `test/`).
const String _goldenDir = 'test/goldens';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // -------------------------------------------------------------------------
  // Responsive audit matrices
  // -------------------------------------------------------------------------
  group('AFK UI/UX audit matrix', () {
    testWidgets('phone light (390x844)', (tester) async {
      _configureView(tester, _phoneSize);
      _setPlatformBrightness(tester, Brightness.light);

      await _pumpApp(tester);
      await _auditState(tester, 'phone light');

      await _expectAuditGolden(tester, 'audit_phone_light.png');
    });

    testWidgets('phone dark (390x844)', (tester) async {
      _configureView(tester, _phoneSize);
      _setPlatformBrightness(tester, Brightness.dark);

      await _pumpApp(tester);
      await _auditState(tester, 'phone dark');

      await _expectAuditGolden(tester, 'audit_phone_dark.png');
    });

    testWidgets('small phone (320x568) at 1.6x text scale', (tester) async {
      _configureView(tester, _smallSize);
      _setPlatformBrightness(tester, Brightness.light);
      _setTextScale(tester, 1.6);

      await _pumpApp(tester);
      await _auditState(tester, 'small 1.6x');

      await _expectAuditGolden(tester, 'audit_small_320x568_1_6x.png');
    });

    testWidgets('narrow desktop window (800x600)', (tester) async {
      _configureView(tester, _narrowDesktopSize);
      _setPlatformBrightness(tester, Brightness.light);

      await _pumpApp(tester);
      await _auditState(tester, 'narrow desktop');

      await _expectAuditGolden(tester, 'audit_narrow_desktop_800x600.png');
    });

    testWidgets('macOS desktop (1440x900)', (tester) async {
      _configureView(tester, _macDesktopSize);
      _setPlatformBrightness(tester, Brightness.light);

      await _pumpApp(tester);
      await _auditState(tester, 'macOS desktop');

      await _expectAuditGolden(tester, 'audit_macos_desktop_1440x900.png');
    });

    testWidgets('header actions stay pinned and unclipped while scrolling', (
      tester,
    ) async {
      _configureView(tester, _smallSize);
      _setPlatformBrightness(tester, Brightness.light);
      _setTextScale(tester, 1.6);

      await _pumpApp(tester);
      await _auditState(tester, 'pinned header: workspace top');

      final Finder header = find.byKey(const Key('workspace-header'));
      final Rect before = tester.getRect(header);

      // Scroll the workspace body, not the header.
      final Finder workspaceScroll = find.byType(SingleChildScrollView);
      expect(workspaceScroll, findsOneWidget);
      final ScrollableState scroll = tester.state<ScrollableState>(
        find
            .descendant(of: workspaceScroll, matching: find.byType(Scrollable))
            .first,
      );
      scroll.position.jumpTo(240);
      await tester.pumpAndSettle();

      expect(scroll.position.pixels, 240);
      expect(
        tester.getRect(header).top,
        before.top,
        reason: 'The header scrolled away with the workspace.',
      );
      _expectHeaderActionsFullyVisible(tester, 'pinned header: scrolled');
    });
  });

  // -------------------------------------------------------------------------
  // Interactive click-throughs
  // -------------------------------------------------------------------------
  group('AFK UI/UX interactive audit', () {
    testWidgets('settings dialog: provider, API key, save', (tester) async {
      _configureView(tester, _phoneSize);
      _setPlatformBrightness(tester, Brightness.dark);

      await _pumpApp(tester);
      await _auditState(tester, 'settings: workspace');

      // The pinned header keeps "Set API Key" on screen without swiping.
      await _tapHeaderAction(tester, find.text('Set API Key'));
      expect(find.text('⚙️ AI Tutor Configuration'), findsOneWidget);
      expect(find.text('PROVIDER'), findsOneWidget);
      expect(find.text('API KEY'), findsOneWidget);
      expect(find.text('MODEL NAME'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save Settings'), findsOneWidget);

      await _auditState(tester, 'settings: dialog open');
      await _expectAuditGolden(tester, 'audit_phone_settings_dialog.png');

      // Switch provider; the model field should follow the provider default.
      await _tapInBody(tester, find.text('Google Gemini API'));
      await _tapInBody(tester, find.text('DeepSeek API').last);
      expect(find.text('deepseek-chat'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Paste your API key...'),
        'audit-test-key',
      );
      await tester.pumpAndSettle();
      await _tapInBody(tester, find.text('Save Settings'));

      expect(find.text('⚙️ AI Tutor Configuration'), findsNothing);
      expect(find.text('API Ready (deepseek)'), findsOneWidget);
      await _auditState(tester, 'settings: saved');

      // Persisted through SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('lingodiff_provider'), 'deepseek');
      expect(prefs.getString('lingodiff_api_key'), 'audit-test-key');
      expect(prefs.getString('lingodiff_model'), 'deepseek-chat');
    });

    testWidgets('AI Tutor gate, offline diff, and clear workspace', (
      tester,
    ) async {
      _configureView(tester, _phoneSize);
      _setPlatformBrightness(tester, Brightness.light);

      await _pumpApp(tester);
      await _auditState(tester, 'gate: workspace');

      // Fill the two required fields on the stacked phone layout.
      await tester.enterText(
        find.byType(TextField).at(0),
        'I have been looking for a new apartment for three months.',
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        'He estado buscando por un nuevo apartamento por tres meses.',
      );
      await tester.pumpAndSettle();

      // No API key: the app must open settings and explain itself.
      await _tapInBody(
        tester,
        find.textContaining('Run AI Tutor & Pointer Diff'),
      );
      expect(find.text('⚙️ AI Tutor Configuration'), findsOneWidget);
      expect(
        find.text(
          'Please set your API key in Settings (or use Load Demo Exercise).',
        ),
        findsOneWidget,
      );
      await _auditState(tester, 'gate: settings dialog from AI Tutor');

      await tester.tap(find.byTooltip('Close settings'));
      await tester.pumpAndSettle();

      // Offline diff without an official reference text.
      await _tapInBody(
        tester,
        find.textContaining('Quick Word Diff Only (Offline)'),
      );
      expect(
        find.textContaining('No official reference text provided'),
        findsOneWidget,
      );
      await _auditState(tester, 'gate: offline diff');

      await _tapInBody(tester, find.text('Clear All'));
      expect(find.textContaining('No official reference text'), findsNothing);
      await _auditState(tester, 'gate: cleared');
    });

    testWidgets('demo, pointer view, save lesson, notebook add/delete', (
      tester,
    ) async {
      _configureView(tester, _phoneSize);
      _setPlatformBrightness(tester, Brightness.light);

      await _pumpApp(tester);
      await _tapHeaderAction(tester, find.text('✨ Load Demo Exercise'));

      // --- Demo results + interactive pointer view.
      expect(find.text('🎯 AI Teaching Breakdown'), findsOneWidget);
      expect(find.textContaining('76 / 100'), findsOneWidget);
      expect(
        find.text('VISUAL WORD DIFF (YOUR SPANISH VS. OFFICIAL REFERENCE)'),
        findsOneWidget,
      );
      expect(find.text('🎯 Interactive Pointer Mode'), findsOneWidget);
      expect(find.textContaining('[#1', findRichText: true), findsWidgets);
      await _auditState(tester, 'demo: loaded');
      await _expectAuditGolden(tester, 'audit_phone_demo.png');

      // Toggle back to the editable English source.
      await _tapInBody(tester, find.text('Edit Source'));
      expect(find.text('Edit Source'), findsNothing);
      expect(
        find.textContaining('I have been looking for a new apartment'),
        findsWidgets,
      );
      await _auditState(tester, 'demo: edit source');

      // --- Save a lesson from the first critique card.
      final Finder saveLesson = find.text('Save Lesson').first;
      await _tapInBody(tester, saveLesson);
      expect(find.text('Saved to Lessons'), findsOneWidget);
      await _auditState(tester, 'demo: lesson saved');

      // --- Notebook drawer with the saved lesson.
      await _tapHeaderAction(tester, find.textContaining('Lessons Learned'));
      expect(find.text('📓 Lessons Learned Notebook'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text("Prepositions & 'Llevar + Gerundio'"),
        ),
        findsOneWidget,
      );
      await _auditState(tester, 'drawer: saved lesson');
      await _expectAuditGolden(tester, 'audit_phone_drawer.png');

      // --- Manual add form.
      await _tapInBody(tester, find.text('+ Add Manual Lesson / Rule'));
      expect(find.text('Save to Notebook'), findsOneWidget);
      await _auditState(tester, 'drawer: add form');
      await _expectAuditGolden(tester, 'audit_phone_drawer_add.png');

      await tester.enterText(
        find.widgetWithText(TextField, 'English trigger phrase...'),
        'The test phrase',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Core takeaway / grammar rule...'),
        'This is a rule',
      );
      await tester.pumpAndSettle();
      await _tapInBody(tester, find.text('Save to Notebook'));

      expect(find.text('The test phrase'), findsOneWidget);
      expect(find.text('Save to Notebook'), findsNothing);
      await _auditState(tester, 'drawer: manual lesson added');

      // --- Delete the manual lesson (top of the list).
      await _tapInBody(tester, find.byIcon(Icons.delete_outline).first);
      expect(find.text('The test phrase'), findsNothing);
      await _auditState(tester, 'drawer: lesson deleted');

      // Close the drawer by tapping the scrim (drawer is 90% width on phones).
      await tester.tapAt(const Offset(10, 300));
      await tester.pumpAndSettle();
      await _auditState(tester, 'drawer: closed');
    });

    testWidgets('notebook export with an empty notebook', (tester) async {
      _configureView(tester, _phoneSize);
      _setPlatformBrightness(tester, Brightness.dark);

      await _pumpApp(tester);
      await _tapHeaderAction(tester, find.textContaining('Lessons Learned'));
      expect(find.text('📓 Lessons Learned Notebook'), findsOneWidget);
      expect(find.textContaining('No lessons saved yet.'), findsOneWidget);
      await _auditState(tester, 'export: empty drawer');
      await _expectAuditGolden(tester, 'audit_phone_drawer_empty.png');

      // Markdown export is guarded by the empty check, so no native save
      // panel is invoked in the test.
      await _tapInBody(tester, find.text('⬇ .MD'));
      expect(find.text('No lessons to export yet.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await _tapInBody(tester, find.text('⬇ Anki'));
      expect(find.text('No lessons to export yet.'), findsOneWidget);
      await _auditState(tester, 'export: empty snackbar');
    });

    testWidgets('narrow 320x568 @1.6x: settings, demo, drawer', (tester) async {
      _configureView(tester, _smallSize);
      _setPlatformBrightness(tester, Brightness.light);
      _setTextScale(tester, 1.6);

      await _pumpApp(tester);
      await _auditState(tester, 'narrow: workspace');

      // Settings dialog must scroll instead of overflowing.
      await _tapHeaderAction(tester, find.text('Set API Key'));
      expect(find.text('⚙️ AI Tutor Configuration'), findsOneWidget);
      await _auditState(tester, 'narrow: settings dialog');
      await _expectAuditGolden(tester, 'audit_small_settings_dialog.png');

      await tester.tap(find.byTooltip('Close settings'));
      await tester.pumpAndSettle();
      await _auditState(tester, 'narrow: settings closed');

      // Demo at 1.6x.
      await _tapHeaderAction(tester, find.text('✨ Load Demo Exercise'));
      expect(find.text('🎯 AI Teaching Breakdown'), findsOneWidget);
      await _auditState(tester, 'narrow: demo loaded');

      // Drawer header + add form at 1.6x.
      await _tapHeaderAction(tester, find.textContaining('Lessons Learned'));
      expect(find.text('📓 Lessons Learned Notebook'), findsOneWidget);
      await _auditState(tester, 'narrow: drawer');
      await _expectAuditGolden(tester, 'audit_small_drawer.png');

      await _tapInBody(tester, find.text('+ Add Manual Lesson / Rule'));
      expect(find.text('Save to Notebook'), findsOneWidget);
      await _auditState(tester, 'narrow: drawer add form');
    });

    testWidgets('macOS desktop: three-column view, shortcut, drawer', (
      tester,
    ) async {
      _configureView(tester, _macDesktopSize);
      _setPlatformBrightness(tester, Brightness.dark);

      await _pumpApp(tester);
      await _auditState(tester, 'macOS: workspace');

      // Three-column layout toggle.
      await _tapHeaderAction(tester, find.textContaining('3-Column View'));
      expect(find.text('📐 3-Column View: On'), findsOneWidget);

      final Rect englishPane = tester.getRect(find.text('1. ORIGINAL ENGLISH'));
      final Rect spanishPane = tester.getRect(
        find.text('2. YOUR SPANISH TRANSLATION'),
      );
      final Rect officialPane = tester.getRect(
        find.text('3. OFFICIAL / REFERENCE SPANISH TRANSLATION'),
      );
      expect(englishPane.top, spanishPane.top);
      expect(englishPane.left, lessThan(spanishPane.left));
      expect(spanishPane.left, lessThan(officialPane.left));
      await _auditState(tester, 'macOS: three-column');

      // Demo + Cmd+Enter shortcut (opens settings when no key is set).
      await _tapHeaderAction(tester, find.text('✨ Load Demo Exercise'));
      expect(find.text('🎯 AI Teaching Breakdown'), findsOneWidget);
      await _auditState(tester, 'macOS: demo loaded');
      await _expectAuditGolden(tester, 'audit_macos_desktop_demo.png');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pumpAndSettle();
      expect(find.text('⚙️ AI Tutor Configuration'), findsOneWidget);
      await _auditState(tester, 'macOS: Cmd+Enter settings');
      await tester.tap(find.byTooltip('Close settings'));
      await tester.pumpAndSettle();

      // Notebook drawer on desktop (500 px wide).
      await _tapHeaderAction(tester, find.textContaining('Lessons Learned'));
      expect(find.text('📓 Lessons Learned Notebook'), findsOneWidget);
      await _auditState(tester, 'macOS: drawer');
      await _expectAuditGolden(tester, 'audit_macos_desktop_drawer.png');
    });
  });
}

// ---------------------------------------------------------------------------
// Harness helpers
// ---------------------------------------------------------------------------

/// Sets a deterministic logical surface plus device pixel ratio and guarantees
/// the host values are restored, even if an expectation fails.
void _configureView(
  WidgetTester tester,
  Size logicalSize, {
  double devicePixelRatio = 1.0,
}) {
  tester.view.devicePixelRatio = devicePixelRatio;
  tester.view.physicalSize = logicalSize * devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void _setPlatformBrightness(WidgetTester tester, Brightness brightness) {
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
}

/// Equivalent to `TextScaler.linear(1.6)`; [TestPlatformDispatcher] exposes the
/// scale factor rather than a `TextScaler` of its own.
void _setTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: LingoDiffApp()));
  await tester.pumpAndSettle();
}

/// Drains every queued framework exception and fails if any were reported.
/// A RenderFlex overflow is reported as an uncaught framework exception, so
/// this covers "zero RenderFlex overflows/errors" for the current state.
void _expectNoExceptions(WidgetTester tester, String step) {
  final List<Object> exceptions = <Object>[];
  while (true) {
    final Object? exception = tester.takeException();
    if (exception == null) break;
    exceptions.add(exception);
  }
  expect(
    exceptions,
    isEmpty,
    reason:
        'Uncaught widget/layout exception(s) during "$step":\n'
        '${exceptions.join('\n\n')}',
  );
}

/// Enforces labelled controls, 48x48dp Android tap targets, and WCAG AA text
/// contrast for the current state, then checks that the audit itself did not
/// introduce an error.
Future<void> _auditState(WidgetTester tester, String step) async {
  // The tap-target guideline measures the *clipped* semantics rect, so a
  // widget scrolled half off the viewport would be reported as too small.
  // Return scrollable pages to their start before auditing so partial clipping
  // never produces a false finding. (Small controls that are fully visible are
  // still caught at every audited state.)
  await _normalizeScrollsForAudit(tester);

  _expectNoExceptions(tester, step);

  // The header is pinned: every action must be on screen without scrolling.
  _expectHeaderActionsFullyVisible(tester, step);

  final SemanticsHandle handle = tester.ensureSemantics();
  try {
    await expectLater(
      tester,
      meetsGuideline(labeledTapTargetGuideline),
      reason: 'Tappable controls are unlabelled at "$step".',
    );
    await expectLater(
      tester,
      meetsGuideline(androidTapTargetGuideline),
      reason: 'A tappable control is smaller than 48x48dp at "$step".',
    );

    final Evaluation contrast = await textContrastGuideline.evaluate(tester);
    expect(
      contrast.passed,
      isTrue,
      reason: 'Text contrast is below WCAG AA at "$step".\n${contrast.reason}',
    );
  } finally {
    handle.dispose();
  }

  // Let the focus/semantics teardown settle before the next interaction;
  // otherwise the Autofocus node can be used after disposal in tests.
  await tester.pump();

  _expectNoExceptions(tester, '$step (after semantics)');
}

/// Resets the workspace body scroll (when the notebook drawer is closed) before
/// an accessibility audit.
///
/// `androidTapTargetGuideline` compares the visible/clipped semantics rect, so
/// a control that is half scrolled out of the viewport looks smaller than it
/// is. Resetting the body scroll keeps the assertion about real widget size.
/// The header is pinned and never scrolls, so it needs no reset.
Future<void> _normalizeScrollsForAudit(WidgetTester tester) async {
  final bool drawerOpen = find.byType(Drawer).evaluate().isNotEmpty;
  if (drawerOpen) return;

  final Finder anchor = find.text('1. ORIGINAL ENGLISH');
  final Finder scrollable = find
      .ancestor(of: anchor, matching: find.byType(Scrollable))
      .first;
  if (scrollable.evaluate().isEmpty) return;
  final ScrollableState state = tester.state<ScrollableState>(scrollable);
  if (!state.position.hasContentDimensions || state.position.pixels == 0) {
    return;
  }
  state.position.jumpTo(0);
  await tester.pump();
}

/// Scrolls the target into view inside the body (or drawer) and taps it.
Future<void> _tapInBody(WidgetTester tester, Finder finder) async {
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Asserts the pinned header owns every action, that each action is fully
/// inside the viewport and the header's own bounds (no clipping, no horizontal
/// scroll needed), and that each one is a >= 48x48dp tap target.
void _expectHeaderActionsFullyVisible(WidgetTester tester, String step) {
  final Finder header = find.byKey(const Key('workspace-header'));
  expect(header, findsOneWidget, reason: 'Pinned header missing at "$step".');

  final Finder buttons = find.descendant(
    of: header,
    matching: find.byType(OutlinedButton),
  );
  expect(
    buttons,
    findsWidgets,
    reason: 'The header exposes no actions at "$step".',
  );

  final Size viewport = tester.view.physicalSize / tester.view.devicePixelRatio;
  final Rect headerRect = tester.getRect(header);
  expect(
    headerRect.left,
    greaterThanOrEqualTo(-0.5),
    reason: 'Header starts off-screen at "$step".',
  );
  expect(
    headerRect.right,
    lessThanOrEqualTo(viewport.width + 0.5),
    reason: 'Header is clipped by the right edge at "$step".',
  );

  for (int i = 0; i < buttons.evaluate().length; i++) {
    final Finder button = buttons.at(i);
    final Rect rect = tester.getRect(button);
    final String label = find
        .descendant(of: button, matching: find.byType(Text))
        .evaluate()
        .map((Element e) => (e.widget as Text).data ?? '')
        .join(' ')
        .trim();

    expect(
      rect.left,
      greaterThanOrEqualTo(-0.5),
      reason: 'Header action "$label" is clipped on the left at "$step".',
    );
    expect(
      rect.right,
      lessThanOrEqualTo(viewport.width + 0.5),
      reason: 'Header action "$label" is clipped on the right at "$step".',
    );
    expect(
      rect.top,
      greaterThanOrEqualTo(headerRect.top - 0.5),
      reason: 'Header action "$label" escapes the header at "$step".',
    );
    expect(
      rect.bottom,
      lessThanOrEqualTo(headerRect.bottom + 0.5),
      reason: 'Header action "$label" escapes the header at "$step".',
    );
    expect(
      rect.width,
      greaterThanOrEqualTo(48.0),
      reason: 'Header action "$label" is narrower than 48dp at "$step".',
    );
    expect(
      rect.height,
      greaterThanOrEqualTo(48.0),
      reason: 'Header action "$label" is shorter than 48dp at "$step".',
    );
  }
}

/// Taps an action in the pinned header. The header must already be on screen:
/// any off-screen or clipped action is a layout failure, not something to
/// scroll around.
Future<void> _tapHeaderAction(WidgetTester tester, Finder finder) async {
  expect(finder, findsOneWidget);

  final Finder header = find.byKey(const Key('workspace-header'));
  expect(
    find.descendant(of: header, matching: finder),
    findsOneWidget,
    reason: 'Header action $finder is not inside the pinned header.',
  );

  _expectHeaderActionsFullyVisible(tester, 'tapping $finder');

  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Writes the baseline only under `--update-goldens`; otherwise compares
/// against the committed baseline. Missing baselines are skipped so a fresh
/// checkout without generated goldens still reports the behavioural audit.
Future<void> _expectAuditGolden(WidgetTester tester, String fileName) async {
  final Finder app = find.byType(MaterialApp);
  expect(app, findsOneWidget);

  final File baseline = File('$_goldenDir/$fileName');

  if (autoUpdateGoldenFiles) {
    // autoUpdateGoldenFiles is only true under `--update-goldens`; create the
    // directory on demand so baselines land in test/goldens/.
    final Directory dir = Directory(_goldenDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  } else if (!baseline.existsSync()) {
    debugPrint(
      'AUDIT golden: skipped "$fileName" because no baseline exists. '
      'Run `flutter test --update-goldens test/ui_ux_audit_test.dart`.',
    );
    return;
  }

  await expectLater(app, matchesGoldenFile('goldens/$fileName'));
}
