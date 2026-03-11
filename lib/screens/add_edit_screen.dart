import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/recipe_store.dart';
import '../models/recipe.dart';

class AddEditScreen extends StatefulWidget {
  final String? id;
  const AddEditScreen({super.key, this.id});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _prepCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  static const _categories = ['Savoury', 'Sweet', 'Snack', 'Drink'];
  static const _difficulties = ['Easy', 'Medium', 'Hard'];

  String? _selectedCategory;
  String _selectedDifficulty = 'Easy';

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      final r = RecipeStore.instance.byId(widget.id!);
      if (r != null) {
        _titleCtrl.text = r.title;
        _prepCtrl.text = r.prepMinutes.toString();
        _servingsCtrl.text = r.servings.toString();
        _ingredientsCtrl.text = r.ingredients.join('\n');
        _tagsCtrl.text =
            r.tags.where((t) => !_categories.contains(t)).join(', ');
        _notesCtrl.text = r.notes;
        _selectedDifficulty = r.difficulty;
        for (final c in _categories) {
          if (r.tags.contains(c)) {
            _selectedCategory = c;
            break;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _prepCtrl.dispose();
    _servingsCtrl.dispose();
    _ingredientsCtrl.dispose();
    _tagsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Recipe' : 'New Recipe'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Recipe Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              validator: (v) => v == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // Difficulty
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.signal_cellular_alt_outlined),
              ),
              items: _difficulties
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedDifficulty = v!),
            ),
            const SizedBox(height: 16),

            // Prep time + servings
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Prep time (min) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 0) return 'Enter minutes';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _servingsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Servings *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1) return 'Enter servings';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ingredients
            TextFormField(
              controller: _ingredientsCtrl,
              decoration: const InputDecoration(
                labelText: 'Ingredients (one per line)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.list_alt_outlined),
                alignLabelWithHint: true,
                hintText: '2 cups flour\n1 tsp salt\n...',
              ),
              maxLines: 7,
              minLines: 4,
            ),
            const SizedBox(height: 16),

            // Extra tags
            TextFormField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(
                labelText: 'Extra tags (comma separated)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
                hintText: 'e.g. gluten-free, vegan, quick',
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
                hintText: 'Step 1: ...\nStep 2: ...',
              ),
              maxLines: 10,
              minLines: 5,
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(isEdit ? 'Save Changes' : 'Create Recipe'),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final store = RecipeStore.instance;
    final isEdit = widget.id != null;

    final base =
        isEdit ? (store.byId(widget.id!) ?? Recipe.newRecipe()) : Recipe.newRecipe();

    base
      ..title = _titleCtrl.text.trim()
      ..prepMinutes = int.parse(_prepCtrl.text)
      ..servings = int.parse(_servingsCtrl.text)
      ..difficulty = _selectedDifficulty
      ..ingredients = _ingredientsCtrl.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList()
      ..tags = [
        if (_selectedCategory != null) _selectedCategory!,
        ..._tagsCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      ]
      ..notes = _notesCtrl.text.trim();

    await store.addOrUpdate(base);
    if (mounted) context.go('/recipe/${base.id}');
  }
}
