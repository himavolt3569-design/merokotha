import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingTheme {
  static const bg = Color(0xFFF7F6F3);
  static const surface = Color(0xFFFFFFFF);
  static const accent = Color(0xFF1C4A3A);
  static const accentMuted = Color(0xFF4A7C6A);
  static const stone = Color(0xFF8C8880);
  static const ink = Color(0xFF1A1917);
  static const hairline = Color(0xFFE8E5E0);

  static TextStyle get displayLg => GoogleFonts.cormorantGaramond(
    fontSize: 38,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: -0.5,
    color: ink,
  );

  static TextStyle get labelSm => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: accentMuted,
  );

  static TextStyle get bodyMd =>
      GoogleFonts.dmSans(fontSize: 13, color: stone, height: 1.5);

  static TextStyle get priceLg => GoogleFonts.cormorantGaramond(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: ink,
    letterSpacing: -0.3,
  );

  static TextStyle get titleMd => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ink,
    letterSpacing: -0.1,
  );

  static const double r = 12.0;
  static const shadow = [
    BoxShadow(color: Color(0x0A1A1917), blurRadius: 16, offset: Offset(0, 4)),
  ];
}
