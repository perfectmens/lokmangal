import 'package:flutter/material.dart';

/// Design tokens for the Dual-Tone Neumorphic UI Design System
/// Foundation: ~90% Neutral White/Off-White
/// Intent / Action Accent: ~5% Light Orange (Soft, Warm, Non-heavy)
/// State / Positive Accent: ~3% Light Teal (Gentle Sage/Mint, Calm)
class AppColors {
  // Foundation (90%)
  static const Color background = Color(0xFFF6F6F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFAFAFB);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF334155);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // Intent Accents (Light Warm Orange)
  static const Color orange = Color(0xFFF59E42); // Light refined warm orange
  static const Color orangeSoft = Color(0xFFFBBF7E);
  static const Color orangeLight = Color(0xFFFFF7ED);

  // State Accents (Light Gentle Teal)
  static const Color teal = Color(0xFF38B2AC); // Light gentle eucalyptus teal
  static const Color tealSoft = Color(0xFF6ED4CB);
  static const Color tealLight = Color(0xFFEBF8F6);

  // Supporting Informational
  static const Color blueMuted = Color(0xFF64748B);
  static const Color cyan = Color(0xFF6ED4CB);

  // Status Colors (Adhering to Dual-Tone semantics)
  static const Color success = teal;
  static const Color warning = orange;
  static const Color error = Color(0xFFE11D48);
}
