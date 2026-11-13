import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studio_app/main.dart';
import 'package:studio_app/src/screens.dart';
import 'package:studio_app/src/tasks.dart';
import 'package:studio_app/studio_theme.dart';

void main() {
  // Tests run offline, so use the default font instead of downloading one.
  GoogleFonts.config.allowRuntimeFetching = false;
  final tokens = jsonDecode(
    File('design/tokens.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  Future<AppState> freshState([Map<String, Object> saved = const {}]) async {
    SharedPreferences.setMockInitialValues(saved);
    return AppState(await SharedPreferences.getInstance());
  }

  testWidgets('the app uses the colours from design/tokens.json', (
    tester,
  ) async {
    final studio = StudioTheme.fromTokens(tokens);
    await tester.pumpWidget(
      StudioApp(studio: studio, state: await freshState()),
    );
    final theme = Theme.of(tester.element(find.byType(HomeShell)));
    expect(theme.colorScheme.primary, studio.color('primary'));
    expect(theme.scaffoldBackgroundColor, studio.color('bg'));
  });

  testWidgets('adding and ticking a task is saved', (tester) async {
    final state = await freshState();
    await tester.pumpWidget(
      StudioApp(studio: StudioTheme.fromTokens(tokens), state: state),
    );
    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Call Sam');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(find.text('Call Sam'), findsOneWidget);
    await tester.tap(find.text('Call Sam'));
    await tester.pumpAndSettle();
    final again = AppState(await SharedPreferences.getInstance());
    expect(again.tasks.first.title, 'Call Sam');
    expect(again.tasks.first.done, isTrue);
  });

  test('filters and counts', () async {
    final state = await freshState();
    state.add('  ');
    expect(state.total, 3);
    expect(state.filtered(Filter.done).length, 1);
    state.remove('t1');
    expect(state.filtered(Filter.done), isEmpty);
  });
}
