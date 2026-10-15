import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translation/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LingoDiffApp smoke test: loads navbar and triggers demo exercise',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const ProviderScope(child: LingoDiffApp()));
    await tester.pumpAndSettle();

    // Verify Title and Subtitle exist
    expect(find.text('LingoDiff Studio'), findsOneWidget);
    expect(find.text('✨ Load Demo Exercise'), findsOneWidget);

    // Click Load Demo Exercise
    await tester.tap(find.text('✨ Load Demo Exercise'));
    await tester.pumpAndSettle();

    // Verify AI Teaching Breakdown & critique cards render
    expect(find.text('🎯 AI Teaching Breakdown'), findsOneWidget);
    expect(find.text('VISUAL WORD DIFF (YOUR SPANISH VS. OFFICIAL REFERENCE)'), findsOneWidget);
    expect(find.textContaining('76 / 100'), findsOneWidget);
  });
}
