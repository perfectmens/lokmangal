import 'package:flutter/material.dart';

class AppShadows {
  /// Standard Raised Tactile Card Shadow
  static List<BoxShadow> raised({
    double blur = 14.0,
    double spread = 1.0,
    Offset offset = const Offset(6, 6),
    double darkOpacity = 0.08,
  }) => [
    BoxShadow(
      color: Color.fromRGBO(10, 13, 47, darkOpacity),
      offset: offset,
      blurRadius: blur,
      spreadRadius: spread,
    ),
    BoxShadow(
      color: Colors.white,
      offset: Offset(-offset.dx, -offset.dy),
      blurRadius: blur,
      spreadRadius: spread,
    ),
  ];

  /// Floating Dock Shadow (High elevation)
  static List<BoxShadow> dock() => const [
    BoxShadow(
      color: Color(0x1A0A0D2F),
      offset: Offset(10, 10),
      blurRadius: 20,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: Colors.white,
      offset: Offset(-10, -10),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  /// Subtle Pill / Button Shadow
  static List<BoxShadow> pill({bool isSelected = false}) {
    if (isSelected) {
      // Recessed / Inset look
      return [];
    }
    return const [
      BoxShadow(
        color: Color(0x100A0D2F),
        offset: Offset(3, 3),
        blurRadius: 6,
        spreadRadius: 0.5,
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(-3, -3),
        blurRadius: 6,
        spreadRadius: 0.5,
      ),
    ];
  }

  /// Small Icon / Control Button Shadow
  static List<BoxShadow> circularButton() => const [
    BoxShadow(
      color: Color(0x150A0D2F),
      offset: Offset(4, 4),
      blurRadius: 8,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Colors.white,
      offset: Offset(-4, -4),
      blurRadius: 8,
      spreadRadius: 1,
    ),
  ];

  /// Standard Neumorphic Card Shadow
  static List<BoxShadow> card() => raised();

  /// Recessed Neumorphic Shadow
  static List<BoxShadow> recessed() => const [
    BoxShadow(
      color: Color(0x0C0A0D2F),
      offset: Offset(2, 2),
      blurRadius: 4,
    ),
    BoxShadow(
      color: Colors.white,
      offset: Offset(-2, -2),
      blurRadius: 4,
    ),
  ];
}
