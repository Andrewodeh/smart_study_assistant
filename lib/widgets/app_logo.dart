import 'package:flutter/material.dart';

/// Reusable amber logo mark used in the dashboard header and side navigation.
class AppLogoMark extends StatelessWidget {
  final double size;

  const AppLogoMark({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE8A020),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        Icons.school_rounded,
        color: Colors.white,
        size: size * 0.54,
      ),
    );
  }
}
