// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'secrets.dart'; // ????? const supabaseUrl ? supabaseAnonKey
import 'theme.dart';

import 'screens/login_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/upload_screen.dart'; // ????? ???? ??? ????????

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ????? Supabase ?????? ??????? ?? secrets.dart
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const LandPhotoApp());
}

class LandPhotoApp extends StatefulWidget {
  const LandPhotoApp({super.key});

  @override
  State<LandPhotoApp> createState() => _LandPhotoAppState();
}

class _LandPhotoAppState extends State<LandPhotoApp> {
  late final GoRouter _router;
  final ValueNotifier<bool> _isOffline = ValueNotifier<bool>(false);
  late final Stream<ConnectivityResult> _connStream;

  @override
  void initState() {
    super.initState();

    // ????? ???????
    _router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
        GoRoute(path: '/upload', builder: (_, __) => const UploadScreen()),
      ],
      // (???????) ????? ??????? ????? ??? ???? ??????
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        final loggingIn = state.subloc == '/';
        if (session == null && !loggingIn) return '/';
        if (session != null && loggingIn) return '/feed';
        return null;
      },
      // ????? ?????? ??? ????? ???? ????????
      refreshListenable: SupabaseAuthRefresh(),
    );

    // ?????? ??????? ???? ????? ??? ???? ??????
    _connStream = Connectivity().onConnectivityChanged;
    _connStream.listen((result) {
      final offline = result == ConnectivityResult.none;
      if (_isOffline.value != offline) {
        _isOffline.value = offline;
      }
    });
  }

  @override
  void dispose() {
    _isOffline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      routerConfig: _router,
      // ???? ???? ??? ???? ?????? ???? ???? ???????
      builder: (context, child) {
        return Directionality( // ???? ??????? ?????????
          textDirection: TextDirection.rtl,
          child: Stack(
            children: [
              if (child != null) child,
              ValueListenableBuilder<bool>(
                valueListenable: _isOffline,
                builder: (context, offline, _) {
                  if (!offline) return const SizedBox.shrink();
                  return const _OfflineBanner();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ????? ????? ???? ???? ????? ??? ???????
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.red.withOpacity(.90),
        elevation: 2,
        child: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Text(
              '?? ???? ????? ?????????',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

/// ???? ???? ?????? ???? ??????? ????? ????? ???? ???? Supabase
class SupabaseAuthRefresh extends ChangeNotifier {
  SupabaseAuthRefresh() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}