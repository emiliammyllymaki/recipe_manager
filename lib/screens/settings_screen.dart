import 'package:flutter/material.dart';
import '../data/recipe_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RecipeStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Asetukset')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: store.darkMode,
            title: const Text('Tumma tila'),
            onChanged: (v) => store.setDarkMode(v),
          ),
          const SizedBox(height: 8),
          Text('Sisällön maksimileveys: ${store.maxContentWidth.toInt()} px'),
          Slider(
            min: 800, max: 1200, divisions: 8,
            value: store.maxContentWidth,
            label: '${store.maxContentWidth.toInt()}',
            onChanged: (v) => store.setMaxWidth(v),
          ),
          const SizedBox(height: 12),
          const Text(
            'Huom: maksimileveyden asetus rajoittaa sisällön leveyttä '
            'suurilla näytöillä (vaatimus).',
          ),
        ],
      ),
    );
  }
}