import 'dart:async'; // ??? ??? StreamSubscription
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'screens/feed_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const LandPhotoApp());
}

class LandPhotoApp extends StatefulWidget {
  const LandPhotoApp({Key? key}) : super(key: key);

  @override
  State<LandPhotoApp> createState() => _LandPhotoAppState();
}

class _LandPhotoAppState extends State<LandPhotoApp> {
  late final StreamSubscription<AuthState> _sub;
  late final Stream<List<ConnectivityResult>> _connStream;
  final ValueNotifier<bool> _isOffline = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    // Auth subscription
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      // ????? ???? ??????? ?? ??????? ?? auth
    });

    // Connectivity stream
    _connStream = Connectivity().onConnectivityChanged;
    _connStream.listen((results) {
      final offline = results.isEmpty || results.first == ConnectivityResult.none;
      _isOffline.value = offline;
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
      ],
      redirect: (context, state) {
        final loggingIn = state.uri.toString() == '/';
        return loggingIn ? null : '/';
      },
    );

    return ValueListenableBuilder<bool>(
      valueListenable: _isOffline,
      builder: (context, offline, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(),
          routerConfig: router,
          builder: (context, child) {
            if (offline) {
              return const Scaffold(
                body: Center(
                  child: Text("?? ???? ????? ?????????"),
                ),
              );
            }
            return child!;
          },
        );
      },
    );
  }
}