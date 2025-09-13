import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final _s = S.c;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final res = await _s.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
      emailRedirectTo: _emailRedirect,
    );
    final uid = res.user?.id;
    if (uid != null) {
      await _s.from('profiles').upsert({
        'id': uid,
        'username': username,
      });
    }
    return res;
  }

  Future<AuthResponse> signIn(String email, String password) {
    return _s.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _s.auth.signOut();

  String get _emailRedirect =>
      _s.restUrl.replace(path: '/auth/v1/callback').toString();

  User? get currentUser => _s.auth.currentUser;
}