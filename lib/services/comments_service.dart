import 'package:supabase_flutter/supabase_flutter.dart';

final _s = Supabase.instance.client;

/// ??? ????????? ?? ?????? ????????
class CommentService {
  const CommentService._();
  static const CommentService I = CommentService._();

  Future<List<Map<String, dynamic>>> fetchForPost(String postId) async {
    final rows = await _s
        .from('comments')
        .select(
          'id, content, user_id, created_at, profiles(username, avatar_url)',
        )
        .eq('post_id', postId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }
}