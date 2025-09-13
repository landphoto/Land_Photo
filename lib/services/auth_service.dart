import 'package:supabase_flutter/supabase_flutter.dart';

final supa = Supabase.instance.client;

class AuthService {
  static Session? get session => supa.auth.currentSession;
  static User? get user => supa.auth.currentUser;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    final res = await supa.auth.signUp(
      email: email,
      password: password,
      data: username == null ? null : {'username': username},
    );

    // أنشئ صف في profiles بعد التسجيل (إن وُجد user)
    final uid = res.user?.id;
    if (uid != null) {
      await supa.from('profiles').upsert({
        'id': uid,
        'username': username ?? email.split('@').first,
        'avatar_url': null,
      });
    }
    return res;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return supa.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() => supa.auth.signOut();

  /// جلب بروفايل المستخدم (إن احتجتها)
  static Future<Map<String, dynamic>?> getMyProfile() async {
    final uid = user?.id;
    if (uid == null) return null;
    final data =
        await supa.from('profiles').select().eq('id', uid).maybeSingle();
    return data;
  }
}