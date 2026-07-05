import 'package:flutter/material.dart';
import 'dart:io';

import 'package:what2eat/models/dish.dart';

class DishesPage extends StatefulWidget {
  final List<Dish> dishes;
  final Function(Dish) onTap;
  final Function(Dish) onDelete;
  final Function(Dish) onEdit;
  final Future<bool> Function(Dish) onConfirmDelete;
  final VoidCallback onAdd;
  final List<String> allTags;
  final Set<String> activeTags;
  final ValueChanged<String> onTagToggled;
  final bool isSearchVisible;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;

  const DishesPage({
    super.key,
    required this.dishes,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.onConfirmDelete,
    required this.onAdd,
    required this.allTags,
    required this.activeTags,
    required this.onTagToggled,
    required this.isSearchVisible,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchCleared,
  });

  @override
  State<DishesPage> createState() => _DishesPageState();
}

class _DishesPageState extends State<DishesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void didUpdateWidget(covariant DishesPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
      _searchController.selection = TextSelection.collapsed(
        offset: _searchController.text.length,
      );
    }

    if (widget.isSearchVisible && !oldWidget.isSearchVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _matchesSearch(Dish dish, String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    final searchableText = [
      dish.title,
      dish.description,
      ...dish.tags,
    ].join(' ').toLowerCase();

    return searchableText.contains(lowerQuery);
  }

  @override
  Widget build(BuildContext context) {
    final trimmedSearchQuery = widget.searchQuery.trim();
    final filteredDishes = widget.dishes.where((dish) {
      final matchesTags = widget.activeTags.isEmpty ||
          widget.activeTags.every((tag) => dish.tags.contains(tag));
      final matchesSearch = _matchesSearch(dish, trimmedSearchQuery);

      return matchesTags && matchesSearch;
    }).toList();

    final hasActiveFilter = widget.activeTags.isNotEmpty ||
        trimmedSearchQuery.isNotEmpty;

    return Stack(
      children: [
        Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: widget.isSearchVisible
                  ? Padding(
                      key: const ValueKey('dish-search-field'),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Gericht suchen...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: trimmedSearchQuery.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Suche löschen',
                                  icon: const Icon(Icons.clear),
                                  onPressed: widget.onSearchCleared,
                                ),
                        ),
                        onChanged: widget.onSearchChanged,
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('dish-search-hidden'),
                    ),
            ),
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  const SizedBox(width: 4),
                  FilterChip(
                    label: const Text('Alle'),
                    selected: widget.activeTags.isEmpty,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) {
                      widget.onTagToggled('__clear__');
                    },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  ...widget.allTags.map((tag) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(tag),
                        selected: widget.activeTags.contains(tag),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (selected) {
                          widget.onTagToggled(tag);
                        },
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: filteredDishes.isEmpty
                  ? Center(
                      child: Text(
                        hasActiveFilter
                            ? 'Keine passenden Gerichte gefunden.'
                            : 'Keine Gerichte vorhanden. \nTippe auf +, um eins hinzuzufügen.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 0,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: filteredDishes.length,
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 80,
                      ),
                      itemBuilder: (context, index) {
                        final dish = filteredDishes[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => widget.onTap(dish),
                          child: Card(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : const Color.fromARGB(255, 50, 50, 60),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: (dish.localImagePath != null &&
                                          File(dish.localImagePath!)
                                              .existsSync())
                                      ? ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                          child: Image.file(
                                            File(dish.localImagePath!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                          child: Image.network(
                                            dish.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) =>
                                                Container(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.white
                                                  : const Color.fromARGB(
                                                      255,
                                                      50,
                                                      50,
                                                      60,
                                                    ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.black
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .surface,
                                                  size: 60,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      right: 12,
                                      left: 12,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      dish.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Colors.black
                                                : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: SizedBox(
            width: 60,
            height: 60,
            child: FloatingActionButton(
              onPressed: () => widget.onAdd(),
              shape: const CircleBorder(),
              child: Icon(
                Icons.add,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
                size: 36,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
