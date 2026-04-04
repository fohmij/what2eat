import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final int dishCount;
  final int swipeIndex;
  final bool hasMoreCards;

  const SettingsPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.dishCount,
    required this.swipeIndex,
    required this.hasMoreCards,
  });

  @override
  Widget build(BuildContext context) {
    return _buildSettingsTab(context);
  }

  Widget _buildSettingsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Icon(Icons.palette),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Theme',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            PopupMenuButton<ThemeMode>(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color.fromARGB(255, 200, 200, 200)
                      : const Color.fromARGB(255, 74, 74, 74),
                  width: 1,
                ),
              ),
              initialValue: themeMode,
              onSelected: onThemeModeChanged,
              itemBuilder: (context) => [
                PopupMenuItem(
                  padding: const EdgeInsets.only(left: 12),
                  value: ThemeMode.system,
                  child: Row(
                    children: [
                      if (themeMode == ThemeMode.system)
                        const Icon(Icons.check, size: 20)
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 12),
                      const Text('System'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ThemeMode.light,
                  child: Row(
                    children: [
                      if (themeMode == ThemeMode.light)
                        const Icon(Icons.check, size: 20)
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 12),
                      const Text('Hell'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ThemeMode.dark,
                  child: Row(
                    children: [
                      if (themeMode == ThemeMode.dark)
                        const Icon(Icons.check, size: 20)
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 12),
                      const Text('Dunkel'),
                    ],
                  ),
                ),
              ],
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        themeMode == ThemeMode.system
                            ? 'System'
                            : themeMode == ThemeMode.light
                            ? 'Hell'
                            : 'Dunkel',
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Gerichte insgesamt'),
          subtitle: Text('$dishCount Gerichte gespeichert'),
        ),
        ListTile(
          leading: const Icon(Icons.shuffle),
          title: const Text('Swipe Fortschritt'),
          subtitle: Text(
            hasMoreCards
                ? 'Aktuelles Gericht ${swipeIndex + 1} von $dishCount'
                : 'Stapel vollständig geswiped',
          ),
        ),
      ],
    );
  }
}
