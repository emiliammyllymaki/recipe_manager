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
  String query = '';
  String selectedCategory = 'All';
  bool showFavoritesOnly = false;

  final List<String> categories = [
    'All',
    'Savoury',
    'Sweet',
    'Snack',
    'Drink',
  ];

  Future<void> _confirmDelete(BuildContext context, Recipe r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
    if (confirmed == true) {
      RecipeStore.instance.remove(r.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = RecipeStore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          Tooltip(
            message: showFavoritesOnly ? 'Show all' : 'Show favourites',
            child: IconButton(
              icon: Icon(
                showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                color: showFavoritesOnly
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
              onPressed: () =>
                  setState(() => showFavoritesOnly = !showFavoritesOnly),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add recipe'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search recipes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => query = value.toLowerCase()),
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: categories.map((c) {
                final isSelected = selectedCategory == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(c),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => selectedCategory = c),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Recipe list
          Expanded(
            child: ValueListenableBuilder<List<Recipe>>(
              valueListenable: store.recipes,
              builder: (context, list, _) {
                final filtered = list.where((r) {
                  final titleLc = r.title.toLowerCase();
                  final tagsLc = r.tags.join(',').toLowerCase();
                  final ingLc = r.ingredients.join(',').toLowerCase();

                  final matchesQuery = query.isEmpty ||
                      titleLc.contains(query) ||
                      tagsLc.contains(query) ||
                      ingLc.contains(query);

                  final matchesCategory = selectedCategory == 'All' ||
                      r.tags.contains(selectedCategory);

                  final matchesFav = !showFavoritesOnly || r.isFavorite;

                  return matchesQuery && matchesCategory && matchesFav;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_menu,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          showFavoritesOnly
                              ? 'No favourites yet.'
                              : 'No recipes or search results.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                final width = MediaQuery.of(context).size.width;
                int columns = 1;
                if (width > 600) columns = 2;
                if (width > 900) columns = 3;

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
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

  @override
  Widget build(BuildContext context) {
    final r = recipe;
    final colorScheme = Theme.of(context).colorScheme;

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      r.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onFavorite,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        r.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: r.isFavorite ? colorScheme.error : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14),
                  const SizedBox(width: 4),
                  Text('${r.prepMinutes} min',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 12),
                  const Icon(Icons.people_outline, size: 14),
                  const SizedBox(width: 4),
                  Text('${r.servings} servings',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: r.tags
                    .take(3)
                    .map((t) => Chip(
                          label: Text(t),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  color: colorScheme.error,
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