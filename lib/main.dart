import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'secrets.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/feed_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const LandPhotoApp());
}

class LandPhotoApp extends StatefulWidget {
  const LandPhotoApp({super.key});
  @override
  State<LandPhotoApp> createState() => _LandPhotoAppState();
}

class _LandPhotoAppState extends State<LandPhotoApp> {
  final _auth = AuthService();
  bool _booted = false;

  @override
  void initState() { super.initState(); _boot(); }
  Future<void> _boot() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _booted = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LandPhoto',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: !_booted
          ? const SplashScreen()
          : (_auth.currentUser == null ? const LoginScreen() : const FeedScreen()),
    );
  }
}