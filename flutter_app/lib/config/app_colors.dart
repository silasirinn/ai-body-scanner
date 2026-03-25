import 'package:flutter/material.dart';

class AppColors {
  // Base colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Theme colors from CSS
  static const Color background = Color(0xFFF8F9FF);
  static const Color foreground = Color(0xFF1a1a2e);
  static const Color card = Color(0xFFFFFFFF);
  
  // Primary: #8B5CF6 (Purple)
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryForeground = Colors.white;
  
  // Secondary: #F3F4FF
  static const Color secondary = Color(0xFFF3F4FF);
  
  // Muted: #E5E7EB
  static const Color muted = Color(0xFFE5E7EB);
  static const Color mutedForeground = Color(0xFF6B7280);
  
  // Accent: #10B981 (Emerald)
  static const Color accent = Color(0xFF10B981);
  
  // Destructive: #EF4444
  static const Color destructive = Color(0xFFEF4444);
  
  // Borders & Rings
  static const Color border = Color.fromRGBO(139, 92, 246, 0.15); // rgba(139,92,246,0.15)
  static const Color inputBorder = Color(0xFFE5E7EB); // Gray-200 for normal inputs usually
  static const Color ring = Color(0xFF8B5CF6);

  // Specific Tailwind Colors used in Project
  static const Color purple50 = Color(0xFFFAF5FF);
  static const Color purple100 = Color(0xFFF3E8FF);
  static const Color purple600 = Color(0xFF9333EA);
  
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald500 = Color(0xFF10B981);
  
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray800 = Color(0xFF1F2937);
  
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange500 = Color(0xFFF97316);

  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);

  static const Color blue50 = Color(0xFFEFF6FF);

  static const Color purple600Tailwind = Color(0xFF9333EA); // Same as purple600 but ensuring naming match


  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, purple600],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [purple50, white, emerald50], // Approximate "from-purple-50 via-white to-emerald-50"
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient logoGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
