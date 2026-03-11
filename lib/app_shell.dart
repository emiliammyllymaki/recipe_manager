import 'package:flutter/material.dart';

// Breakpoints
const kMobileBreakpoint = 600.0;   // mobile -> tablet
const kTabletBreakpoint = 1024.0;  // tablet -> desktop
const kMaxContentWidth = 1200.0;   // max content width on large screens

class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  static const _destinations = [
    (icon: Icons.menu_book_outlined, selected: Icons.menu_book, label: 'Recipes'),
    (icon: Icons.bar_chart_outlined, selected: Icons.bar_chart, label: 'Statistics'),
    (icon: Icons.settings_outlined, selected: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Responsive: use NavigationRail on tablet/desktop, NavigationBar on mobile
        final useRail = width >= kTabletBreakpoint;

        final body = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: child,
            ),
          ),
        );

        return Scaffold(
          body: Row(
            children: [
              if (useRail)
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: onIndexChanged,
                  labelType: NavigationRailLabelType.selected,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Icon(Icons.restaurant_menu, size: 32),
                  ),
                  destinations: _destinations
                      .map((d) => NavigationRailDestination(
                            icon: Icon(d.icon),
                            selectedIcon: Icon(d.selected),
                            label: Text(d.label),
                          ))
                      .toList(),
                ),
              if (useRail) const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: body),
            ],
          ),
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: onIndexChanged,
                  destinations: _destinations
                      .map((d) => NavigationDestination(
                            icon: Icon(d.icon),
                            selectedIcon: Icon(d.selected),
                            label: d.label,
                          ))
                      .toList(),
                ),
        );
      },
    );
  }
}
