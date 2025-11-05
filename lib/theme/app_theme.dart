import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// MyFolio App Theme
/// Based on DESIGN_STRATEGY.md
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryPurple,
        surface: AppColors.primaryBackground,
        error: AppColors.lossRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.primaryText,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.secondaryBackground,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.primaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLG,
        ),
        shadowColor: Colors.black.withOpacity(0.05),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMD,
          ),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMD,
          ),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          padding: AppSpacing.buttonPadding,
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMD,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMD,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMD,
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMD,
          borderSide: const BorderSide(
            color: AppColors.lossRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMD,
          borderSide: const BorderSide(
            color: AppColors.lossRed,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        hintStyle: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 16.0,
        ),
        labelStyle: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 16.0,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.neutralGray,
        size: 24.0,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.neutralGray.withOpacity(0.2),
        thickness: 1.0,
        space: AppSpacing.lg,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.secondaryBackground,
        selectedColor: AppColors.primaryBlue.withOpacity(0.1),
        labelStyle: const TextStyle(
          color: AppColors.primaryText,
          fontSize: 14.0,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryBackground,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.neutralGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
        selectedLabelStyle: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryBlue,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLG,
        ),
      ),
    );
  }

  // Dark theme for Phase 2
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryPurple,
        surface: AppColors.darkBackground,
        error: AppColors.lossRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      // TODO: Add dark theme details in Phase 2
    );
  }
}
