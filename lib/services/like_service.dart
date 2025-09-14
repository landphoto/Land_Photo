import 'package:supabase_flutter/supabase_flutter.dart';

class LikeService {
  final _s = Supabase.instance.client;

  Future<int> countLikes(String postId) async {
    final rows = await _s
        .from('likes')
        .select('id')
        .eq('post_id', postId);
    // ???? ????? ?????? ????? ????? count/head/FetchOptions
    return (rows as List).length;
  }

  Future<bool> likedByMe(String postId) async {
    final userId = _s.auth.currentUser!.id;
    final rows = await _s
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .limit(1);
    return (rows as List).isNotEmpty;
  }

  Future<void> toggleLike(String postId) async {
    final userId = _s.auth.currentUser!.id;
    final isLiked = await likedByMe(postId);

    if (isLiked) {
      await _s.from('likes').delete().match({
        'post_id': postId,
        'user_id': userId,
      });
    } else {
      await _s.from('likes').insert({
        'post_id': postId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}