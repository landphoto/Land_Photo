import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_service.dart';

final _s = Supabase.instance.client;

/// ???? ???????? (Singleton)
class AuthService {
  const AuthService._();
  static const AuthService I = AuthService._();

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _s.auth.signInWithPassword(email: email, password: password);
    await ProfileService.I.ensureRow(); // ????? ?? ?????????
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    final res = await _s.auth.signUp(email: email, password: password);
    if (res.user != null) {
      await ProfileService.I.ensureRow(); // ???? ?? ??????? ???????? ??????
    }
  }

  Future<void> signOut() async {
    await _s.auth.signOut();
  }

  /// ???????? ??????
  User? get currentUser => _s.auth.currentUser;
}