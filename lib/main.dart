import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'secrets.dart'; // AppSecrets.supabaseUrl / AppSecrets.supabaseAnonKey
import 'theme.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/comments_screen.dart';
import 'screens/image_viewer.dart';

/// ????? ?????? ????? ????? ????
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const feed = '/feed';
  static const upload = '/upload';
  static const profile = '/profile';

  // ???? ????? ??????????: ?????? onGenerateRoute ???
  static const comments = '/comments'; // args: { "postId": String }
  static const image = '/image';       // args: { "url": String, "heroTag": String }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ?? Supabase init ???????? AppSecrets
  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
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

      // ?????? Splash ?? home ????? ?? initialRoute ?????? ????? routeName
      home: const SplashScreen(),

      // ???? ???? ??????????
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signup: (_) => const SignupScreen(),
        AppRoutes.feed: (_) => const FeedScreen(),
        AppRoutes.upload: (_) => const UploadScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },

      // ???? ????? ??????????
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.comments) {
          final args = settings.arguments;
          if (args is Map && args['postId'] is String) {
            return MaterialPageRoute(
              builder: (_) => CommentsScreen(postId: args['postId'] as String),
              settings: settings,
            );
          }
          return _badArgs(settings, 'Expected { "postId": String }');
        }

        if (settings.name == AppRoutes.image) {
          final args = settings.arguments;
          if (args is Map && args['url'] is String) {
            final url = args['url'] as String;
            final heroTag = (args['heroTag'] ?? '') as String; // ??? ????????? ????? heroTag
            return MaterialPageRoute(
              builder: (_) => ImageViewer(url: url, heroTag: heroTag),
              settings: settings,
            );
          }
          return _badArgs(settings, 'Expected { "url": String, "heroTag"?: String }');
        }

        // ??? ?? route ??? ?????
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
          settings: settings,
        );
      },

      // ??? ??????? (?? ???? buildTheme ?? theme.dart)
      theme: ThemeData.dark(),
    );
  }

  // ???? ??? ????? ??? ????? ?????????? ?????
  Route _badArgs(RouteSettings s, String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Navigation error')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Route "${s.name}" arguments error:\n$message'),
        ),
      ),
      settings: s,
    );
  }
}