import 'package:flutter/material.dart';
import '../data/recipe_store.dart';
import '../models/recipe.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RecipeStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Tilastot')),
      body: ValueListenableBuilder<List<Recipe>>(
        valueListenable: store.recipes,
        builder: (context, list, _) {
          final count = list.length;
          final avg = count == 0
              ? 0
              : (list.map((e) => e.prepMinutes).reduce((a, b) => a + b) / count)
                  .round();
          final tagCounts = <String, int>{};
          for (final r in list) {
            for (final t in r.tags) {
              tagCounts[t] = (tagCounts[t] ?? 0) + 1;
            }
          }
          final topTags = tagCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(title: 'Reseptejä', value: '$count'),
                _StatCard(title: 'Keskim. aika', value: '$avg min'),
                _StatCard(
                  title: 'Suosituimmat tagit',
                  value: topTags.isEmpty
                      ? '—'
                      : topTags.take(3).map((e) => '${e.key} (${e.value})').join(', '),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 280,
        height: 120,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(value,
                  style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }
}