import 'package:flutter/material.dart';
import '../data/recipe_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _store = RecipeStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_rebuild);
  }

  @override
  void dispose() {
    _store.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_outlined),
        title: const Text('Clear All Recipes'),
        content: const Text(
            'This will permanently delete all your recipes. This cannot be undone.'),
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
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ids = [..._store.recipes.value.map((r) => r.id)];
      for (final id in ids) {
        await _store.remove(id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeCount = _store.recipes.value.length;
    final favCount = _store.recipes.value.where((r) => r.isFavorite).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance
          _SectionLabel('Appearance'),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark theme'),
              value: _store.darkMode,
              onChanged: (v) => _store.setDarkMode(v),
            ),
          ),

          const SizedBox(height: 20),

          // Data summary
          _SectionLabel('Your Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Total Recipes'),
                  trailing: Text(
                    '$recipeCount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text('Favourites'),
                  trailing: Text(
                    '$favCount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.delete_forever_outlined,
                      color: Theme.of(context).colorScheme.error),
                  title: Text('Clear All Recipes',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                  subtitle: const Text('Permanently delete all recipes'),
                  onTap: recipeCount == 0
                      ? null
                      : () => _confirmClearAll(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // About
          _SectionLabel('About'),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.restaurant_menu),
                  title: Text('Recipe Manager'),
                  subtitle: Text('Your personal recipe collection'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  trailing: Text('1.0.0'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.devices_outlined),
                  title: Text('Platform'),
                  trailing: Text('Web / Flutter'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
