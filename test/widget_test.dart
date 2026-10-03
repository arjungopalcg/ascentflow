import 'package:ascent_flow/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Supabase isn't initialised in tests, so the app runs on its local sample
// data (3 tasks, 1 completed; 3 goals, 1 met).

Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const ProviderScope(child: AscentFlowApp()));
  // Let the home screen's entrance animation finish.
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Today screen shows the greeting and real progress',
      (tester) async {
    await pumpApp(tester);

    expect(find.textContaining('Alex'), findsOneWidget);
    expect(find.text('2 of 6 done'), findsOneWidget);
  });

  testWidgets('Every tab in the bottom bar is labelled', (tester) async {
    await pumpApp(tester);

    for (final label in ['Today', 'Tasks', 'Focus', 'Journal', 'More']) {
      expect(find.text(label), findsWidgets, reason: '$label tab');
    }
  });

  testWidgets('Ticking a plan item updates today\'s progress',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Read 20 pages'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('3 of 6 done'), findsOneWidget);
  });

  testWidgets('Tasks tab lists upcoming tasks with readable priorities',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Tasks').last);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Review Q1 strategy deck'), findsWidgets);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('2 left'), findsOneWidget);
  });

  testWidgets('Main tabs lay out without overflow at 150% text size',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const ProviderScope(child: AscentFlowApp()));
    await tester.pump(const Duration(seconds: 2));

    for (final tab in ['Tasks', 'Focus', 'Journal', 'More', 'Today']) {
      await tester.tap(find.text(tab).last);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull, reason: '$tab tab');
    }
  });
}
