import 'package:flutter/material.dart';

class AppTheme {
  // Theme Colors
  static const Color spaceBackground = Color(0xFF070B19);
  static const Color cyanGlow = Color(0xFF00E5FF);
  static const Color purpleNebula = Color(0xFF7B1FA2);
  static const Color crystalBlue = Color(0xFF29B6F6);
  static const Color crystalGold = Color(0xFFFFD700);
  static const Color asteroidOrange = Color(0xFFFF5722);
  static const Color darkOverlay = Color(0xCC070B19);

  // Text Styles
  static TextStyle titleStyle = const TextStyle(
    fontFamily:
        'Orbitron', // Standard fallback, we will use default sans-serif but stylized if not loaded
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 2.0,
    shadows: [Shadow(blurRadius: 15.0, color: cyanGlow, offset: Offset(0, 0))],
  );

  static TextStyle subtitleStyle = const TextStyle(
    fontSize: 16,
    color: Colors.white70,
    letterSpacing: 1.0,
    fontStyle: FontStyle.italic,
  );

  static TextStyle hudStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    shadows: [
      Shadow(blurRadius: 5.0, color: Colors.black, offset: Offset(2, 2)),
    ],
  );

  static TextStyle scoreStyle = const TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: cyanGlow,
    shadows: [
      Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2)),
    ],
  );

  static TextStyle gameOverStyle = const TextStyle(
    fontSize: 54,
    fontWeight: FontWeight.w900,
    color: asteroidOrange,
    letterSpacing: 3.0,
    shadows: [
      Shadow(blurRadius: 20.0, color: Colors.red, offset: Offset(0, 0)),
    ],
  );

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: cyanGlow,
    foregroundColor: spaceBackground,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    elevation: 8,
    shadowColor: cyanGlow.withValues(alpha: 0.5),
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: const BorderSide(color: Colors.white30, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  );
}
