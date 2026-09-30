import 'package:flutter/material.dart';

/// Design tokens for the Dual-Tone Neumorphic UI Design System
/// Foundation: ~90% Neutral White/Off-White
/// Teal & Orange are ultra-light pastels — heavily white-mixed
class AppColors {
  // Foundation (90%)
  static const Color background  = Color(0xFFF4F5F7);
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFAFAFB);
  static const Color textPrimary   = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted     = Color(0xFFA0AEC0);
  static const Color borderLight   = Color(0xFFE2E8F0);
  static const Color divider       = Color(0xFFEDF2F7);

  // Intent Accents — Ultra-light Warm Peach-Orange (heavily white-mixed)
  static const Color orange      = Color(0xFFE8A87C); // Washed warm peach
  static const Color orangeSoft  = Color(0xFFF0C9A8);
  static const Color orangeLight = Color(0xFFFDF5EE); // Near-white orange tint

  // State Accents — Ultra-light Sage Teal (heavily white-mixed)
  static const Color teal        = Color(0xFF76B7B2); // Washed sage teal
  static const Color tealSoft    = Color(0xFFA8D5D1);
  static const Color tealLight   = Color(0xFFEFF8F7); // Near-white teal tint

  // Supporting
  static const Color blueMuted = Color(0xFF718096);
  static const Color cyan      = Color(0xFF9ECFCB);

  // Graph & Telemetry Palette
  static const Color targetLineOrange    = Color(0xFFF68420); // Warm Accent Orange
  static const Color targetAreaFillOrange = Color(0xFFF6A560); // Warm Accent Area Fill
  static const Color telemetryTeal       = Color(0xFF11CFC9); // Dynamic Telemetry Teal
  static const Color telemetryTealGlow   = Color(0x3311CFC9); // Pulse glow
  static const Color slateGrey           = Color(0xFF8C929C); // Muted Slate Grey
  static const Color gridGrey            = Color(0xFFE2E4E9); // Soft Neumorphic Neutral Grey

  // Status Colors
  static const Color success = teal;
  static const Color warning = orange;
  static const Color error   = Color(0xFFFC8181); // Soft rose-red
}
