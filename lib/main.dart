import 'package:flutter/material.dart';
import 'router.dart';
import 'data/recipe_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RecipeStore.instance.init();
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
    RecipeStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    RecipeStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final store = RecipeStore.instance;
    return MaterialApp.router(
      title: 'Recipe Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: store.darkMode ? Brightness.dark : Brightness.light,
      ),
      routerConfig: _router,
    );
  }
}
