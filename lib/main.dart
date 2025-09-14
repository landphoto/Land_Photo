// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'secrets.dart'; // ??? ????? ??? url ???? anonKey
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ????? Supabase ???????? ????? ?? secrets.dart
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorSchemeSeed: const Color(0xFF66E0CC),
      brightness: Brightness.dark,
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: UnderlineInputBorder(),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Land Photo',
      theme: theme,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/home': (_) => const HomeScreen(),
      },
      initialRoute: '/login',
    );
  }
}

/// ???? ?????? ????? ??? ????? ??????
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome ${user?.email ?? ""}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (r) => false);
                }
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}