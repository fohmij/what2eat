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
    final verticalOffset = isRejecting
        ? swipeVerticalOffset // KEIN clamp bei Animation
        : swipeVerticalOffset.clamp(-220.0, 220.0);

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
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(0, verticalOffset, 0),
          child: GestureDetector(
            onVerticalDragUpdate: (details) =>
                onVerticalDragUpdate(details.delta.dy),
            onVerticalDragEnd: (details) {
                if (swipeVerticalOffset < -50 ||
                    details.velocity.pixelsPerSecond.dy < -500) {
                  // 🔺 nach oben → reject
                  onRejectSwipe(animate: true);

                } else if (swipeVerticalOffset > 80 ||
                          details.velocity.pixelsPerSecond.dy > 500) {
                  // 🔻 nach unten → reset
                  onReset();

                } else {
                  // zurück in Mitte
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
                        'Tippe zum Lesen oder streiche nach oben zum Ablehnen. Steiche nach unten zum Zurücksetzen.',
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    dish.title,
                    maxLines: 2,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
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
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 🔹 Hintergrundkarten
                for (
                  int level = min(dishes.length, dishes.length - swipeIndex - 1);
                  level >= 1;
                  level--
                )
                  Positioned(
                    top: 16.0 * level,
                    left: 16.0 * level,
                    right: 16.0 * level,
                    bottom: 16.0 * level,
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          dishes[swipeIndex + level].localImagePath != null &&
                                  File(
                                    dishes[swipeIndex + level].localImagePath!,
                                  ).existsSync()
                              ? Image.file(
                                  File(
                                    dishes[swipeIndex + level].localImagePath!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  dishes[swipeIndex + level].imageUrl,
                                  fit: BoxFit.cover,
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
                        ],
                      ),
                    ),
                  ),
                // 🔥 FEHLT BEI DIR
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
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: FilledButton.icon(
          //     onPressed: onReset,
          //     icon: const Icon(Icons.refresh),
          //     label: const Text('nochmal'),
          //   ),
          // ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
