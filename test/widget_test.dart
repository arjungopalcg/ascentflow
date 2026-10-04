import 'package:ascent_flow/game/climb_engine.dart';
import 'package:ascent_flow/main.dart';
import 'package:ascent_flow/providers/prefs_provider.dart';
import 'package:ascent_flow/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Supabase isn't initialised in tests, so the app runs on its local sample
// data (3 tasks, 1 completed; 3 goals, 1 met).

/// A returning user who has finished setup.
const _onboarded = <String, Object>{
  'profile.name': 'Alex',
  'profile.onboarded': true,
  'home.enabled': ['progress', 'plan', 'challenge', 'motivation'],
};

Future<void> pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = _onboarded,
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  // Reduce motion: Pip, the campfire and the trail stop looping, so
  // pumpAndSettle can settle. (Also how real users with that setting see it.)
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  // The focus lock's Android side: nothing granted, every call succeeds.
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('ascentflow/focus'),
    (call) async => call.method.startsWith('has') ? false : null,
  );
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('ascentflow/focus'), null));

  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(sp)],
    child: const AscentFlowApp(),
  ));
  await tester.pump(const Duration(seconds: 2));
}

/// Home's own scroll view (other tabs stay mounted in an IndexedStack).
final _homeScroll = find
    .descendant(of: find.byType(HomeScreen), matching: find.byType(Scrollable))
    .first;

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Today screen greets by name and shows the Daily climb', (tester) async {
    await pumpApp(tester);

    expect(find.textContaining('Alex'), findsOneWidget);
    expect(find.text('0 of 5 steps'), findsOneWidget);
    expect(find.text('0 m'), findsOneWidget, reason: 'altitude in the top bar');
  });

  testWidgets('Every tab in the bottom bar is labelled', (tester) async {
    await pumpApp(tester);

    for (final label in ['Today', 'Tasks', 'Focus', 'Journal', 'More']) {
      expect(find.text(label), findsWidgets, reason: '$label tab');
    }
  });

  testWidgets('Finishing a task climbs the trail and earns metres', (tester) async {
    await pumpApp(tester);

    await tester.scrollUntilVisible(find.text('Review Q1 strategy deck'), 300, scrollable: _homeScroll);
    await tester.tap(find.text('Review Q1 strategy deck'));
    await tester.pump();
    expect(find.text('+20 m'), findsOneWidget, reason: 'the floating gain');
    await tester.pump(const Duration(seconds: 3)); // gain chip and streak banner finish

    expect(find.text('20 m'), findsOneWidget);
    expect(find.text('1 of 5 steps'), findsOneWidget);
    expect(find.text('+20 m today'), findsOneWidget);
  });

  testWidgets('Finishing the Daily climb plays the summit', (tester) async {
    await pumpApp(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(HomeScreen)));
    final climb = container.read(climbProvider.notifier);

    for (final a in [ClimbAction.task, ClimbAction.task, ClimbAction.task, ClimbAction.focus, ClimbAction.mood]) {
      climb.record(a);
    }
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('You summited today!'), findsOneWidget);
    await tester.tap(find.text('Keep climbing'));
    await tester.pumpAndSettle();
    expect(find.text('Summit reached!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4)); // let banners finish
  });

  testWidgets('Tasks tab lists upcoming tasks with readable priorities', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Tasks').last);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Review Q1 strategy deck'), findsWidgets);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('2 left'), findsOneWidget);
  });

  testWidgets('Main tabs lay out without overflow at 150% text size', (tester) async {
    await pumpApp(tester, textScale: 1.5);

    for (final tab in ['Tasks', 'Focus', 'Journal', 'More', 'Today']) {
      await tester.tap(find.text(tab).last);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull, reason: '$tab tab');
    }
  });

  testWidgets('First launch: setup builds home from the answers', (tester) async {
    await pumpApp(tester, prefs: const {});

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Sam');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('When does your day usually start?'), findsOneWidget);
    await tester.tap(find.text('Around 8'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Continue stays disabled until something is picked.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('What would you like help with?'), findsOneWidget);

    await tester.tap(find.text('Focus deeply'));
    await tester.ensureVisible(find.text('Save money'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save money'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Here\'s your home screen, Sam'), findsOneWidget);
    await tester.tap(find.text('Start climbing'));
    await tester.pump(const Duration(seconds: 2));

    expect(find.textContaining('Sam'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('profile.dayStart'), 'usual');
    expect(find.text('Focus session'), findsNothing, reason: 'Catalog names are for Edit home');
    expect(find.text('One thing for 25 minutes.'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('saved'), 300, scrollable: _homeScroll);
    expect(find.textContaining('saved'), findsOneWidget);
    // Not picked, so not on Home.
    expect(find.text('Today\'s plan'), findsNothing);
  });

  testWidgets('Edit home adds a widget from another section', (tester) async {
    await pumpApp(tester);

    await tester.scrollUntilVisible(find.text('Edit home'), 300, scrollable: _homeScroll);
    await tester.tap(find.text('Edit home'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byTooltip('Add Mood check-in'),
      300,
      scrollable: find.descendant(of: find.byType(CustomScrollView), matching: find.byType(Scrollable)).first,
    );
    await tester.tap(find.byTooltip('Add Mood check-in'));
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('How are you feeling?'), 300, scrollable: _homeScroll);
    expect(find.text('How are you feeling?'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('home.enabled'), contains('mood'));
  });

  testWidgets('Giving up a focus session makes Pip slip', (tester) async {
    await pumpApp(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(HomeScreen)));
    final climb = container.read(climbProvider.notifier);
    for (var i = 0; i < 4; i++) {
      climb.record(ClimbAction.task);
    }
    await tester.pump(const Duration(seconds: 4));
    final before = container.read(climbProvider).altitude;
    expect(before, greaterThan(focusFallMetres)); // and below the first camp

    await tester.tap(find.text('Focus').last);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byIcon(LucideIcons.play));
    await tester.pump(const Duration(milliseconds: 500));
    // No lock permissions in tests, so it offers setup first.
    expect(find.text('Set up the focus lock'), findsOneWidget);
    await tester.tap(find.text('Start without lock'));
    await tester.pump(const Duration(seconds: 2));

    // Like Forest, focus can't be paused: the button is now "give up".
    expect(find.byIcon(LucideIcons.pause), findsNothing);
    await tester.tap(find.byIcon(LucideIcons.flag));
    await tester.pump(const Duration(seconds: 1)); // the timer keeps running
    expect(find.text('Give up this climb?'), findsOneWidget);
    await tester.tap(find.text('Give up'));
    await tester.pump(const Duration(seconds: 1));

    expect(container.read(climbProvider).altitude, before - focusFallMetres);
    expect(container.read(climbProvider).falls, 1);
    await tester.pump(const Duration(seconds: 4)); // slip banner finishes
  });

  testWidgets('Closing the app mid-focus makes Pip slip on the next launch', (tester) async {
    await pumpApp(tester, prefs: {..._onboarded, 'focus.pendingSlip': true});
    final container = ProviderScope.containerOf(tester.element(find.byType(HomeScreen)));

    expect(container.read(climbProvider).falls, 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('focus.pendingSlip'), isNull, reason: 'applied once');
    await tester.pump(const Duration(seconds: 4)); // slip banner finishes
  });
}
