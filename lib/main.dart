// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'secrets.dart'; // <-- ??? ????: ???? supabaseUrl & supabaseAnonKey
import 'theme.dart';
import 'bootstrap/ensure_profile_row.dart';

// ???????
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/comments_screen.dart';
import 'screens/image_viewer.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ????? Supabase ?? ?????? secrets.dart
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    // optional: persistSession: true,
    // optional: authFlowType: AuthFlowType.pkce,
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
      navigatorKey: navigatorKey,
      theme: buildTheme(), // ?? theme.dart

      // ???? SplashScreen ?? ??????? ??? ???? ???? ????? ???????? ????
      initialRoute: SplashScreen.routeName,

      // routes ????? ???????? ? ?? ?????? '/home' ??? ?? ???? ????? ??????
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignupScreen.routeName: (_) => const SignupScreen(),
        FeedScreen.routeName: (_) => const FeedScreen(),
        UploadScreen.routeName: (_) => const UploadScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        CommentsScreen.routeName: (_) => const CommentsScreen(),
        ImageViewer.routeName: (_) => const ImageViewer(),
      },

      // ?? ??? ??????? Route ?? ?????? ????? ??? Splash
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const SplashScreen(),
        settings: const RouteSettings(name: SplashScreen.routeName),
      ),
    );
  }
}