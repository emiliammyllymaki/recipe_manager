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
        builder: (context, recipes, _) {
          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart,
                      size: 72,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.25)),
                  const SizedBox(height: 16),
                  Text('No data yet.',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Add recipes to see statistics.'),
                ],
              ),
            );
          }

          return _StatsBody(recipes: recipes);
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
    final count = recipes.length;
    final favCount = recipes.where((r) => r.isFavorite).length;
    final avgTime =
        (recipes.fold(0, (s, r) => s + r.prepMinutes) / count).round();
    final minTime =
        recipes.map((r) => r.prepMinutes).reduce((a, b) => a < b ? a : b);
    final maxTime =
        recipes.map((r) => r.prepMinutes).reduce((a, b) => a > b ? a : b);

    // Category counts
    final catCounts = <String, int>{};
    for (final r in recipes) {
      for (final t in r.tags) {
        catCounts[t] = (catCounts[t] ?? 0) + 1;
      }
    }
    final sortedCats = catCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Difficulty breakdown
    final diffCounts = <String, int>{
      'Easy': 0,
      'Medium': 0,
      'Hard': 0,
    };
    for (final r in recipes) {
      diffCounts[r.difficulty] = (diffCounts[r.difficulty] ?? 0) + 1;
    }

    // Prep time buckets
    final timeBuckets = {
      '≤ 15 min': 0,
      '16–30 min': 0,
      '31–60 min': 0,
      '> 60 min': 0,
    };
    for (final r in recipes) {
      if (r.prepMinutes <= 15) timeBuckets['≤ 15 min'] = timeBuckets['≤ 15 min']! + 1;
      else if (r.prepMinutes <= 30) timeBuckets['16–30 min'] = timeBuckets['16–30 min']! + 1;
      else if (r.prepMinutes <= 60) timeBuckets['31–60 min'] = timeBuckets['31–60 min']! + 1;
      else timeBuckets['> 60 min'] = timeBuckets['> 60 min']! + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(icon: Icons.menu_book, label: 'Total Recipes', value: '$count', color: Colors.teal),
              _StatCard(icon: Icons.favorite, label: 'Favourites', value: '$favCount', color: Colors.red),
              _StatCard(icon: Icons.timer_outlined, label: 'Avg. Prep Time', value: '$avgTime min', color: Colors.blue),
              _StatCard(icon: Icons.flash_on, label: 'Quickest', value: '$minTime min', color: Colors.green),
              _StatCard(icon: Icons.hourglass_bottom, label: 'Longest', value: '$maxTime min', color: Colors.orange),
            ],
          ),

          const SizedBox(height: 28),

          // Category breakdown
          if (sortedCats.isNotEmpty) ...[
            _SectionTitle('Recipes by Category'),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: sortedCats.take(8).map((e) {
                    return _BarRow(label: e.key, value: e.value, total: count);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Difficulty breakdown
          _SectionTitle('Recipes by Difficulty'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _BarRow(label: 'Easy', value: diffCounts['Easy']!, total: count, color: Colors.green),
                  _BarRow(label: 'Medium', value: diffCounts['Medium']!, total: count, color: Colors.orange),
                  _BarRow(label: 'Hard', value: diffCounts['Hard']!, total: count, color: Colors.red),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Prep time distribution
          _SectionTitle('Preparation Time Distribution'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: timeBuckets.entries.map((e) {
                  return _BarRow(label: e.key, value: e.value, total: count,
                      color: Theme.of(context).colorScheme.secondary);
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Top recipes by ingredients
          _SectionTitle('Most Ingredients'),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: ([...recipes]
                    ..sort((a, b) =>
                        b.ingredients.length.compareTo(a.ingredients.length)))
                  .take(5)
                  .map((r) => ListTile(
                        leading: CircleAvatar(
                          child: Text('${r.ingredients.length}',
                              style: const TextStyle(fontSize: 12)),
                        ),
                        title: Text(r.title),
                        subtitle: Text('${r.prepMinutes} min · ${r.difficulty}'),
                        trailing: r.isFavorite
                            ? const Icon(Icons.favorite, color: Colors.red, size: 16)
                            : null,
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color? color;

  const _BarRow({
    required this.label,
    required this.value,
    required this.total,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : value / total;
    final barColor = color ?? Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text('$value',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              color: barColor,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
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
