import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF07111F);
  static const Color surface = Color(0xFF0F1E33);
  
  static const Color primaryBlue = Color(0xFF2F80ED);
  static const Color secondaryBlue = Color(0xFF56CCF2);
  static const Color accentCyan = Color(0xFF00D1FF);
  
  static const Color successGreen = Color(0xFF27AE60);
  static const Color warningYellow = Color(0xFFF2C94C);
  static const Color dangerRed = Color(0xFFEB5757);
  
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFAAB7C8);

  // Gradient definitions for premium glassmorphism and background styling
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF07111F),
      Color(0xFF0A192F),
      Color(0xFF050B14),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryBlue,
      secondaryBlue,
    ],
  );

  static const LinearGradient glassBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF),
      Color(0x05FFFFFF),
    ],
  );
}
