import 'package:flutter/material.dart';
import 'package:project_gaia/ui/views/stats/stats_page_view.dart';
import 'package:project_gaia/ui/widgets/bottom_navbar.dart';
import 'package:project_gaia/ui/views/home/home_view.dart';
import 'package:project_gaia/ui/views/settings/settings_view.dart';

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
      backgroundColor: const Color(0xFF0A2342),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeView(),
          StatsPageView(),
          Center(
            child: Text("Chat Page", style: TextStyle(color: Colors.white)),
          ),
          Center(
            child: SettingsView(),
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
