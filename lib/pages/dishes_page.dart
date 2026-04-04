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

  const DishesPage({
    super.key,
    required this.dishes,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.onConfirmDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: dishes.isEmpty
                  ? Center(
                      child: Text(
                        'Keine Gerichte vorhanden. Tippe auf +, um eins hinzuzufügen.',
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
                      itemCount: dishes.length,
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 80,
                      ),
                      itemBuilder: (context, index) {
                        final dish = dishes[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => onTap(dish),
                          child: Card(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? const Color.fromARGB(255, 210, 214, 211)
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
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          size: 60,
                                                        ),
                                                      ),
                                                    ),
                                          ),
                                        ),
                                  // child:
                                  //                           if (dish.localimagepath != null &&
                                  //                               file(dish.localimagepath!).existssync())
                                  //                             cliprrect(
                                  //                               borderradius: const borderradius.vertical(
                                  //                                 top: radius.circular(16),
                                  //                               ),
                                  //                               child: image.file(
                                  //                                 file(dish.localimagepath!),
                                  //                                 height: 180,
                                  //                                 fit: boxfit.cover,
                                  //                               ),
                                  //                             )
                                  //                           else
                                  //                             cliprrect(
                                  //                               borderradius: const borderradius.vertical(
                                  //                                 top: radius.circular(16),
                                  //                               ),
                                  //                               child: image.network(
                                  //                                 dish.imageurl,
                                  //                                 height: 180,
                                  //                                 fit: boxfit.cover,
                                  //                                 errorbuilder:
                                  //                                     (context, error, stacktrace) =>
                                  //                                         container(
                                  //                                           height: 180,
                                  //                                           color: colors.grey.shade300,
                                  //                                           child: const center(
                                  //                                             child: icon(
                                  //                                               icons.broken_image,
                                  //                                               size: 60,
                                  //                                             ),
                                  //                                           ),
                                  //                                         ),
                                  //                               ),
                                  //                             ),
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
