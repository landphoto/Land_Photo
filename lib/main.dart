import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/upload_screen.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();        // ????? Supabase
  runApp(const LandPhotoApp());
}

class LandPhotoApp extends StatelessWidget {
  const LandPhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/', // ?? ????? ???? ?????? ??? feed
      redirect: (ctx, state) {
        final session = Supabase.instance.client.auth.currentSession;
        final loggingIn = state.fullPath == '/';
        if (session == null && !loggingIn) return '/';
        if (session != null && loggingIn) return '/feed';
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
        GoRoute(path: '/upload', builder: (_, __) => const UploadScreen()),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      routerConfig: router,
    );
  }
}