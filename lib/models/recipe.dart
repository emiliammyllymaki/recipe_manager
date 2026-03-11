import 'dart:convert';

class Recipe {
  final String id;
  String title;
  int prepMinutes;
  int servings;
  String difficulty; // 'Easy', 'Medium', 'Hard'
  List<String> ingredients;
  List<String> tags;
  String notes;
  bool isFavorite;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    required this.prepMinutes,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.tags,
    required this.notes,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory Recipe.newRecipe() => Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '',
        prepMinutes: 0,
        servings: 2,
        difficulty: 'Easy',
        ingredients: const [],
        tags: const [],
        notes: '',
        createdAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'prepMinutes': prepMinutes,
        'servings': servings,
        'difficulty': difficulty,
        'ingredients': ingredients,
        'tags': tags,
        'notes': notes,
        'isFavorite': isFavorite,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        prepMinutes: json['prepMinutes'] as int? ?? 0,
        servings: json['servings'] as int? ?? 2,
        difficulty: json['difficulty'] as String? ?? 'Easy',
        ingredients: (json['ingredients'] as List?)?.cast<String>() ?? [],
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        notes: json['notes'] as String? ?? '',
        isFavorite: json['isFavorite'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );

  static String encodeList(List<Recipe> recipes) =>
      jsonEncode(recipes.map((r) => r.toJson()).toList());

  static List<Recipe> decodeList(String source) {
    final raw = jsonDecode(source) as List<dynamic>;
    return raw.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
  }
}
