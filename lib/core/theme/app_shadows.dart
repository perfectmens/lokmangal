import 'package:flutter/material.dart';

class AppShadows {
  /// Standard Raised Tactile Card Shadow — stronger neumorphism
  static List<BoxShadow> raised({
    double blur = 18.0,
    double spread = 1.0,
    Offset offset = const Offset(7, 7),
    double darkOpacity = 0.13,
  }) => [
    BoxShadow(
      color: Color.fromRGBO(10, 13, 47, darkOpacity),
      offset: offset,
      blurRadius: blur,
      spreadRadius: spread,
    ),
    const BoxShadow(
      color: Colors.white,
      offset: Offset(-7, -7),
      blurRadius: 18,
      spreadRadius: 1,
    ),
  ];

  /// Floating Dock Shadow (High elevation)
  static List<BoxShadow> dock() => const [
    BoxShadow(
      color: Color(0x220A0D2F),
      offset: Offset(10, 10),
      blurRadius: 24,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: Colors.white,
      offset: Offset(-10, -10),
      blurRadius: 24,
      spreadRadius: 2,
    ),
  ];

  /// Subtle Pill / Button Shadow
  static List<BoxShadow> pill({bool isSelected = false}) {
    if (isSelected) return [];
    return const [
      BoxShadow(
        color: Color(0x150A0D2F),
        offset: Offset(4, 4),
        blurRadius: 8,
        spreadRadius: 0.5,
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(-4, -4),
        blurRadius: 8,
        spreadRadius: 0.5,
      ),
    ];
  }

  /// Small Icon / Control Button Shadow
  static List<BoxShadow> circularButton() => const [
    BoxShadow(
      color: Color(0x1A0A0D2F),
      offset: Offset(5, 5),
      blurRadius: 10,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Colors.white,
      offset: Offset(-5, -5),
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ];

  /// Standard Neumorphic Card Shadow
  static List<BoxShadow> card() => raised();

  /// Recessed / Inset Shadow (for progress bars, text fields)
  static List<BoxShadow> recessed() => const [
    BoxShadow(
      color: Color(0x140A0D2F),
      offset: Offset(3, 3),
      blurRadius: 6,
    ),
    BoxShadow(
      color: Colors.white,
      offset: Offset(-3, -3),
      blurRadius: 6,
    ),
  ];

  /// Inset Field / Bar Shadow
  static List<BoxShadow> insetField() => recessed();
}
