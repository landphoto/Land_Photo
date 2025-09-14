// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ?????? ??????? ?? ??? secrets.dart
import 'secrets.dart';

// ???????
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/comments_screen.dart';
import 'screens/image_viewer.dart';

/// ????? ???????? ???????? ? ?? ????? ????? ??? ???? ?????.
class RouteNames {
  static const splash   = '/splash';
  static const login    = '/login';
  static const signup   = '/signup';
  static const feed     = '/feed';
  static const upload   = '/upload';
  static const profile  = '/profile';
  static const comments = '/comments'; // ????? postId
  static const image    = '/image';    // ????? url
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ????? Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const LandPhotoApp());
}

class LandPhotoApp extends StatelessWidget {
  const LandPhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Land Photo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF54DFC9),
        useMaterial3: true,
      ),
      initialRoute: RouteNames.splash,

      // routes ???? ?? ????? arguments
      routes: {
        RouteNames.splash:  (_) => const SplashScreen(),
        RouteNames.login:   (_) => const LoginScreen(),
        RouteNames.signup:  (_) => const SignupScreen(),
        RouteNames.feed:    (_) => const FeedScreen(),
        RouteNames.upload:  (_) => const UploadScreen(),
        RouteNames.profile: (_) => const ProfileScreen(),
      },

      // ??????? ???? ????? arguments (comments, image)
      onGenerateRoute: (settings) {
        if (settings.name == RouteNames.comments) {
          final args = (settings.arguments ?? {}) as Map;
          final postId = args['postId'];
          return MaterialPageRoute(
            builder: (_) => CommentsScreen(postId: postId),
          );
        }
        if (settings.name == RouteNames.image) {
          final args = (settings.arguments ?? {}) as Map;
          final url = args['url'] as String;
          return MaterialPageRoute(
            builder: (_) => ImageViewer(url: url),
          );
        }
        // fallback
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      },
    );
  }
}