import 'package:flutter/material.dart';

/// MyFolio Spacing System (8pt Grid)
/// Based on DESIGN_STRATEGY.md
class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();

  // Spacing Scale (8pt Grid System)
  static const double xs = 4.0;   // 0.5x
  static const double sm = 8.0;   // 1x
  static const double md = 12.0;  // 1.5x
  static const double lg = 16.0;  // 2x
  static const double xl = 24.0;  // 3x
  static const double xxl = 32.0; // 4x
  static const double xxxl = 48.0; // 6x

  // Common Padding Presets
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: xl,
  );

  static const EdgeInsets screenHorizontalPadding = EdgeInsets.symmetric(
    horizontal: lg,
  );

  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    vertical: lg,
    horizontal: xl,
  );

  // Common SizedBox Presets
  static const SizedBox verticalSpaceXS = SizedBox(height: xs);
  static const SizedBox verticalSpaceSM = SizedBox(height: sm);
  static const SizedBox verticalSpaceMD = SizedBox(height: md);
  static const SizedBox verticalSpaceLG = SizedBox(height: lg);
  static const SizedBox verticalSpaceXL = SizedBox(height: xl);
  static const SizedBox verticalSpaceXXL = SizedBox(height: xxl);

  static const SizedBox horizontalSpaceXS = SizedBox(width: xs);
  static const SizedBox horizontalSpaceSM = SizedBox(width: sm);
  static const SizedBox horizontalSpaceMD = SizedBox(width: md);
  static const SizedBox horizontalSpaceLG = SizedBox(width: lg);
  static const SizedBox horizontalSpaceXL = SizedBox(width: xl);
  static const SizedBox horizontalSpaceXXL = SizedBox(width: xxl);

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;

  static BorderRadius get borderRadiusXS => BorderRadius.circular(radiusXS);
  static BorderRadius get borderRadiusSM => BorderRadius.circular(radiusSM);
  static BorderRadius get borderRadiusMD => BorderRadius.circular(radiusMD);
  static BorderRadius get borderRadiusLG => BorderRadius.circular(radiusLG);
  static BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);
}
