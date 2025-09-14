import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';
import 'feed_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ????? ??????? ??? ??? ??? ???? ??? ?? ???? ????? ?? ??? Navigator
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final client = Supabase.instance.client;

    try {
      // ????? ????? ?????? ??? ?????? (???????)
      await client.auth.refreshSession();
    } catch (_) {
      // ????? ?? ??? ????? ????
    }

    final session = client.auth.currentSession;

    // ??? ???????? ?????? ??? ?????? ??? ??? ??? ??????
    final String next =
        (session == null) ? LoginScreen.routeName : FeedScreen.routeName;

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(next, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}