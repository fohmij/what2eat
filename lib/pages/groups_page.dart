import 'package:flutter/material.dart';
import 'package:what2eat/models/dish_group.dart';

class GroupsPage extends StatelessWidget {
  final List<DishGroup> groups;
  final Function(DishGroup) onTap;
  final Function(DishGroup) onDelete;
  final Function(DishGroup) onEdit;
  final Future<bool> Function(DishGroup) onConfirmDelete;
  final VoidCallback onAdd;

  const GroupsPage({
    super.key,
    required this.groups,
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
              child: groups.isEmpty
                  ? Center(
                      child: Text(
                        'Keine Gruppen vorhanden. Tippe auf +, um eine hinzuzufügen.',
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
                      itemCount: groups.length,
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 80,
                      ),
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => onTap(group),
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.folder,
                                      size: 80,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                group.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${group.dishIds.length} Gerichte',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (group.isDeletable)
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                          onPressed: () => onEdit(group),
                                        ),
                                    ],
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
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: onAdd,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
