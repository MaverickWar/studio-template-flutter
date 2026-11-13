import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/screens.dart';
import 'src/tasks.dart';
import 'studio_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Colours, fonts and corners come from design/tokens.json (Universal App Studio writes it).
  final studio = await StudioTheme.load();
  final state = AppState(await SharedPreferences.getInstance());
  runApp(StudioApp(studio: studio, state: state));
}

class StudioApp extends StatelessWidget {
  const StudioApp({super.key, required this.studio, required this.state});

  final StudioTheme studio;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final name = studio.tokens['name'] as String? ?? 'New project';
    return MaterialApp(
      title: name,
      theme: studio.theme,
      debugShowCheckedModeBanner: false,
      home: HomeShell(state: state, projectName: name),
    );
  }
}
