import 'package:flutter/material.dart';
import 'app_logo.dart';

class SideNavigation extends StatelessWidget {
  final int selectedIndex;
  final void Function(int index) onTabSelected;

  const SideNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Dashboard',
      index: 0,
    ),
    _NavItemData(
      icon: Icons.book_outlined,
      activeIcon: Icons.book_rounded,
      label: 'Subjects',
      index: 1,
    ),
    _NavItemData(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'Exams',
      index: 2,
    ),
    _NavItemData(
      icon: Icons.task_alt,
      activeIcon: Icons.task_alt,
      label: 'Assignments',
      index: 3,
    ),
    _NavItemData(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: 'Calendar',
      index: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      color: const Color(0xFF0F1F3D),
      child: SafeArea(
        right: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand area
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Row(
                children: const [
                  AppLogoMark(size: 32),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Smart Study\nAssistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              color: Colors.white12,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            const SizedBox(height: 8),

            // Navigation items
            for (final item in _items)
              _NavItem(
                data: item,
                isActive: selectedIndex == item.index,
                onTap: () => onTabSelected(item.index),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Data model for a nav item ───────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
  });
}

// ─── Single nav item widget ───────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive
                  ? const Color(0xFFE8A020)
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          children: [
            Icon(
              isActive ? data.activeIcon : data.icon,
              color: isActive
                  ? const Color(0xFFE8A020)
                  : Colors.white54,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              data.label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white60,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
