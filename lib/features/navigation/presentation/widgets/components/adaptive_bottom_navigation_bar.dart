import 'package:flutter/material.dart';

import 'package:pulse_track/l10n/app_localizations.dart';

/// An adaptive bottom navigation bar used in portrait mode.
class AdaptiveBottomNavigationBar extends StatelessWidget {
  /// Index of the currently selected destination.
  final int selectedIndex;

  /// Callback when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  const AdaptiveBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 80,
          backgroundColor: colorScheme.surfaceContainer,
          elevation: 0,
          indicatorColor: colorScheme.secondaryContainer,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.focused)) {
              return colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.48,
              );
            }
            return null;
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: colorScheme.onSecondaryContainer);
            }
            return IconThemeData(color: colorScheme.onSurfaceVariant);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final base = textTheme.labelMedium;
            if (states.contains(WidgetState.selected)) {
              return base?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              );
            }
            return base?.copyWith(color: colorScheme.onSurfaceVariant);
          }),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: [
            Semantics(
              selected: selectedIndex == 0,
              label: l10n.tabHomeSemanticsLabel,
              child: NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l10n.tabHome,
              ),
            ),
            Semantics(
              selected: selectedIndex == 1,
              label: l10n.tabCalendarSemanticsLabel,
              child: NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month),
                label: l10n.tabCalendar,
              ),
            ),
            Semantics(
              selected: selectedIndex == 2,
              label: l10n.tabStatisticsSemanticsLabel,
              child: NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart),
                label: l10n.tabStatistics,
              ),
            ),
            Semantics(
              selected: selectedIndex == 3,
              label: l10n.tabSettingsSemanticsLabel,
              child: NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l10n.tabSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
