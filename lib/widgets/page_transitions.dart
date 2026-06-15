import 'package:flutter/material.dart';

// Fungsi global untuk transisi Fade & Scale yang super smooth
Route createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      return FadeTransition(opacity: curve, child: child);
    },
    transitionDuration: const Duration(milliseconds: 600),
  );
}
