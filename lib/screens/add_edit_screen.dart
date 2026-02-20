import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/recipe_store.dart';
import '../models/recipe.dart';

class AddEditScreen extends StatefulWidget {
  final String? id; // null -> uusi
  const AddEditScreen({super.key, this.id});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _prep = TextEditingController();
  final _ingredients = TextEditingController();
  final _tags = TextEditingController();
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    final store = RecipeStore.instance;
    if (widget.id != null) {
      final r = store.byId(widget.id!);
      if (r != null) {
        _title.text = r.title;
        _prep.text = r.prepMinutes.toString();
        _ingredients.text = r.ingredients.join('\n');
        _tags.text = r.tags.join(',');
        _notes.text = r.notes;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Muokkaa reseptiä' : 'Uusi resepti')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Otsikko'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Anna otsikko'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _prep,
              decoration: const InputDecoration(
                labelText: 'Valmistusaika (min)',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 0) return 'Anna minuutit numerona';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ingredients,
              decoration: const InputDecoration(
                labelText: 'Ainekset (yksi per rivi)',
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tags,
              decoration:
                  const InputDecoration(labelText: 'Tagit (pilkuin eroteltu)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Ohjeet / muistiinpanot'),
              maxLines: 6,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final store = RecipeStore.instance;
                final recipe = (isEdit
                        ? store.byId(widget.id!) ?? Recipe.newRecipe()
                        : Recipe.newRecipe())
                    ..title = _title.text.trim()
                    ..prepMinutes = int.parse(_prep.text)
                    ..ingredients = _ingredients.text
                        .split('\n')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList()
                    ..tags = _tags.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList()
                    ..notes = _notes.text.trim();

                await store.addOrUpdate(recipe);
                if (context.mounted) context.go('/recipe/${recipe.id}');
              },
              icon: const Icon(Icons.check),
              label: Text(isEdit ? 'Tallenna' : 'Luo resepti'),
            ),
          ],
        ),
      ),
    );
  }
}