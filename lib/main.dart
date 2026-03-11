import 'package:flutter/material.dart';
import 'router.dart';
import 'data/recipe_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RecipeStore.instance.init(); // Lataa muistista (shared_preferences)
  runApp(const RecipeApp());
}

class RecipeApp extends StatefulWidget {
  const RecipeApp({super.key});
  @override
  State<RecipeApp> createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> {
  final _tabIndex = ValueNotifier<int>(0);
  late final _router = AppRouter.build(tabIndex: _tabIndex);

  @override
  void initState() {
    super.initState();
    RecipeStore.instance.addListener(_onSettings);
  }

  @override
  void dispose() {
    RecipeStore.instance.removeListener(_onSettings);
    super.dispose();
  }

  void _onSettings() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final store = RecipeStore.instance;
    return MaterialApp.router(
      title: 'Reseptit',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: store.darkMode ? Brightness.dark : Brightness.light,
      ),
      routerConfig: _router,
    );
  }
}
