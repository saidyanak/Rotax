import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFDB3737);
  static const Color primaryDark = Color(0xFFBE1D16);
  static const Color primaryLight = Color(0xFFFF5252);
  
  // Background Colors
  static const Color background = Color(0xFF79686B);
  static const Color backgroundDark = Color(0xFF171717);
  static const Color scaffoldBackground = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2E1A1A);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF000000);
  
  // Dark Colors
  static const Color dark = Color(0xFF1E1E2D);
  static const Color darkLight = Color(0xFF2D2D3A);
  
  // Card & Surface Colors
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFAFAFA);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Button Colors
  static const Color buttonPrimary = Color(0xFF171717);
  static const Color buttonSecondary = Color(0xFF616161);
  static const Color buttonText = Color(0xFFFFFFFF);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [backgroundDark, Color(0xFF2C2C2C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
