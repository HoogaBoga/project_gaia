import 'package:flutter/material.dart';
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
      body: <Widget>[
        const Center(child: Text("Home Page")),
        const Center(child: Text("Stats Page")),
        const Center(child: Text("Chat Page")),
        const Center(child: Text("Settings Page"))
      ][_currentIndex],
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
