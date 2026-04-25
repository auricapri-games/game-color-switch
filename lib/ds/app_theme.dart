import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData build() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.background,
        onSurface: AppColors.text,
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: GoogleFonts.fredokaTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
    );
  }

  static TextStyle title(double size) => GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        letterSpacing: -0.5,
      );

  static TextStyle subtitle(double size) => GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      );

  static TextStyle body(double size) => GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );
}
