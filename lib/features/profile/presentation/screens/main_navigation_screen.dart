import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/features/home/presentation/screens/home_screen.dart';
import 'package:fitness_app/features/plan/presentation/screens/my_plan_screen.dart';
import 'package:fitness_app/features/workouts/presentation/screens/workouts_screen.dart';
import 'package:fitness_app/features/progress/presentation/screens/progress_screen.dart';
import 'profile_preferences_screen.dart';

/// Main navigation shell hosting persistent bottom navigation bar.
/// Contains: Home, Plan, Workouts, Progress, Profile tabs.
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0, // Default to Home as requested
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onNavigateToTab: (index) => setState(() => _currentIndex = index),
          ),
          MyPlanScreen(
            onNavigateToTab: (index) => setState(() => _currentIndex = index),
          ),
          const WorkoutsScreen(),
          const ProgressScreen(),
          const ProfilePreferencesScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEDF2F7), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'Home', Icons.home_outlined, Icons.home_rounded),
              _buildNavItem(1, 'Plan', Icons.assignment_outlined, Icons.assignment_rounded),
              _buildNavItem(2, 'Workouts', Icons.fitness_center_outlined, Icons.fitness_center_rounded),
              _buildNavItem(3, 'Progress', Icons.bar_chart_outlined, Icons.bar_chart_rounded),
              _buildNavItem(4, 'Profile', Icons.person_outline_rounded, Icons.person_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon, IconData activeIcon) {
    final isSelected = _currentIndex == index;
    const activeColor = Color(0xFF005953);
    const inactiveColor = Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 4),
            // Wireframe active indicator bar under active tab
            Container(
              width: 20,
              height: 2.5,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
