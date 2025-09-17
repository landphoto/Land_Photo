import 'dart:ui';
import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.0, -1.0),
          end: Alignment(1.0, 1.0),
          colors: [
            Color(0xFF0D0B17),
            Color(0xFF141129),
            Color(0xFF1B163A),
            Color(0xFF1E1744),
          ],
        ),
      ),
      child: Stack(
        children: [
          // ???? ??? ?????
          Positioned(
            top: -60,
            right: -60,
            child: _GlowBall(color: const Color(0xFF7E6BFF).withOpacity(.35)),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: _GlowBall(color: const Color(0xFFB494FF).withOpacity(.25)),
          ),
          // ???? ????
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: const SizedBox.expand(),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowBall extends StatelessWidget {
  final Color color;
  const _GlowBall({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}