import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  // ???? ?????? ??? ???????? ??????
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // ??? ????? ???? ??? ???? ???????
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final session = Supabase.instance.client.auth.currentSession;

    // ????? ?????? ?????? ?????? ?????
    final String nextRoute = (session == null) ? '/login' : '/feed';

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}