import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/recipe_store.dart';
import '../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String id;
  const RecipeDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final store = RecipeStore.instance;
    final Recipe? r = store.byId(id);

    if (r == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resepti')),
        body: const Center(child: Text('Reseptiä ei löytynyt')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(r.title),
        actions: [
          IconButton(
            onPressed: () => context.go('/edit/$id'),
            icon: const Icon(Icons.edit),
            tooltip: 'Muokkaa',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('${r.prepMinutes} min')),
              ...r.tags.map((t) => Chip(label: Text(t))),
            ],
          ),
          const SizedBox(height: 20),

          const Text('Ainekset', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...r.ingredients.map((i) => Text('• $i')),
          const SizedBox(height: 20),

          const Text('Ohjeet', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(r.notes.isEmpty ? '—' : r.notes),
        ],
      ),
    );
  }
}
