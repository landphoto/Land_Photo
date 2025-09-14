// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart'; // <-- ??? ?????

class SplashScreen extends StatefulWidget {
  static const String routeName = AppRoutes.splash; // '/'
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    // ??? ???? ???????? ???? + ???? ?????? ???
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final session = Supabase.instance.client.auth.currentSession;
    final nextRoute = (session == null) ? AppRoutes.login : AppRoutes.feed;

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}