import 'package:flutter/material.dart';

import 'package:pulse_track/l10n/app_localizations.dart';

/// An adaptive navigation rail used in landscape mode.
class AdaptiveNavigationRail extends StatelessWidget {
  /// Index of the currently selected destination.
  final int selectedIndex;

  /// Callback when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  const AdaptiveNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return NavigationRailTheme(
      data: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(
          color: colorScheme.onSecondaryContainer,
        ),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  groupAlignment: 0.0,
                  minWidth: 88.0,
                  backgroundColor: colorScheme.surfaceContainer,
                  destinations: [
                    NavigationRailDestination(
                      icon: Semantics(
                        selected: selectedIndex == 0,
                        label: l10n.tabHomeSemanticsLabel,
                        child: const Icon(Icons.home_outlined),
                      ),
                      selectedIcon: Semantics(
                        selected: selectedIndex == 0,
                        label: l10n.tabHomeSemanticsLabel,
                        child: const Icon(Icons.home),
                      ),
                      label: Text(l10n.tabHome),
                    ),
                    NavigationRailDestination(
                      icon: Semantics(
                        selected: selectedIndex == 1,
                        label: l10n.tabCalendarSemanticsLabel,
                        child: const Icon(Icons.calendar_month_outlined),
                      ),
                      selectedIcon: Semantics(
                        selected: selectedIndex == 1,
                        label: l10n.tabCalendarSemanticsLabel,
                        child: const Icon(Icons.calendar_month),
                      ),
                      label: Text(l10n.tabCalendar),
                    ),
                    NavigationRailDestination(
                      icon: Semantics(
                        selected: selectedIndex == 2,
                        label: l10n.tabStatisticsSemanticsLabel,
                        child: const Icon(Icons.bar_chart_outlined),
                      ),
                      selectedIcon: Semantics(
                        selected: selectedIndex == 2,
                        label: l10n.tabStatisticsSemanticsLabel,
                        child: const Icon(Icons.bar_chart),
                      ),
                      label: Text(l10n.tabStatistics),
                    ),
                    NavigationRailDestination(
                      icon: Semantics(
                        selected: selectedIndex == 3,
                        label: l10n.tabSettingsSemanticsLabel,
                        child: const Icon(Icons.settings_outlined),
                      ),
                      selectedIcon: Semantics(
                        selected: selectedIndex == 3,
                        label: l10n.tabSettingsSemanticsLabel,
                        child: const Icon(Icons.settings),
                      ),
                      label: Text(l10n.tabSettings),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
