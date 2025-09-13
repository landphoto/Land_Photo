import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F1115), Color(0xFF16202A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _c,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LandPhoto',
                    style: GoogleFonts.poppins(
                      fontSize: 44, fontWeight: FontWeight.w800,
                      color: AppColors.mint, letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Glassy Social Moments', style: t.titleMedium?.copyWith(color: AppColors.hint)),
                  const SizedBox(height: 32),
                  const SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}