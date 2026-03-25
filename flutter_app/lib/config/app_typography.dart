import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Base text style with Inter font
  static TextStyle get _base => GoogleFonts.inter(
    color: AppColors.foreground,
  );

  // typography-display
  // index.css: font-size: 2.5rem (40px); font-weight: 700; line-height: 1.2; letter-spacing: -0.02em;
  static TextStyle get display => _base.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.02 * 40, // -0.8px roughly
  );

  // typography-h2
  // index.css: font-size: 1.75rem (28px); font-weight: 600; line-height: 1.3; letter-spacing: -0.01em;
  static TextStyle get h2 => _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.01 * 28,
  );

  // typography-body-large
  // index.css: font-size: 1.125rem (18px); font-weight: 500; line-height: 1.5;
  static TextStyle get bodyLarge => _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // Standard headings (h1-h4 from index.css layer base via @media checks or defaults)
  // h1: text-2xl (24px)
  static TextStyle get h1 => _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  
  // h3: text-lg (18px)
  static TextStyle get h3 => _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // body / p
  // text-base (16px)
  static TextStyle get body => _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  // text-sm
  static TextStyle get bodySmall => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5, // Tailwind default leading is usually 1.5 or 1.25 for sm
  );

  // text-xs
  static TextStyle get caption => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.mutedForeground,
  );
}
