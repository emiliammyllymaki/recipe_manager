import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/recipe_store.dart';
import '../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String id;
  const RecipeDetailScreen({super.key, required this.id});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe?'),
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
    if (confirmed == true && context.mounted) {
      RecipeStore.instance.remove(id);
      context.go('/');
    }
  }

  Color _difficultyColor(String difficulty) => switch (difficulty) {
        'Easy' => Colors.green,
        'Medium' => Colors.orange,
        'Hard' => Colors.red,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    final store = RecipeStore.instance;

    return ValueListenableBuilder<List<Recipe>>(
      valueListenable: store.recipes,
      builder: (context, _, __) {
        final Recipe? r = store.byId(id);

        if (r == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Recipe')),
            body: const Center(child: Text('Recipe not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(r.title),
            actions: [
              IconButton(
                icon: Icon(
                  r.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color:
                      r.isFavorite ? Theme.of(context).colorScheme.error : null,
                ),
                tooltip:
                    r.isFavorite ? 'Remove from favourites' : 'Add to favourites',
                onPressed: () => store.toggleFavorite(id),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () => context.go('/edit/$id'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Meta info chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Chip(
                    avatar: const Icon(Icons.timer_outlined, size: 16),
                    label: Text('${r.prepMinutes} min'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.people_outline, size: 16),
                    label: Text('${r.servings} servings'),
                  ),
                  Chip(
                    avatar: Icon(Icons.circle,
                        size: 12, color: _difficultyColor(r.difficulty)),
                    label: Text(r.difficulty),
                  ),
                  ...r.tags.map((t) => Chip(label: Text(t))),
                ],
              ),

              const SizedBox(height: 24),

              // Ingredients
              if (r.ingredients.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.list_alt_outlined,
                  title: 'Ingredients',
                  badge: '${r.ingredients.length} items',
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Column(
                      children: r.ingredients.map((ing) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(Icons.fiber_manual_record,
                                  size: 8,
                                  color:
                                      Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(ing,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Instructions
              _SectionHeader(
                icon: Icons.notes_outlined,
                title: 'Instructions',
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    r.notes.isEmpty ? 'No instructions added.' : r.notes,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;

  const _SectionHeader({required this.icon, required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Chip(
            label: Text(badge!, style: const TextStyle(fontSize: 11)),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ],
    );
  }
}
