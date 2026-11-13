// Made by Universal App Studio. Reads design/tokens.json and builds the app's ThemeData.
// Change the look in Studio (it rewrites design/tokens.json), never here.
//
// Setup (once), in pubspec.yaml:
//   dependencies:
//     google_fonts: ^9.0.0
//     material_ui: ^1.1.0   (Flutter 3.47 and later; older Flutter uses package:flutter/material.dart)
//   flutter:
//     assets:
//       - design/tokens.json
// Copy this file to lib/studio_theme.dart, then in main.dart:
//   void main() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     final studio = await StudioTheme.load();
//     runApp(MaterialApp(theme: studio.theme, home: const HomeScreen()));
//   }
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

class StudioTheme {
  StudioTheme._(this.tokens);

  final Map<String, dynamic> tokens;

  static Future<StudioTheme> load() async {
    final raw = await rootBundle.loadString('design/tokens.json');
    return StudioTheme._(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// For tests and previews: build the theme from tokens already in hand.
  factory StudioTheme.fromTokens(Map<String, dynamic> tokens) =>
      StudioTheme._(tokens);

  Map<String, dynamic> _group(String key) =>
      (tokens[key] as Map<String, dynamic>?) ?? const {};

  Color color(String key) {
    final hex = (_group('color')[key] as String? ?? '#000000').replaceFirst(
      '#',
      '',
    );
    return Color(int.parse('FF$hex', radix: 16));
  }

  double radius(String key) =>
      double.tryParse(
        (_group('radius')[key] as String? ?? '8px').replaceAll('px', ''),
      ) ??
      8;

  List<double> get space =>
      ((tokens['space'] as List<dynamic>?) ?? const [4, 8, 16, 24, 32, 48])
          .map((v) => (v as num).toDouble())
          .toList();

  String get displayFont => _group('font')['display'] as String? ?? 'Roboto';
  String get bodyFont => _group('font')['body'] as String? ?? 'Roboto';

  TextTheme _fontTheme(String family, TextTheme base) {
    try {
      return GoogleFonts.getTextTheme(family, base);
    } catch (_) {
      return base; // A font Google Fonts doesn't have: keep the default.
    }
  }

  ThemeData get theme {
    final scheme = ColorScheme.fromSeed(seedColor: color('primary')).copyWith(
      primary: color('primary'),
      onPrimary: color('on-primary'),
      secondary: color('accent'),
      onSecondary: color('on-accent'),
      surface: color('surface'),
      onSurface: color('text'),
      onSurfaceVariant: color('text-muted'),
    );
    final base = ThemeData(colorScheme: scheme).textTheme;
    final body = _fontTheme(bodyFont, base);
    final display = _fontTheme(displayFont, base);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius('md')),
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: color('bg'),
      textTheme: body.copyWith(
        displayLarge: display.displayLarge,
        displayMedium: display.displayMedium,
        displaySmall: display.displaySmall,
        headlineLarge: display.headlineLarge,
        headlineMedium: display.headlineMedium,
        headlineSmall: display.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: color('surface'),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius('lg')),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: shape),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: shape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: shape),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius('md')),
        ),
      ),
    );
  }
}
