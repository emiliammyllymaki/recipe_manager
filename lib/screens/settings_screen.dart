import 'package:flutter/material.dart';
import '../data/recipe_store.dart';

// Use StatefulWidget + ListenableBuilder so the UI rebuilds when store changes
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          _SectionTitle(title: 'Cover'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _store.darkMode,
                  title: const Text('Dark mode'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  onChanged: (v) => _store.setDarkMode(v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Layout section
          _SectionTitle(title: 'Padding'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.width_normal_outlined),
                    title: const Text('Max width'),
                    subtitle:
                        Text('${_store.maxContentWidth.toInt()} px'),
                  ),
                  Slider(
                    min: 600,
                    max: 1400,
                    divisions: 16,
                    value: _store.maxContentWidth,
                    label: '${_store.maxContentWidth.toInt()} px',
                    onChanged: (v) => _store.setMaxWidth(v),
                  ),
                  Text(
                    'Limits the width of displayed content on large screens.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // About section
          _SectionTitle(title: 'About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  trailing: const Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Recipe manager'),
                  trailing: const Text('Recipebook'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
