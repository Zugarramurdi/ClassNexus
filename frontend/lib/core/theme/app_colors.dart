import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF358C7C);
  static const Color primaryAlternative = Color(0xFF358C74);
  static const Color secondary = Color(0xFFD9AC59); // Gold/Accent
  
  // Neutrals
  static const Color background = Color(0xFFF0F2F2);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF3E4F59); // Slate Dark Text
  
  // Semantic
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFBC02D);
  
  // Helper for transparency
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
}
