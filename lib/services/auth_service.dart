import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_service.dart';

class AuthService {
  final _s = Supabase.instance.client;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _s.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _s.auth.signUp(email: email, password: password);
    // ???? ???? ??? ???????? ?? profiles
    await ProfileService().ensureRow();
  }

  Future<void> signOut() async {
    await _s.auth.signOut();
  }
}