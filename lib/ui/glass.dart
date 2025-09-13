import 'dart:ui';
import 'package:flutter/material.dart';

class Glass extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsets padding;
  final BorderRadius radius;
  final Gradient? gradient;

  const Glass({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = .08,
    this.padding = const EdgeInsets.all(14),
    this.radius = const BorderRadius.all(Radius.circular(20)),
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final g = gradient ?? LinearGradient(
      colors: [
        Colors.white.withOpacity(opacity + .04),
        Colors.white.withOpacity(opacity),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: g,
            border: Border.all(color: Colors.white.withOpacity(.12), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.35),
                blurRadius: 24,
                spreadRadius: -6,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}