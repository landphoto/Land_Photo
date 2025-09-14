// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'secrets.dart'; // ??? AppSecrets.supabaseUrl ? AppSecrets.supabaseAnonKey

// ???????
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/comments_screen.dart';
import 'screens/image_viewer.dart';

/// ????? ??????? ???? ????? ????
class AppRoutes {
  static const String splash  = '/';
  static const String login   = '/login';
  static const String signup  = '/signup';
  static const String feed    = '/feed';
  static const String upload  = '/upload';
  static const String profile = '/profile';

  // ???????
  static const String comments = '/comments';
  static const String image    = '/image';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  runApp(LandPhotoApp());
}

class LandPhotoApp extends StatelessWidget {
  LandPhotoApp({super.key}); // ???? const

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Land Photo',
      debugShowCheckedModeBanner: false,

      // ??? ????
      initialRoute: SplashScreen.routeName,

      // ??????? ???????
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        AppRoutes.login:   (_) => const LoginScreen(),
        AppRoutes.signup:  (_) => const SignupScreen(),
        AppRoutes.feed:    (_) => const FeedScreen(),
        AppRoutes.upload:  (_) => const UploadScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },

      // ??????? ???????????
      onGenerateRoute: (settings) {
        // /comments
        if (settings.name == AppRoutes.comments) {
          final args = settings.arguments;
          if (args is Map && args['postId'] is String) {
            return MaterialPageRoute(
              builder: (_) => CommentsScreen(postId: args['postId'] as String),
              settings: settings,
            );
          }
          return _badArgs(settings, "Expected {postId: String}");
        }

        // /image
        if (settings.name == AppRoutes.image) {
          final args = settings.arguments;
          if (args is Map && args['url'] is String && args['heroTag'] is String) {
            return MaterialPageRoute(
              builder: (_) => ImageViewer(
                url: args['url'] as String,
                heroTag: args['heroTag'] as String,
              ),
              settings: settings,
            );
          }
          return _badArgs(settings, "Expected {url: String, heroTag: String}");
        }

        return null;
      },

      theme: ThemeData.dark(),
    );
  }

  MaterialPageRoute _badArgs(RouteSettings settings, String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Bad arguments')),
        body: Center(
          child: Text('$message for route: ${settings.name}'),
        ),
      ),
      settings: settings,
    );
  }
}

// ? SplashScreen ?? routeName
class SplashScreen extends StatefulWidget {
  static const String routeName = AppRoutes.splash; // ?? '/'

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final session = Supabase.instance.client.auth.currentSession;
    if (!mounted) return;
    if (session == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.feed);
    }
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