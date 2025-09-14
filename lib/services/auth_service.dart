import 'package:supabase_flutter/supabase_flutter.dart';
import '../secrets.dart';
import 'supabase_service.dart';

class AuthService {
  final _s = SupaService.I.client;

  Session? get session => _s.auth.currentSession;
  User? get user => _s.auth.currentUser;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final res = await _s.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    // ????/???? ???????
    final uid = res.user?.id;
    if (uid != null) {
      await _s.from('profiles').upsert({
        'id': uid,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    return res;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) =>
      _s.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _s.auth.signOut();

  Future<Map<String, dynamic>?> getProfile() async {
    final uid = user?.id;
    if (uid == null) return null;
    final data =
        await _s.from('profiles').select().eq('id', uid).maybeSingle();
    return data;
  }
}