import 'package:flutter/material.dart';
import 'package:project_gaia/ui/widgets/bottom_navbar.dart';
import 'package:project_gaia/ui/views/home/home_view.dart';

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
      backgroundColor: const Color (0xFF0A2342),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
         HomeView(),
         ,
          Center(
            child: Text("Stats Page"),
          ),
          Center(
            child: Text("Chat Page"),
          ),
          Center(
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
