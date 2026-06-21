import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'subjects_screen.dart';
import 'exams_screen.dart';
import 'assignments_screen.dart';
import 'calendar_screen.dart';
import '../widgets/side_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Incremented every time the user returns to the dashboard so that
  // HomeScreen's ValueKey changes and forces a fresh initState reload,
  // which updates the subject count.
  int _homeRefreshKey = 0;

  void _onTabSelected(int index) {
    setState(() {
      if (index == 0) _homeRefreshKey++;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── Dashboard: full screen, no navigation chrome ──────────────────────
    if (_selectedIndex == 0) {
      return HomeScreen(
        key: ValueKey(_homeRefreshKey),
        onNavigate: _onTabSelected,
      );
    }

    // ── Inner pages: side navigation + content ────────────────────────────
    return Scaffold(
      body: Row(
        children: [
          SideNavigation(
            selectedIndex: _selectedIndex,
            onTabSelected: _onTabSelected,
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex - 1,
              children: const [
                SubjectsScreen(),
                ExamsScreen(),
                AssignmentsScreen(),
                CalendarScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
