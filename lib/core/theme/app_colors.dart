import 'package:flutter/material.dart';

/// Design tokens for the Dual-Tone Neumorphic UI Design System (App 1 Alignment)
/// Foundation: ~90% Neutral White/Off-White
/// TEAL = STATE / REALITY / HEALTH (#11CFC9 Electric Teal)
/// ORANGE = INTENT / TARGET / ACTION / ATTENTION (#F68420 Strong Orange)
class AppColors {
  // ===========================================================================
  // NEUTRAL FOUNDATION (90%)
  // ===========================================================================
  static const Color background      = Color(0xFFF6F6F7); // App canvas
  static const Color surface         = Color(0xFFFFFFFF); // Elevated neumorphic cards & controls
  static const Color surfaceElevated = Color(0xFFFAFAFB);
  static const Color textPrimary     = Color(0xFF0A0D2F); // High-emphasis text & critical outlines
  static const Color textSecondary   = Color(0xFF223B57); // Headings & secondary emphasis
  static const Color textMuted       = Color(0xFF8C929C); // Steel gray for muted labels & neutral icons
  static const Color borderLight     = Color(0xFFE2E4E9); // Subtle neumorphic neutral border
  static const Color divider         = Color(0xFFEDF2F7);

  // ===========================================================================
  // TEAL FAMILY — STATE / REALITY / HEALTH
  // ===========================================================================
  /// Primary Teal: Electric Teal (#11CFC9)
  /// Active navigation, live indicators, actual telemetry, healthy status badges
  static const Color primaryTeal     = Color(0xFF11CFC9);
  static const Color teal            = Color(0xFF11CFC9); // Main teal identity of the application

  /// Light Teal (#62E4DF)
  /// Secondary/live trend curves, soft telemetry indicators, hairline curves
  static const Color lightTeal       = Color(0xFF62E4DF);
  static const Color tealSoft        = Color(0xFF62E4DF);

  /// Historical Teal (#7DE0DD)
  /// Completed/past shift bars, historical chart elements, settled data
  static const Color historicalTeal  = Color(0xFF7DE0DD);

  /// Deep Teal (#00B5AD & #009688)
  /// Positive production/yield indicators, favorable deviations, performance badges
  static const Color deepTeal        = Color(0xFF00B5AD);

  /// Muted Teal (#0EA5A0) & Translucent Teal (10% #1A11CFC9)
  /// Stable zones, subtle background tints, verified/healthy card backgrounds
  static const Color mutedTeal       = Color(0xFF0EA5A0);
  static const Color tealTint10      = Color(0x1A11CFC9);
  static const Color tealLight       = Color(0x1A11CFC9); // 10% translucent electric teal tint

  /// Telemetry Graph Palette
  static const Color telemetryTeal     = Color(0xFF11CFC9);
  static const Color telemetryTealGlow = Color(0x3311CFC9); // Translucent 20% pulse glow
  static const Color cyan              = Color(0xFF7DE0DD); // Supporting info / cyan
  static const Color blueMuted         = Color(0xFF496D89); // Supporting information

  // ===========================================================================
  // ORANGE FAMILY — INTENT / TARGET / ACTION / ATTENTION
  // ===========================================================================
  /// Primary Orange: Strong Intent Orange (#F68420)
  /// Primary action buttons, logout, critical alerts, attention cues, active shift
  static const Color primaryOrange    = Color(0xFFF68420);
  static const Color orange           = Color(0xFFF68420); // Main orange identity of the application

  /// Target / Benchmark Orange (#F6A560)
  /// Target lines, target dots, target values, benchmark indicators, warning zones
  static const Color targetLineOrange    = Color(0xFFF6A560);
  static const Color targetAreaFillOrange = Color(0x33F68420); // 20% translucent warm fill
  static const Color targetOrange        = Color(0xFFF6A560);

  /// Soft Supporting Orange (#D68A51)
  /// Secondary warm emphasis, subtle input borders, secondary controls
  static const Color orangeSoft       = Color(0xFFD68A51);

  /// Orange Transparency (10% #1AF68420 & 20% #33F68420)
  /// Soft selected-state backgrounds, active chips, subtle attention tints
  static const Color orangeTint10     = Color(0x1AF68420);
  static const Color orangeTint20     = Color(0x33F68420);
  static const Color orangeLight      = Color(0x1AF68420); // 10% translucent intent orange tint

  // Neutral Graph Palette
  static const Color slateGrey        = Color(0xFF8C929C); // Steel / Muted Grey
  static const Color gridGrey         = Color(0xFFE2E4E9); // Soft Neumorphic Neutral Grey

  // Status Semantics
  static const Color success          = Color(0xFF11CFC9); // Electric Teal
  static const Color warning          = Color(0xFFF68420); // Strong Orange
  static const Color error            = Color(0xFFE53935); // Critical Exception / Error
}
