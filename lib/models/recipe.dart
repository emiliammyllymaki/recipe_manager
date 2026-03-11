import 'dart:convert';

class Recipe {
  final String id;
  String title;
  int prepMinutes;
  int servings;
  List<String> ingredients;
  List<String> tags;
  String notes;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.prepMinutes,
    required this.servings,
    required this.ingredients,
    required this.tags,
    required this.notes,
    this.isFavorite = false,
  });

  factory Recipe.newRecipe() => Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '',
        prepMinutes: 0,
        servings: 2,
        ingredients: const [],
        tags: const [],
        notes: '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'prepMinutes': prepMinutes,
        'servings': servings,
        'ingredients': ingredients,
        'tags': tags,
        'notes': notes,
        'isFavorite': isFavorite,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        prepMinutes: json['prepMinutes'] as int? ?? 0,
        servings: json['servings'] as int? ?? 2,
        ingredients: (json['ingredients'] as List?)?.cast<String>() ?? [],
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        notes: json['notes'] as String? ?? '',
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  static String encodeList(List<Recipe> recipes) =>
      jsonEncode(recipes.map((r) => r.toJson()).toList());

  static List<Recipe> decodeList(String source) {
    final raw = jsonDecode(source) as List<dynamic>;
    return raw.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
  }
}
