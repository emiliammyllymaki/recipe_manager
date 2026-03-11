import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/recipe_store.dart';
import '../models/recipe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  String _selectedCategory = 'All';
  bool _showFavoritesOnly = false;

  static const _categories = ['All', 'Savoury', 'Sweet', 'Snack', 'Drink'];

  Future<void> _confirmDelete(BuildContext context, Recipe r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${r.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) RecipeStore.instance.remove(r.id);
  }

  @override
  Widget build(BuildContext context) {
    final store = RecipeStore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Manager'),
        actions: [
          Tooltip(
            message: _showFavoritesOnly ? 'Show all' : 'Show favourites',
            child: IconButton(
              icon: Icon(
                _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                color: _showFavoritesOnly
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
              onPressed: () =>
                  setState(() => _showFavoritesOnly = !_showFavoritesOnly),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Recipe'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by title, ingredient or tag...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _categories.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(c),
                    selected: _selectedCategory == c,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = c),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Recipe grid
          Expanded(
            child: ValueListenableBuilder<List<Recipe>>(
              valueListenable: store.recipes,
              builder: (context, list, _) {
                final filtered = list.where((r) {
                  final matchesQuery = _query.isEmpty ||
                      r.title.toLowerCase().contains(_query) ||
                      r.tags.join(',').toLowerCase().contains(_query) ||
                      r.ingredients.join(',').toLowerCase().contains(_query);

                  final matchesCategory = _selectedCategory == 'All' ||
                      r.tags.contains(_selectedCategory);

                  final matchesFav = !_showFavoritesOnly || r.isFavorite;

                  return matchesQuery && matchesCategory && matchesFav;
                }).toList();

                if (filtered.isEmpty) {
                  return _EmptyState(favoritesOnly: _showFavoritesOnly);
                }

                // Responsive grid columns
                final width = MediaQuery.of(context).size.width;
                final columns = width > 900 ? 3 : width > 600 ? 2 : 1;

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final r = filtered[i];
                    return _RecipeCard(
                      recipe: r,
                      onTap: () => context.go('/recipe/${r.id}'),
                      onFavorite: () => store.toggleFavorite(r.id),
                      onDelete: () => _confirmDelete(context, r),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool favoritesOnly;
  const _EmptyState({required this.favoritesOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            favoritesOnly ? Icons.favorite_border : Icons.restaurant_menu,
            size: 72,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            favoritesOnly ? 'No favourites yet.' : 'No recipes found.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            favoritesOnly
                ? 'Tap the heart icon on a recipe to add it here.'
                : 'Tap "Add Recipe" to get started!',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  const _RecipeCard({
    required this.recipe,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
  });

  Color _difficultyColor(BuildContext context, String difficulty) {
    return switch (difficulty) {
      'Easy' => Colors.green,
      'Medium' => Colors.orange,
      'Hard' => Colors.red,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final r = recipe;
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      r.title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: onFavorite,
                    child: Icon(
                      r.isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: r.isFavorite ? cs.error : cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Meta row
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 13, color: cs.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 3),
                  Text('${r.prepMinutes} min',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 10),
                  Icon(Icons.people_outline, size: 13, color: cs.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 3),
                  Text('${r.servings}',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 10),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _difficultyColor(context, r.difficulty),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(r.difficulty,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 6),

              // Tags
              if (r.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: r.tags.take(3).map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 10)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                      )).toList(),
                ),

              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: 'Delete',
                  color: cs.error.withValues(alpha: 0.7),
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
