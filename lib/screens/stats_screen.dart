import 'package:flutter/material.dart';
import '../data/recipe_store.dart';
import '../models/recipe.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ValueListenableBuilder<List<Recipe>>(
        valueListenable: RecipeStore.instance.recipes,
        builder: (context, list, _) {
          return _StatsBody(recipes: list);
        },
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  final List<Recipe> recipes;
  const _StatsBody({required this.recipes});

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_outlined,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    ..withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('Add recipes to see the statistics'),
          ],
        ),
      );
    }

    final count = recipes.length;
    final totalTime =
        recipes.fold(0, (sum, r) => sum + r.prepMinutes);
    final avgTime = (totalTime / count).round();
    final maxTime =
        recipes.map((r) => r.prepMinutes).reduce((a, b) => a > b ? a : b);
    final minTime =
        recipes.map((r) => r.prepMinutes).reduce((a, b) => a < b ? a : b);
    final favCount = recipes.where((r) => r.isFavorite).length;

    // Category counts
    final catCounts = <String, int>{};
    for (final r in recipes) {
      for (final t in r.tags) {
        catCounts[t] = (catCounts[t] ?? 0) + 1;
      }
    }
    final sortedCats = catCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Prep-time distribution buckets
    final buckets = {
      '≤15 min': 0,
      '16–30 min': 0,
      '31–60 min': 0,
      '>60 min': 0,
    };
    for (final r in recipes) {
      if (r.prepMinutes <= 15) {
        buckets['≤15 min'] = buckets['≤15 min']! + 1;
      } else if (r.prepMinutes <= 30) {
        buckets['16–30 min'] = buckets['16–30 min']! + 1;
      } else if (r.prepMinutes <= 60) {
        buckets['31–60 min'] = buckets['31–60 min']! + 1;
      } else {
        buckets['>60 min'] = buckets['>60 min']! + 1;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                  icon: Icons.menu_book,
                  title: 'Recipes',
                  value: '$count',
                  color: Colors.teal),
              _StatCard(
                  icon: Icons.timer_outlined,
                  title: 'Avergae time',
                  value: '$avgTime min',
                  color: Colors.blue),
              _StatCard(
                  icon: Icons.favorite,
                  title: 'Favourites',
                  value: '$favCount',
                  color: Colors.red),
              _StatCard(
                  icon: Icons.flash_on,
                  title: 'Min time',
                  value: '$minTime min',
                  color: Colors.green),
              _StatCard(
                  icon: Icons.hourglass_bottom,
                  title: 'Max time',
                  value: '$maxTime min',
                  color: Colors.orange),
            ],
          ),

          const SizedBox(height: 28),

          // Category bar chart
          if (sortedCats.isNotEmpty) ...[
            Text('Kategoriat',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: sortedCats.take(8).map((entry) {
                    final pct = entry.value / count;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text('${entry.value}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 10,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],

          // Prep-time distribution
          Text('Preparation time',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: buckets.entries.map((entry) {
                  final pct = count == 0 ? 0.0 : entry.value / count;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text('${entry.value} recipe',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 10,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Top recipes by ingredient count
          if (recipes.isNotEmpty) ...[
            Text('Eniten aineksia',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: ([...recipes]
                      ..sort((a, b) => b.ingredients.length
                          .compareTo(a.ingredients.length)))
                    .take(5)
                    .map((r) => ListTile(
                          leading: CircleAvatar(
                              child: Text('${r.ingredients.length}')),
                          title: Text(r.title),
                          subtitle: Text('${r.prepMinutes} min'),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(title,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
