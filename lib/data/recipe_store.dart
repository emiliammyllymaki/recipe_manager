import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class RecipeStore extends ChangeNotifier {
  static const _recipesKey = 'recipes_v1';
  static const _maxWidthKey = 'max_width_v1';
  static const _themeDarkKey = 'theme_dark_v1';

  static final RecipeStore instance = RecipeStore._();
  RecipeStore._();

  final ValueNotifier<List<Recipe>> recipes = ValueNotifier<List<Recipe>>([]);
  double maxContentWidth = 1000;
  bool darkMode = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recipesKey);
    if (raw != null && raw.isNotEmpty) {
      recipes.value = Recipe.decodeList(raw);
    }
    maxContentWidth = prefs.getDouble(_maxWidthKey) ?? 1000;
    darkMode = prefs.getBool(_themeDarkKey) ?? false;
  }

  Future<void> addOrUpdate(Recipe recipe) async {
    final list = [...recipes.value];
    final idx = list.indexWhere((r) => r.id == recipe.id);
    if (idx >= 0) {
      list[idx] = recipe;
    } else {
      list.insert(0, recipe);
    }
    recipes.value = list;
    await _persist();
  }

  Future<void> remove(String id) async {
    recipes.value = recipes.value.where((r) => r.id != id).toList();
    await _persist();
  }

  Future<void> toggleFavorite(String id) async {
    final list = [...recipes.value];
    final idx = list.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      final r = list[idx];
      r.isFavorite = !r.isFavorite;
      list[idx] = r;
      recipes.value = list;
      await _persist();
    }
  }

  // Safe null-returning lookup — no more "null as Recipe" crash
  Recipe? byId(String id) {
    try {
      return recipes.value.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> setMaxWidth(double value) async {
    maxContentWidth = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_maxWidthKey, value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeDarkKey, value);
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recipesKey, Recipe.encodeList(recipes.value));
    notifyListeners();
  }
}
