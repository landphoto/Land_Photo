import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _s = Supabase.instance.client;

  /// ???? ?? ?? profiles ??? ?? ?????
  Future<void> ensureRow() async {
    final u = _s.auth.currentUser;
    if (u == null) return;

    final exists = await _s
        .from('profiles')
        .select('id')
        .eq('id', u.id)
        .limit(1);

    if (exists.isEmpty) {
      await _s.from('profiles').insert({
        'id': u.id,
        'username': (u.email ?? '').split('@').first,
        'avatar_url': null,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> updateProfile({String? username, String? avatarUrl}) async {
    final u = _s.auth.currentUser;
    if (u == null) return;

    await _s.from('profiles').update({
      if (username != null) 'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    }).eq('id', u.id);
  }

  /// ???? ????????? ?? ?????? ???? ??????? (username, avatar_url)
  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    final rows = await _s
        .from('comments')
        .select(
            'id, content, user_id, created_at, profiles(username, avatar_url)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(rows);
  }
}