import 'package:flutter/material.dart';
import 'data/recipe_store.dart';

const kMobile = 600.0;
const kTablet = 1024.0;

class AppShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final useRail = w >= kTablet;
        final store = RecipeStore.instance;

        final body = Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: store.maxContentWidth),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.child,
            ),
          ),
        );

        // Material 3: compact → NavigationBar, medium/expanded → NavigationRail
        // (M3-suositusten mukainen käyttö; codelabissa sama ajatus). 
        // [2](https://m3.material.io/components/navigation-bar/overview)[3](https://api.flutter.dev/flutter/material/NavigationRail-class.html)[1](https://codelabs.developers.google.com/codelabs/flutter-animated-responsive-layout)
        return Scaffold(
          body: Row(
            children: [
              if (useRail)
                NavigationRail(
                  selectedIndex: widget.currentIndex,
                  onDestinationSelected: widget.onIndexChanged,
                  labelType: NavigationRailLabelType.selected,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book),
                      label: Text('Reseptit'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics),
                      label: Text('Tilastot'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Asetukset'),
                    ),
                  ],
                ),
              Expanded(child: body),
            ],
          ),
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: widget.currentIndex,
                  onDestinationSelected: widget.onIndexChanged,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book),
                      label: 'Reseptit',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics),
                      label: 'Tilastot',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: 'Asetukset',
                    ),
                  ],
                ),
        );
      },
    );
  }
}