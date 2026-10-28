import 'dart:io';

import 'package:flutter/material.dart';
import 'package:what2eat/models/dish.dart';
import 'package:what2eat/widgets/dish_description.dart';

enum DishDetailResult { edit }

/// A true draggable bottom sheet for the Gerichte tab.
///
/// Important: The entire detail content is in ONE CustomScrollView with the
/// ScrollController supplied by DraggableScrollableSheet. Do not wrap the
/// description in another SingleChildScrollView or ListView.
class DishDetailSheet extends StatefulWidget {
  const DishDetailSheet({
    super.key,
    required this.dish,
    required this.onConfirmDelete,
    required this.onDelete,
  });

  final Dish dish;
  final Future<bool> Function(Dish) onConfirmDelete;
  final Future<void> Function(Dish) onDelete;

  @override
  State<DishDetailSheet> createState() => _DishDetailSheetState();
}

class _DishDetailSheetState extends State<DishDetailSheet> {
  bool _isDeleting = false;
  bool _isClosing = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_closeIfDraggedDown);
  }

  void _closeIfDraggedDown() {
    if (_isClosing || !_sheetController.isAttached) return;
    // Let the sheet follow the finger first. Dismiss it once it has been
    // pulled almost to the bottom instead of leaving a tiny sheet open.
    if (_sheetController.size <= 0.25) {
      _isClosing = true;
      // DraggableScrollableSheet notifies during layout: defer route changes
      // to avoid modifying the widget tree while it is being laid out.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _sheetController.removeListener(_closeIfDraggedDown);
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _deleteDish() async {
    if (_isDeleting) return;
    final confirmed = await widget.onConfirmDelete(widget.dish);
    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await widget.onDelete(widget.dish);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gericht konnte nicht gelöscht werden.')),
      );
    }
  }

  Widget _dishImage(BuildContext context) {
    final dish = widget.dish;
    final localPath = dish.localImagePath;

    Widget fallback() => Container(
          height: 220,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const Icon(Icons.restaurant, size: 56),
        );

    if (localPath != null && File(localPath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(localPath),
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback(),
        ),
      );
    }

    if (dish.imageUrl.trim().isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: fallback(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        dish.imageUrl,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DraggableScrollableSheet(
      controller: _sheetController,
      // Relative to the available height after the modal safe-area insets.
      initialChildSize: 0.53,
      // Below 25% height, the sheet dismisses itself (see listener above).
      minChildSize: 0.20,
      maxChildSize: 0.90,
      expand: false,
      snap: false,
      shouldCloseOnMinExtent: true,
      builder: (sheetContext, sheetScrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Material(
            color: colors.surface,
            child: CustomScrollView(
              // This connection is what makes dragging resize the SHEET
              // rather than scrolling the description separately.
              controller: sheetScrollController,
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SheetHandleHeader(
                    backgroundColor: colors.surface,
                    handleColor: colors.onSurfaceVariant.withAlpha(140),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(dish.title, style: theme.textTheme.headlineSmall),
                        if (dish.tags.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: dish.tags
                                .map((tag) => Chip(label: Text(tag)))
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _dishImage(sheetContext),
                        if (dish.description.trim().isNotEmpty) ...[
                          const SizedBox(height: 22),
                          DishDescription(
                            description: dish.description,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.error,
                                  foregroundColor: colors.onError,
                                ),
                                onPressed: _isDeleting ? null : _deleteDish,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Löschen'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _isDeleting
                                    ? null
                                    : () => Navigator.of(sheetContext)
                                        .pop(DishDetailResult.edit),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Bearbeiten'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The handle is pinned, so long descriptions cannot scroll it out of sight.
/// It is part of the SAME scroll view, so a drag on the handle also moves
/// the sheet, without adding a competing vertical gesture detector.
class _SheetHandleHeader extends SliverPersistentHeaderDelegate {
  const _SheetHandleHeader({
    required this.backgroundColor,
    required this.handleColor,
  });

  final Color backgroundColor;
  final Color handleColor;

  @override
  double get minExtent => 50;

  @override
  double get maxExtent => 50;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: backgroundColor,
      child: Center(
        child: Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: handleColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SheetHandleHeader oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor ||
      handleColor != oldDelegate.handleColor;
}
