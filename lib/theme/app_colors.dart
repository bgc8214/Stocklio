import 'package:flutter/material.dart';

/// MyFolio App Color System
/// Based on DESIGN_STRATEGY.md
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors (Main Brand Colors)
  static const Color primaryBlue = Color(0xFF4C6FFF);
  static const Color primaryPurple = Color(0xFF7C3AED);

  // Semantic Colors
  static const Color profitGreen = Color(0xFF10B981);
  static const Color lossRed = Color(0xFFEF4444);
  static const Color neutralGray = Color(0xFF6B7280);
  static const Color warningYellow = Color(0xFFF59E0B);

  // Background Colors
  static const Color primaryBackground = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFF9FAFB);
  static const Color darkBackground = Color(0xFF111827); // For dark mode (Phase 2)

  // Text Colors
  static const Color primaryText = Color(0xFF111827);
  static const Color secondaryText = Color(0xFF6B7280);
  static const Color disabledText = Color(0xFF9CA3AF);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFfdfbfb), Color(0xFFebedee)],
  );

  // Chart Colors
  static const Color chartDaily = primaryBlue;
  static const Color chartMonthly = profitGreen;
  static const Color chartYearly = primaryPurple;

  // Helper method to get profit/loss color based on value
  static Color getProfitLossColor(double value) {
    return value >= 0 ? profitGreen : lossRed;
  }

  // Helper method to get profit/loss color with opacity
  static Color getProfitLossColorWithOpacity(double value, double opacity) {
    return value >= 0
        ? profitGreen.withOpacity(opacity)
        : lossRed.withOpacity(opacity);
  }
}
