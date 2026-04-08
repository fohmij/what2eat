import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what2eat/pages/dishes_page.dart';
import 'package:what2eat/pages/swipe_page.dart';
import 'package:what2eat/pages/settings_page.dart';
import 'package:what2eat/models/dish.dart';
import 'package:what2eat/theme/app_theme.dart';

class What2EatApp extends StatefulWidget {
  const What2EatApp({super.key});

  @override
  State<What2EatApp> createState() => _What2EatAppState();
}

class _What2EatAppState extends State<What2EatApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 🔥 hinzufügen
      title: 'What2Eat',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: MetaHomePage(
        themeMode: _themeMode,
        onThemeModeChanged: _updateThemeMode,
      ),
    );
  }
}

class MetaHomePage extends StatefulWidget {
  const MetaHomePage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<MetaHomePage> createState() => _MetaHomePageState();
}

class _MetaHomePageState extends State<MetaHomePage> {
  static const String _storageKey = 'saved_dishes';

  final ImagePicker _picker = ImagePicker();
  final List<Dish> _dishes = [];
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _allTags = [];
  final Set<String> _selectedTags = {};

  String? _selectedImagePath;
  Dish? _editingDish;
  bool _isEditing = false;
  int _selectedIndex = 0;
  int _swipeIndex = 0;
  bool _isSwipeCardFlipped = false;
  double _swipeVerticalOffset = 0.0;
  bool _isRejecting = false;
  final Set<String> _activeTags = {};

  bool get isOnSwipePage => _selectedIndex == 1;
  bool get _hasMoreCards => _swipeIndex < _dishes.length;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadDishes();
  }

  Future<void> _loadDishes() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final stored = prefs.getStringList(_storageKey);
    if (stored != null) {
      final savedDishes = stored
          .map(
            (jsonString) =>
                Dish.fromJson(jsonDecode(jsonString) as Map<String, dynamic>),
          )
          .toList();
      setState(() {
        _dishes
          ..clear()
          ..addAll(savedDishes);
        _swipeIndex = 0;
      });
    } else {
      setState(() {
        _dishes.addAll([
          Dish(
            id: '1',
            title: 'Caprese-Salat',
            description:
                'Frischer Mozzarella, Tomaten und Basilikum mit Olivenöl.',
            imageUrl: 'https://loremflickr.com/800/600/caprese-salad',
          ),
          Dish(
            id: '2',
            title: 'Pasta al Pomodoro',
            description: 'Klassische Pasta mit Tomatensauce und Parmesan.',
            imageUrl: 'https://loremflickr.com/800/600/pasta',
          ),
          Dish(
            id: '3',
            title: 'Avocado-Bowl',
            description:
                'Sättigende Bowl mit Avocado, Quinoa und knackigem Gemüse.',
            imageUrl: 'https://loremflickr.com/800/600/avocado-bowl',
          ),
        ]);
      });
      await _saveDishes();
    }
    _extractTags();
  }

  Future<void> _saveDishes() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = _dishes
        .map((dish) => jsonEncode(dish.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, stringList);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(
    ImageSource source,
    void Function(void Function()) setModalState,
  ) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (picked != null) {
      setModalState(() {
        _selectedImagePath = picked.path;
        _imageUrlController.clear();
      });
    }
  }

  void _prepareDishForm([Dish? dish]) {
    _editingDish = dish;
    _isEditing = dish != null;
    if (dish != null) {
      _titleController.text = dish.title;
      _imageUrlController.text = dish.localImagePath == null
          ? dish.imageUrl
          : '';
      _descriptionController.text = dish.description;
      _selectedImagePath = dish.localImagePath;
      _selectedTags.addAll(dish.tags);
    } else {
      _titleController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      _selectedImagePath = null;
    }
  }

  Future<void> _showDishDialog([Dish? dish]) async {
    _prepareDishForm(dish);
    await showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: _buildAddDishForm(setModalState),
              ),
            );
          },
        );
      },
    );
    if (mounted) {
      setState(() {
        _isEditing = false;
        _editingDish = null;
        _prepareDishForm();
      });
    }
  }

  Future<void> _saveDish() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final imageUrl = _selectedImagePath != null
        ? ''
        : _imageUrlController.text.trim();

    final dish = Dish(
      id: _editingDish?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.trim(),
      imageUrl: imageUrl,
      localImagePath: _selectedImagePath,
      tags: _selectedTags.toList(),
    );

    setState(() {
      if (_isEditing && _editingDish != null) {
        final index = _dishes.indexWhere(
          (element) => element.id == _editingDish!.id,
        );
        if (index != -1) {
          _dishes[index] = dish;
        }
      } else {
        _dishes.insert(0, dish);
      }
      _selectedImagePath = null;
      _titleController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      _swipeIndex = 0;
    });

    await _saveDishes();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? 'Gericht aktualisiert' : 'Gericht gespeichert',
        ),
      ),
    );
    Navigator.of(context).pop();

    _extractTags();
  }

  Future<bool> _confirmDelete(Dish dish) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Löschen bestätigen'),
              content: Text(
                'Soll das Gericht "${dish.title}" wirklich gelöscht werden?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Löschen'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _removeDish(Dish dish) async {
    setState(() {
      _dishes.remove(dish);
      if (_swipeIndex > _dishes.length) {
        _swipeIndex = _dishes.length;
      }
      _swipeIndex = _swipeIndex.clamp(
        0,
        _dishes.isEmpty ? 0 : _dishes.length - 1,
      );
    });
    await _saveDishes();
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Gericht gelöscht: ${dish.title}')));
  }

  Future<void> _showDishDetail(Dish dish) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Container(
                  height: 4,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey
                        : const Color.fromARGB(255, 75, 75, 75),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                dish.title,
                style: TextStyle(
                  fontSize: 24,
                  // fontWeight: FontWeight.w400
                ),
              ),
              Divider(
                height: 16,
                thickness: 1,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey
                    : const Color.fromARGB(255, 75, 75, 75),
              ),
              if (dish.tags.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dish.tags.map((tag) {
                      return Chip(
                        backgroundColor: Color.fromARGB(
                          255,
                          0,
                          255,
                          8,
                        ).withAlpha(70),
                        label: Text(tag),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                const SizedBox(height: 12),
              ],
              if (dish.localImagePath != null &&
                  File(dish.localImagePath!).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(dish.localImagePath!),
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    dish.imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220,
                      color: 
                                                          Theme.of( context,).brightness == Brightness.light
                                                          ? Colors.white
                                                          : Theme.of(context).colorScheme.surface,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 60),
                      ),
                    ),
                  ),
                ),
              if (dish.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  dish.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final confirmed = await _confirmDelete(dish);
                        if (confirmed) {
                          navigator.pop();
                          await _removeDish(dish);
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Löschen'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showDishDialog(dish);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Bearbeiten'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 72),
            ],
          ),
        );
      },
    );
  }

  bool _isRejectAnimationRunning = false;

  void _rejectSwipe({bool animate = false}) {
    if (!_hasMoreCards || _isRejectAnimationRunning) return;

    if (animate) {
      _isRejectAnimationRunning = true;
      setState(() {
        _swipeVerticalOffset = -MediaQuery.of(context).size.height;
        _isRejecting = true;
      });
      Future.delayed(const Duration(milliseconds: 260), () {
        if (!mounted) return;
        setState(() {
          _swipeIndex = (_swipeIndex + 1).clamp(0, _dishes.length);
          _isSwipeCardFlipped = false;
          _swipeVerticalOffset = 0.0;
          _isRejecting = false;
          _isRejectAnimationRunning = false;
        });
      });
      return;
    }

    setState(() {
      _swipeIndex = (_swipeIndex + 1).clamp(0, _dishes.length);
      _isSwipeCardFlipped = false;
      _swipeVerticalOffset = 0.0;
      _isRejecting = false;
    });
  }

  Future<void> _resetSwipeStack() async {
    setState(() {
      _swipeIndex = 0;
      _isSwipeCardFlipped = false;
      _swipeVerticalOffset = 0;
      _isRejecting = false;
    });
  }

  void _extractTags() {
    final tags = <String>{};
    for (final dish in _dishes) {
      tags.addAll(dish.tags);
    }

    setState(() {
      _allTags
        ..clear()
        ..addAll(tags);
    });
    _allTags
      ..clear()
      ..addAll(tags.toList()..sort());
  }

  Future<void> _showAddTagDialog(
    void Function(void Function()) setModalState,
  ) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Neuer Tag'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Tag eingeben...'),
            onSubmitted: (value) {
              Navigator.pop(context, value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    final tag = result.trim();
    if (tag.isEmpty) return;

    setModalState(() {
      if (!_allTags.contains(tag)) {
        _allTags.add(tag);
      }
      _selectedTags.add(tag);
    });
  }

  Future<bool> _confirmDeleteTag(String tag) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('"$tag" löschen'),
            content: Text('Möchtest du den Tag "$tag" wirklich löschen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Löschen'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildAddDishForm(void Function(void Function()) setModalState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Container(
                height: 4,
                width: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey
                      : const Color.fromARGB(255, 75, 75, 75),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              _isEditing ? 'Gericht bearbeiten' : 'Neues Gericht',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
            Divider(
              height: 16,
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color.fromARGB(255, 202, 202, 202)
                  : const Color.fromARGB(255, 65, 65, 65),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._allTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);

                    return GestureDetector(
                      onLongPress: () async {
                        final confirm = await _confirmDeleteTag(tag);
                        if (!confirm) return;

                        setModalState(() {
                          _allTags.remove(tag);
                          _selectedTags.remove(tag);
                        });
                      },
                      child: FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        showCheckmark: false,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                      ),
                    );
                  }),

                  ActionChip(
                    label: Icon(
                      Icons.add,
                      color: Color.fromARGB(255, 41, 95, 44),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                    onPressed: () {
                      _showAddTagDialog(setModalState);
                    },
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedImagePath != null ||
                _imageUrlController.text.trim().isNotEmpty)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _selectedImagePath != null
                        ? Image.file(
                            File(_selectedImagePath!),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            _imageUrlController.text.trim(),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 60),
                                  ),
                                ),
                          ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            const SizedBox(width: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Titel',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bitte gib einen Titel ein.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<ImageSource>(
                  onSelected: (source) {
                    _pickImage(source, setModalState);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 100, 100, 100),
                      width: 1,
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: ImageSource.gallery,
                      child: Row(
                        children: const [
                          Icon(Icons.photo_library, color: Colors.grey),
                          SizedBox(width: 12),
                          Text('Galerie'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: ImageSource.camera,
                      child: Row(
                        children: const [
                          Icon(Icons.camera_alt, color: Colors.grey),
                          SizedBox(width: 12),
                          Text('Kamera'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color.fromARGB(255, 202, 202, 202)
                          : const Color.fromARGB(255, 65, 65, 65),
                    ),
                    child: IconButton(
                      onPressed: null,
                      icon: const Icon(
                        Icons.add_a_photo_outlined,
                        color: Colors.white,
                      ),
                      color: Colors.grey,
                      highlightColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Beschreibung (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.transparent,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.withAlpha(150)
                      : Colors.grey.withAlpha(50),
                ),
              ),
              child: IconButton(
                onPressed: _saveDish,
                icon: const Icon(Icons.save),
                color: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary,
                iconSize: 28,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.withAlpha(80), width: 0.5),
              ),
            ),
            child: NavigationBar(
              backgroundColor: isLight
                  ? Colors.white
                  // : const Color.fromARGB(255, 50, 50, 60),
                  : Colors.transparent,
              indicatorColor: isOnSwipePage
                  ? Colors.transparent
                  : (isLight
                        ? Color.fromARGB(255, 0, 255, 8).withAlpha(70)
                        : Color.fromARGB(40, 100, 255, 0)),
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index == 1 ? 2 : 0;
                });
              },
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.list),
                  selectedIcon: Icon(
                    Icons.list,
                    color: isLight
                        ? Theme.of(context).colorScheme.primary.withGreen(100)
                        : Colors.white,
                  ),
                  label: 'Gerichte',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(
                    Icons.settings,
                    color: isLight
                        ? Theme.of(context).colorScheme.primary.withGreen(100)
                        : Colors.white,
                  ),
                  label: 'Einstellungen',
                ),
              ],
              selectedIndex: _selectedIndex == 2 ? 1 : 0,
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -35,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      color: isLight
                          ? Colors.white
                          : Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -24,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_selectedIndex == 1) {
                        // 🔥 schon auf Swipe → reset
                        _resetSwipeStack();
                      } else {
                        // 🔄 wechseln zur Swipe-Seite
                        setState(() => _selectedIndex = 1);
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        // color: Theme.of(context).colorScheme.primary,
                        border: Border.all(
                          color: !isOnSwipePage
                              ? Colors.grey.withAlpha(80)
                              : Colors.transparent,
                        ),
                        color: !isOnSwipePage
                            ? (isLight
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.surface)
                            : (isLight
                                  ? Theme.of(context).colorScheme.primary
                                  // ? Color.fromARGB(255, 185, 255, 187)
                                  : Color.fromARGB(40, 100, 255, 0)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isOnSwipePage
                            ? Icons.swipe_vertical
                            : Icons.swipe_vertical_outlined,
                        size: 28,
                        color: !isOnSwipePage
                            ? (isLight ? Colors.black : Colors.white)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDishes = _activeTags.isEmpty
    ? _dishes
    : _dishes.where((dish) {
        return _activeTags.every((tag) => dish.tags.contains(tag));
      }).toList();

    final pages = <Widget>[
      DishesPage(
        dishes: _dishes,
        onTap: _showDishDetail,
        onDelete: _removeDish,
        onEdit: _showDishDialog,
        onConfirmDelete: _confirmDelete,
        onAdd: () => _showDishDialog(),
        allTags: _allTags,
        activeTags: _activeTags,
        onTagToggled: (tag) {
          setState(() {
            if (tag == '__clear__') {
              _activeTags.clear();
              return;
            }

            if (_activeTags.contains(tag)) {
              _activeTags.remove(tag);
            } else {
              _activeTags.add(tag);
            }
          });
        },
      ),
      SwipePage(
        dishes: filteredDishes, // 👈 wie oben
        allTags: _allTags,
        activeTags: _activeTags,
        onTagToggled: (tag) {
          setState(() {
            _swipeIndex = 0;
            if (tag == '__clear__') {
              _activeTags.clear();
            } else if (_activeTags.contains(tag)) {
              _activeTags.remove(tag);
            } else {
              _activeTags.add(tag);
            }
          });
        },
        swipeIndex: _swipeIndex,
        isSwipeCardFlipped: _isSwipeCardFlipped,
        swipeVerticalOffset: _swipeVerticalOffset,
        isRejecting: _isRejecting,
        onReset: _resetSwipeStack,
        onRejectSwipe: _rejectSwipe,
        onFlipCard: () {
          setState(() {
            _isSwipeCardFlipped = !_isSwipeCardFlipped;
          });
        },
        onVerticalDragUpdate: (delta) {
          setState(() {
            _swipeVerticalOffset += delta;
            _isRejecting = _swipeVerticalOffset < -20;
          });
        },
        onVerticalDragEnd: (details) {
          setState(() {
            _swipeVerticalOffset = 0;
            _isRejecting = false;
          });
        },
        onVerticalDragCancel: () {
          setState(() {
            _swipeVerticalOffset = 0;
            _isRejecting = false;
          });
        },
      ),
      SettingsPage(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        dishCount: _dishes.length,
        swipeIndex: _swipeIndex,
        hasMoreCards: _swipeIndex < _dishes.length,
      ),
    ];

    final titles = ['Gerichte', 'Swipen', 'Einstellungen'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_selectedIndex],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        surfaceTintColor: Theme.of(context).brightness == Brightness.light
            ? const Color.fromARGB(255, 210, 214, 211)
            : const Color.fromARGB(255, 50, 50, 60),
        centerTitle: false,
        flexibleSpace: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedIndex = 0),
                splashColor: Colors.white24,
                highlightColor: Colors.transparent,
                child: Container(color: Colors.transparent),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedIndex = 2),
                splashColor: Colors.white24,
                highlightColor: Colors.transparent,
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}
