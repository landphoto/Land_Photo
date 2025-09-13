import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/upload_screen.dart';
import 'theme.dart';
import 'secrets.dart'; // ???? ????

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const LandPhotoApp());
}

class LandPhotoApp extends StatefulWidget {
  const LandPhotoApp({Key? key}) : super(key: key);
  @override
  State<LandPhotoApp> createState() => _LandPhotoAppState();
}

class _LandPhotoAppState extends State<LandPhotoApp> {
  late final StreamSubscription<AuthState> _authSub;
  late final Stream<List<ConnectivityResult>> _connStream;
  final ValueNotifier<bool> _isOffline = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      // ??????? ?????? ?? ????? ???? ????????
      setState(() {});
    });

    _connStream = Connectivity().onConnectivityChanged;
    _connStream.listen((results) {
      final offline =
          results.isEmpty || results.first == ConnectivityResult.none;
      _isOffline.value = offline;
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLogged = Supabase.instance.client.auth.currentSession != null;

    final router = GoRouter(
      initialLocation: isLogged ? '/feed' : '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
        GoRoute(path: '/upload', builder: (_, __) => const UploadScreen()),
      ],
      redirect: (context, state) {
        final logged = Supabase.instance.client.auth.currentSession != null;
        final loggingIn = state.uri.toString() == '/';
        if (!logged && !loggingIn) return '/';
        if (logged && loggingIn) return '/feed';
        return null;
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
                body: Center(child: Text('?? ???? ????? ?????????')),
              );
            }
            return child!;
          },
        );
      },
    );
  }
}