import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../heart_rate/presentation/views/hr_home_view.dart';
import '../../../heart_rate/presentation/views/workout_history_view.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/components/adaptive_bottom_navigation_bar.dart';
import '../widgets/components/adaptive_navigation_rail.dart';

/// Main container screen featuring adaptive navigation (NavigationBar in portrait, NavigationRail in landscape).
class MainNavigationScreen extends StatefulWidget {
  /// Optional navigation shell provided by [StatefulShellRoute].
  final StatefulNavigationShell? navigationShell;

  /// Creates a [MainNavigationScreen].
  const MainNavigationScreen({super.key, this.navigationShell});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  int get _activeTabIndex =>
      widget.navigationShell?.currentIndex ?? _currentIndex;

  void _onTabSelected(int index) {
    if (widget.navigationShell != null) {
      widget.navigationShell!.goBranch(
        index,
        initialLocation: index == widget.navigationShell!.currentIndex,
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = _activeTabIndex;

    final Widget body;
    if (widget.navigationShell != null) {
      body = widget.navigationShell!;
    } else {
      final screens = [
        const HrHomeView(),
        const WorkoutHistoryView(),
        const SettingsScreen(),
      ];
      body = IndexedStack(index: _currentIndex, children: screens);
    }

    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    if (isLandscape) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              AdaptiveNavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: _onTabSelected,
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: body,
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _onTabSelected,
      ),
    );
  }
}
