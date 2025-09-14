import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'secrets.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/comments_screen.dart';
import 'screens/image_viewer.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String feed = '/feed';
  static const String upload = '/upload';
  static const String profile = '/profile';
  static const String comments = '/comments';
  static const String image = '/image';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF18C2A5)),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signup: (_) => const SignupScreen(),
        AppRoutes.feed: (_) => const FeedScreen(),
        AppRoutes.upload: (_) => const UploadScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.comments:
            final args = settings.arguments;
            if (args is String) {
              return MaterialPageRoute(
                builder: (_) => CommentsScreen(postId: args),
                settings: settings,
              );
            }
            return _badArgs('Expected a String postId for /comments');

          case AppRoutes.image:
            final args = settings.arguments;
            if (args is Map) {
              final url = args['url'] as String?;
              final heroTag = args['heroTag'] as String?;
              if (url == null || url.isEmpty) {
                return _badArgs('Expected a non-empty "url" for /image');
              }
              return MaterialPageRoute(
                builder: (_) => ImageViewer(url: url, heroTag: heroTag),
                settings: settings,
              );
            }
            return _badArgs('Expected {url:String, heroTag?:String} for /image');

          default:
            return null;
        }
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  MaterialPageRoute _badArgs(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Route error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}