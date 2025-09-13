import 'package:flutter/material.dart';

class GradientBg extends StatelessWidget {
  final Widget child;
  const GradientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          radius: 1.2,
          center: Alignment(-.6, -.8),
          colors: [ Color(0xFF11202B), Color(0xFF0B0F14) ],
        ),
      ),
      child: child,
    );
  }
}