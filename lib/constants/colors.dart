import 'package:flutter/material.dart';

// Following the roadmap guidelines for autism-friendly design with the new color palette:
// - Dark Blue: #141B41
// - Medium Blue: #306BAC
// - Light Blue: #6F9CEB
// - Very Light Blue/Periwinkle: #98B9F2
// - Lavender: #8D8AF0

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF306BAC); // Medium Blue
  static const Color primaryLight = Color(0xFF6F9CEB); // Light Blue
  static const Color primaryDark = Color(0xFF141B41); // Dark Blue

  // Background colors
  static const Color background = Color(0xFFF5F5F0); // Off-white background
  static const Color cardBackground = Color(0xFFF8F8F3);
  static const Color surfaceColor = Color(0xFFF0F0E8);

  // Text colors
  static const Color textPrimary = Color(0xFF141B41); // Dark Blue for text
  static const Color textSecondary = Color(0xFF306BAC); // Medium Blue for secondary text
  static const Color textLight = Color(0xFF6F9CEB); // Light Blue for light text

  // Accent colors
  static const Color accent1 = Color(0xFF98B9F2); // Very Light Blue/Periwinkle
  static const Color accent2 = Color(0xFF8D8AF0); // Lavender
  static const Color accent3 = Color(0xFF6F9CEB); // Light Blue

  // Feedback colors
  static const Color success = Color(0xFF6F9CEB); // Light Blue
  static const Color warning = Color(0xFF8D8AF0); // Lavender
  static const Color error = Color(0xFFE57373);   // Keeping a muted red for error
  static const Color info = Color(0xFF98B9F2);    // Very Light Blue/Periwinkle

  // Divider and border colors
  static const Color divider = Color(0xFFE0E0D8);
  static const Color border = Color(0xFFD8D8D0);
} 