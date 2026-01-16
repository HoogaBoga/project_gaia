import 'package:flutter/material.dart';
import 'package:project_gaia/ui/views/stats/stats_page_view.dart';
import 'package:project_gaia/ui/widgets/bottom_navbar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const Center(
            child: Text("Home Page"),
          ),
          StatsPageView(),
          const Center(
            child: Text("Chat Page"),
          ),
          const Center(
            child: Text("Settings Page"),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentPageIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
