import 'package:flutter/material.dart';

/// Central color palette for the app.
///
/// A modern violet + teal scheme designed for a mobile experience.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C4DF6); // violet
  static const Color primaryDark = Color(0xFF4F37C9);
  static const Color primaryLight = Color(0xFFEDE9FE); // soft violet tint
  static const Color accent = Color(0xFF00C2A8); // teal

  // Surfaces
  static const Color background = Color(0xFFF5F4FB); // light lavender-gray
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE7E5F0);

  // Text
  static const Color textDark = Color(0xFF1E1B2E);
  static const Color textMuted = Color(0xFF6B6880);
  static const Color textFaint = Color(0xFF9C99AD);

  // Status
  static const Color success = Color(0xFF16A974);
  static const Color warning = Color(0xFFF5A524);
  static const Color danger = Color(0xFFE53E5A);
  static const Color info = Color(0xFF2563EB);

  // Gradient for headers
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C5CFB), Color(0xFF5538D9)],
  );
}
