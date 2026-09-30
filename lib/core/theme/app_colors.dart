import 'package:flutter/material.dart';

/// Design tokens for the Dual-Tone Neumorphic UI Design System
/// Foundation: ~90% Neutral White/Off-White
/// Intent / Action Accent: ~5% Orange
/// State / Positive Accent: ~3% Teal
class AppColors {
  // Foundation (90%)
  static const Color background = Color(0xFFF6F6F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFAFAFB);
  static const Color textPrimary = Color(0xFF0A0D2F);
  static const Color textSecondary = Color(0xFF223B57);
  static const Color textMuted = Color(0xFF8C929C);
  static const Color borderLight = Color(0xFFBCBCBF);
  static const Color divider = Color(0xFFE5E7EB);

  // Intent Accents (5% - User Action, Intent, Attention)
  static const Color orange = Color(0xFFF68420);
  static const Color orangeSoft = Color(0xFFD68A51);
  static const Color orangeLight = Color(0xFFFFF2E6);

  // State Accents (3% - System State, Healthy, Active, Verified)
  static const Color teal = Color(0xFF11CFC9);
  static const Color tealSoft = Color(0xFF47B3E2);
  static const Color tealLight = Color(0xFFE4F9F8);

  // Supporting Informational
  static const Color blueMuted = Color(0xFF496D89);
  static const Color cyan = Color(0xFF47B3E2);

  // Status Colors (Adhering to Dual-Tone semantics)
  static const Color success = teal;
  static const Color warning = orange;
  static const Color error = Color(0xFFD32F2F);
}
