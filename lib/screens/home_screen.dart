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

  @override
  Widget build(BuildContext context) {
    final store = RecipeStore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Reseptit')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Lisää resepti'),
      ),
      body: Column(
        children: [
          // 🔍 Hakupalkki (Search Bar)
          Padding(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
  child: Row(
    children: [
      // 🔍 Hakukenttä
      Expanded(
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Etsi reseptejä...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              query = value.toLowerCase();
            });
          },
        ),
      ),

      const SizedBox(width: 12),

      // ➕ Pyöreä lisäyspainike (FAB small)
      FloatingActionButton.small(
        onPressed: () => context.go('/add'),
        heroTag: 'add_recipe_small',
        child: const Icon(Icons.add),
      ),
    ],
  ),
),
          // 🔽 Reseptilista (suodatettuna)
          Expanded(
            child: ValueListenableBuilder<List<Recipe>>(
              valueListenable: store.recipes,
              builder: (context, list, _) {
                // Suodatus logiikka
                final filtered = list.where((r) {
                  final title = r.title.toLowerCase();
                  final tags = r.tags.join(',').toLowerCase();
                  final ingredients =
                      r.ingredients.join(',').toLowerCase();
                  return title.contains(query) ||
                      tags.contains(query) ||
                      ingredients.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Ei reseptejä tai hakutuloksia.'),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = filtered[i];
                    return ListTile(
                      title: Text(r.title),
                      subtitle: Text('${r.prepMinutes} min • ${r.tags.join(', ')}'),
                      onTap: () => context.go('/recipe/${r.id}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => store.remove(r.id),
                        tooltip: 'Poista',
                      ),
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