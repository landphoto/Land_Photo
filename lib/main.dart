import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/comment_composer.dart';
import 'screens/upload_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LandPhotoApp());
}

class LandPhotoApp extends StatelessWidget {
  const LandPhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        // ???? ????? ?????? (???????)
        GoRoute(path: '/', builder: (_, __) => const LoginScreen()),

        // ???? ???Feed
        GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),

        // ???? ?????????
        GoRoute(path: '/comment', builder: (_, __) => const CommentComposer()),

        // ???? ??? ????
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