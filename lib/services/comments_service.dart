import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsService {
  CommentsService._();
  static final I = CommentsService._();
  final _c = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetch(String postId) async {
    final rows = await _c
        .from('comments')
        .select('id, content, user_id, created_at, profiles(username, avatar_url)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<void> add(String postId, String content) async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) return;
    await _c.from('comments').insert({'post_id': postId, 'content': content, 'user_id': uid});
  }
}