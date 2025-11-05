import 'package:flutter/material.dart';
import 'app_colors.dart';

/// MyFolio Typography System
/// Based on DESIGN_STRATEGY.md
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Font Weights
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight regular = FontWeight.w400;

  // Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: bold,
    color: AppColors.primaryText,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24.0,
    fontWeight: bold,
    color: AppColors.primaryText,
    letterSpacing: -0.3,
  );

  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20.0,
    fontWeight: semiBold,
    color: AppColors.primaryText,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18.0,
    fontWeight: semiBold,
    color: AppColors.primaryText,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: regular,
    color: AppColors.primaryText,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: regular,
    color: AppColors.secondaryText,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: medium,
    color: AppColors.primaryText,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12.0,
    fontWeight: regular,
    color: AppColors.secondaryText,
  );

  // Number Styles (for financial data)
  static const TextStyle numberLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: bold,
    color: AppColors.primaryText,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()], // Monospaced numbers
  );

  static const TextStyle numberMedium = TextStyle(
    fontSize: 20.0,
    fontWeight: semiBold,
    color: AppColors.primaryText,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle numberSmall = TextStyle(
    fontSize: 16.0,
    fontWeight: medium,
    color: AppColors.primaryText,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Profit/Loss Styles
  static TextStyle profitLoss(double value, {double fontSize = 16.0}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: semiBold,
      color: AppColors.getProfitLossColor(value),
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle profitLossPercentage(double value) {
    return TextStyle(
      fontSize: 14.0,
      fontWeight: medium,
      color: AppColors.getProfitLossColor(value),
    );
  }
}
