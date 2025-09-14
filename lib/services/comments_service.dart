import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsService {
  final _s = Supabase.instance.client;

  Future<List<dynamic>> fetchComments(String postId) async {
    final rows = await _s
        .from('comments')
        .select(
          'id, content, user_id, created_at, profiles(username, avatar_url)',
        )
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return rows as List<dynamic>;
  }

  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    final userId = _s.auth.currentUser!.id;
    final inserted = await _s.from('comments').insert({
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();
    return inserted as Map<String, dynamic>;
  }
}