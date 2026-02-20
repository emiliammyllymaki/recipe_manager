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
  String selectedCategory = 'Kaikki';

  final List<String> categories = [
    'Kaikki',
    'Suolainen',
    'Makea',
    'Välipala',
    'Juoma',
  ];

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
          // 🔍 Hakupalkki
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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

          // 🔽 Kategoria-suodatin (FilterChipit)
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
                    onSelected: (_) {
                      setState(() => selectedCategory = c);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // 🔽 Reseptilista (kortit)
          Expanded(
            child: ValueListenableBuilder<List<Recipe>>(
              valueListenable: store.recipes,
              builder: (context, list, _) {
                // Suodatus
                final filtered = list.where((r) {
                  final title = r.title.toLowerCase();
                  final tags = r.tags.join(',').toLowerCase();
                  final ingredients = r.ingredients.join(',').toLowerCase();

                  final matchesQuery =
                      title.contains(query) ||
                      tags.contains(query) ||
                      ingredients.contains(query);

                  final matchesCategory =
                      selectedCategory == 'Kaikki' ||
                      r.tags.contains(selectedCategory);

                  return matchesQuery && matchesCategory;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Ei reseptejä tai hakutuloksia.'),
                  );
                }

                // 📱 Responsiivinen sarakemäärä
                final width = MediaQuery.of(context).size.width;
                int columns = 1;
                if (width > 600) columns = 2;
                if (width > 900) columns = 3;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final r = filtered[i];

                    return GestureDetector(
                      onTap: () => context.go('/recipe/${r.id}'),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.title,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${r.prepMinutes} min',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                children: r.tags
                                    .map((t) => Chip(
                                          label: Text(t),
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ))
                                    .toList(),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => store.remove(r.id),
                                ),
                              ),
                            ],
                          ),
                        ),
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
