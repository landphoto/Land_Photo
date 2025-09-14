import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _s = Supabase.instance.client;

  Future<void> ensureRow() async {
    final uid = _s.auth.currentUser?.id;
    if (uid == null) return;
    await _s.from('profiles').upsert({'id': uid}, onConflict: 'id');
  }

  Future<Map<String, dynamic>?> readMe() async {
    final uid = _s.auth.currentUser?.id;
    if (uid == null) return null;

    return await _s.from('profiles')
        .select('id, username, avatar_url, updated_at')
        .eq('id', uid)
        .maybeSingle();
  }

  Future<void> updateUsername(String name) async {
    final uid = _s.auth.currentUser?.id;
    if (uid == null) return;
    await _s.from('profiles')
        .update({'username': name, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', uid);
  }

  Future<void> updateAvatarUrl(String url) async {
    final uid = _s.auth.currentUser?.id;
    if (uid == null) return;
    await _s.from('profiles')
        .update({'avatar_url': url, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', uid);
  }
}