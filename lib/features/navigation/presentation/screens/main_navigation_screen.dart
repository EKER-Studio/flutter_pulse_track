import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/components/adaptive_bottom_navigation_bar.dart';
import '../widgets/components/adaptive_navigation_rail.dart';

/// Main container screen featuring adaptive navigation (NavigationBar in portrait, NavigationRail in landscape).
class MainNavigationScreen extends StatefulWidget {
  /// Navigation shell provided by [StatefulShellRoute].
  ///
  /// Required: the router always supplies a shell, so no shell-less
  /// fallback exists (a previous IndexedStack fallback was removed as
  /// dead code — every production route goes through the shell).
  final StatefulNavigationShell navigationShell;

  /// Creates a [MainNavigationScreen].
  const MainNavigationScreen({super.key, required this.navigationShell});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  void _onTabSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = widget.navigationShell.currentIndex;

    final Widget body = widget.navigationShell;

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
