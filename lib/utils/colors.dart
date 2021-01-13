import 'package:flutter/material.dart';
import 'dart:ui';

final Color backgroundColor = Color(0xFFE4E6F1);
final Color firstCircleColor = Colors.white.withOpacity(0.3);
final Color secondCircleColor = Colors.white.withOpacity(0.4);
final Color thirdCircleColor = Colors.white.withOpacity(0.6);

const primaryColor = const Color(0xFFffcb78);
const primaryLight = const Color(0xF4F5F9);
const primaryDark = const Color(0xFFFF9F59);

const secondaryColor = const Color(0xFFFF9F59);
const secondaryLight = const Color(0xFFFF9F59);
const secondaryDark = const Color(0xFFFF9F59);


const Color gradientStart = const Color(0xFFfbab66);
const Color gradientEnd = const Color(0xFFf7418c);

const primaryGradient = const LinearGradient(
  colors: const [gradientStart, gradientEnd],
  stops: const [0.0, 1.0],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const chatBubbleGradient = const LinearGradient(
  colors: const [Color(0xFFFD60A3), Color(0xFFFF8961)],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);

const chatBubbleGradient2 = const LinearGradient(
  colors: const [Color(0xFFf4e3e3), Color(0xFFf4e3e3)],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);
