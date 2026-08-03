import 'package:flutter/material.dart';

class AppSizes {
  AppSizes._();

  // Spacing
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  // Border radius
  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const radiusXl = 24.0;
  static const radiusFull = 999.0;

  // Shadows — soft, realistic, low-elevation (premium look, no harsh drop shadows)
  static const shadowCard = [
    BoxShadow(color: Color(0x0F1A1A18), blurRadius: 20, offset: Offset(0, 6)),
  ];
  static const shadowRaised = [
    BoxShadow(color: Color(0x141A1A18), blurRadius: 24, offset: Offset(0, 10)),
  ];

  // Icon sizes
  static const iconSm = 16.0;
  static const iconMd = 20.0;
  static const iconLg = 24.0;
  static const iconXl = 32.0;

  // Component heights
  static const buttonHeight = 52.0;
  static const inputHeight = 52.0;
  static const appBarHeight = 56.0;
  static const bottomNavHeight = 64.0;
  static const listingCardHeight = 220.0;

  // Padding
  static const pagePadding = 20.0;
  static const cardPadding = 16.0;

  // Avatar
  static const avatarSm = 32.0;
  static const avatarMd = 44.0;
  static const avatarLg = 64.0;
}
