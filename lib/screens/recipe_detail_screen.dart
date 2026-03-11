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
        title: const Text('Delete recipe'),
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
                  color: r.isFavorite
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
                tooltip: r.isFavorite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: () => store.toggleFavorite(id),
              ),
              IconButton(
                onPressed: () => context.go('/edit/$id'),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Meta chips
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _MetaChip(
                      icon: Icons.timer_outlined,
                      label: '${r.prepMinutes} min'),
                  _MetaChip(
                      icon: Icons.people_outline,
                      label: '${r.servings} servings'),
                  ...r.tags.map((t) => Chip(label: Text(t))),
                ],
              ),

              const SizedBox(height: 24),

              // Ingredients section
              if (r.ingredients.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.list_alt_outlined,
                  title: 'Ingredients',
                  subtitle: '${r.ingredients.length} ingredients',
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Column(
                      children: r.ingredients
                          .map((ing) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Icon(Icons.circle,
                                        size: 8,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(ing)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Instructions section
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
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _SectionHeader(
      {required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(subtitle!,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}
