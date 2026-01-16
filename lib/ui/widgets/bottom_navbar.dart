import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int currentPageIndex;
  final ValueChanged<int> onDestinationSelected;

  const BottomNavbar(
      {super.key,
      required this.currentPageIndex,
      required this.onDestinationSelected});

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
        data: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: Colors.green.withValues(alpha: 0.1),
            labelTextStyle:
                WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                    fontSize: 12);
              }

              return const TextStyle(
                  color: Colors.black, // Or Colors.grey.shade700
                  fontWeight: FontWeight.w500,
                  fontSize: 12);
            })),
        child: NavigationBar(
            selectedIndex: currentPageIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: _buildDestinations()));
  }

  List<NavigationDestination> _buildDestinations() {
    return const [
      NavigationDestination(
        icon: Icon(
          Icons.energy_savings_leaf_outlined,
        ),
        label: "Home",
        selectedIcon: Icon(
          Icons.energy_savings_leaf,
          color: Colors.green,
        ),
      ),
      NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        label: "Stats",
        selectedIcon: Icon(
          Icons.bar_chart,
          color: Colors.green,
        ),
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline_outlined),
        label: "Chat",
        selectedIcon: Icon(
          Icons.chat_bubble,
          color: Colors.green,
        ),
      ),
      NavigationDestination(
        icon: Icon(Icons.menu),
        label: "Settings",
        selectedIcon: Icon(
          Icons.menu,
          color: Colors.green,
        ),
      )
    ];
  }
}
