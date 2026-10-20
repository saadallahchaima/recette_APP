import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette Mijou, relevée dans le design Figma.
class Pal {
  static const bg = Color(0xFFFFF2F7);
  static const cream = Color(0xFFFFF9EE);
  static const primary = Color(0xFFC73568);
  static const ink = Color(0xFF7A2747);
  static const inkSoft = Color(0xFF8D4860);
  static const pale = Color(0xFFFFE3ED);
  static const chip = Color(0xFFFFF1F5);
  static const border = Color(0xFFF3C9D9);
  static const card = Color(0xFFFFF7F8);
  static const field = Color(0xFFFFF8FB);
  static const cheek = Color(0xFFFF9DBB);
  static const greenInk = Color(0xFF31624A);
  static const greenDeep = Color(0xFF2F7A5A);
  static const greenBg = Color(0xFFE5F5EB);
  static const greenBox = Color(0xFFEAF8F0);
  static const peach = Color(0xFFFFF1E8);
  static const timerBg = Color(0xFFFFE1CF);
}

/// Style de texte Nunito (Medium 500, SemiBold 600, ExtraBold 800, Black 900).
TextStyle ts(
  double size, {
  FontWeight w = FontWeight.w500,
  Color color = Pal.ink,
  double? h,
  TextDecoration? deco,
}) =>
    GoogleFonts.nunito(
      fontSize: size,
      fontWeight: w,
      color: color,
      height: h,
      decoration: deco,
    );

const shadowSoft = [
  BoxShadow(color: Color(0x14C73568), blurRadius: 12, offset: Offset(0, 4)),
];

const shadowNav = [
  BoxShadow(color: Color(0x29C73568), blurRadius: 18, offset: Offset(0, 6)),
];

const shadowTimer = [
  BoxShadow(color: Color(0x26D46A8A), blurRadius: 24, offset: Offset(0, 10)),
];
