import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';

import 'package:what2eat/models/dish.dart';

class SwipePage extends StatelessWidget {
  final List<Dish> dishes;
  final int swipeIndex;

  final bool isSwipeCardFlipped;
  final double swipeVerticalOffset;
  final bool isRejecting;

  final VoidCallback onReset;
  final Function({bool animate}) onRejectSwipe;
  final VoidCallback onFlipCard;
  final Function(double) onVerticalDragUpdate;
  final Function(DragEndDetails) onVerticalDragEnd;
  final VoidCallback onVerticalDragCancel;

  const SwipePage({
    super.key,
    required this.dishes,
    required this.swipeIndex,
    required this.isSwipeCardFlipped,
    required this.swipeVerticalOffset,
    required this.isRejecting,
    required this.onReset,
    required this.onRejectSwipe,
    required this.onFlipCard,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
    required this.onVerticalDragCancel,
  });

  @override
  Widget build(BuildContext context) {
    return _buildSwipeTab(context);
  }

  Widget _buildSwipeCard(BuildContext context, Dish dish) {
    final verticalOffset = swipeVerticalOffset.clamp(-220.0, 220.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: swipeVerticalOffset > 8 ? 1.0 : 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(24),
              ),
              child: SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.refresh, color: Colors.white, size: 34),
                        SizedBox(height: 8),
                        Text(
                          'Stapel zurücksetzen',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isRejecting)
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.close, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Ablehnen',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Transform.translate(
          offset: Offset(0, verticalOffset),
          child: GestureDetector(
            onVerticalDragUpdate: (details) =>
                onVerticalDragUpdate(details.delta.dy),
            onVerticalDragEnd: (details) {
              if (swipeVerticalOffset < -100 ||
                  details.velocity.pixelsPerSecond.dy < -500) {
                onRejectSwipe(animate: true);
              } else {
                onVerticalDragEnd(details);
              }
            },
            onVerticalDragCancel: onVerticalDragCancel,
            child: InkWell(
              onTap: onFlipCard,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.hardEdge,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    final rotate = Tween(
                      begin: 1.0,
                      end: 0.0,
                    ).animate(animation);
                    return AnimatedBuilder(
                      animation: rotate,
                      child: child,
                      builder: (context, child) {
                        final value = rotate.value;
                        return Transform(
                          transform: Matrix4.rotationY(value * 3.14159),
                          alignment: Alignment.center,
                          child: child,
                        );
                      },
                    );
                  },
                  child: isSwipeCardFlipped
                      ? _buildSwipeCardDetails(context, dish)
                      : _buildSwipeCardSummary(dish),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeCardSummary(Dish dish) {
    return SizedBox.expand(
      key: const ValueKey('summary'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          dish.localImagePath != null && File(dish.localImagePath!).existsSync()
              ? Image.file(File(dish.localImagePath!), fit: BoxFit.cover)
              : Image.network(
                  dish.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
          if (swipeIndex == 0)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tippe zum Lesen oder streiche nach oben zum Ablehnen',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dish.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${swipeIndex + 1}/${dishes.length}',
                 style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeCardDetails(BuildContext context, Dish dish) {
    return Container(
      key: const ValueKey('details'),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                dish.localImagePath != null &&
                        File(dish.localImagePath!).existsSync()
                    ? Image.file(File(dish.localImagePath!), fit: BoxFit.cover)
                    : Image.network(
                        dish.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 60),
                          ),
                        ),
                      ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Text(
                    dish.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Text(
                  dish.description.isNotEmpty
                      ? dish.description
                      : 'Keine Beschreibung vorhanden',
                  style: TextStyle(
                    fontSize: 16,
                    color: dish.description.isNotEmpty
                        ? null
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeTab(BuildContext context) {
    if (dishes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Keine Gerichte zum Swipen. Füge zuerst ein Gericht hinzu.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }

    if (swipeIndex >= dishes.length) {
      return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx < -200) {
            onReset();
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ende des Stapels erreicht.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Wische nach links, um den Stapel zurückzusetzen.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh),
                label: const Text('Zurücksetzen'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16,  top: 16, bottom: 0),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (
                  int level = min(4, dishes.length - swipeIndex - 1);
                  level >= 1;
                  level--
                ) ...[
                  Positioned(
                    top: 18.0 * level,
                    left: 14.0 * level,
                    right: 14.0 * level,
                    bottom: 18.0 * level,
                    child: Opacity(
                      opacity: 1 - level * 0.16,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _buildSwipeCard(context, dishes[swipeIndex]),
                ),
              ],
            ),
          ),
          if (swipeIndex > 0)
            FilledButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('Stapel zurücksetzen'),
            ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
