import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_service.dart';

class AuthService {
  final _s = Supabase.instance.client;

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _s.auth.signUp(email: email, password: password);

    // === ????? ???? ????? ===
    final _p = ProfileService();
    await _p.ensureRow();

    if (res.session == null && _s.auth.currentUser == null) {
      // ?????? ????? ????? ???? ? ?? ??? ????? ???
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _s.auth.signInWithPassword(email: email, password: password);

    // === ????? ???? ????? ===
    final _p = ProfileService();
    await _p.ensureRow();
  }

  Future<void> signOut() async {
    await _s.auth.signOut();
  }

  String? get currentUserId => _s.auth.currentUser?.id;
  String? get currentEmail  => _s.auth.currentUser?.email;
}