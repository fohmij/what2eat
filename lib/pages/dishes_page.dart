import 'package:flutter/material.dart';
import 'dart:io';

import 'package:what2eat/models/dish.dart';

class DishesPage extends StatelessWidget {
  final List<Dish> dishes;
  final Function(Dish) onTap;
  final Function(Dish) onDelete;
  final Function(Dish) onEdit;
  final Future<bool> Function(Dish) onConfirmDelete;
  final VoidCallback onAdd;
  final List<String> allTags;
  final Set<String> activeTags;
  final ValueChanged<String> onTagToggled;

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
  });

  @override
  Widget build(BuildContext context) {
    final filteredDishes = dishes.where((dish) {
      if (activeTags.isEmpty) return true;

      return activeTags.every((tag) => dish.tags.contains(tag));
    }).toList();
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  const SizedBox(width: 4),

                  FilterChip(
                    label: const Text('Alle'),
                    selected: activeTags.isEmpty,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) {
                      onTagToggled('__clear__'); // Trick
                    },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),

                  const SizedBox(width: 8),

                  // 🔹 Tags
                  ...allTags.map((tag) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(tag),
                        selected: activeTags.contains(tag),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (selected) {
                          onTagToggled(tag);
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
                        'Keine Gerichte vorhanden. \nTippe auf +, um eins hinzuzufügen.',
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
                          onTap: () => onTap(dish),
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
                                  child:
                                      (dish.localImagePath != null &&
                                          File(
                                            dish.localImagePath!,
                                          ).existsSync())
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
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Container(
                                                  color:
                                                      Theme.of( context,).brightness == Brightness.light
                                                      ? Colors.white
                                                      : const Color.fromARGB(255, 50, 50, 60,),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color:
                                                          Theme.of( context,).brightness == Brightness.light
                                                          ? Colors.black
                                                          : Theme.of(context).colorScheme.surface,
                                                      size: 60,
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      right: 12,
                                      left: 12,
                                      bottom: 0,
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
              onPressed: () => onAdd(),
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
