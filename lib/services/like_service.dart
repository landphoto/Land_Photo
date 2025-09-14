import 'package:supabase_flutter/supabase_flutter.dart';

class LikeService {
  final _s = Supabase.instance.client;

  Future<int> countLikes(String postId) async {
    final res = await _s.from('likes')
        .select('id')
        .eq('post_id', postId);
    return (res as List).length;
  }

  Future<bool> likedByMe(String postId) async {
    final user = _s.auth.currentUser;
    if (user == null) return false;
    final res = await _s.from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', user.id)
        .limit(1);
    return res.isNotEmpty;
  }

  Future<void> toggleLike(String postId) async {
    final user = _s.auth.currentUser;
    if (user == null) return;

    final exists = await _s.from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', user.id)
        .limit(1);

    if (exists.isNotEmpty) {
      await _s.from('likes').delete()
          .match({'post_id': postId, 'user_id': user.id});
    } else {
      await _s.from('likes').insert({'post_id': postId, 'user_id': user.id});
    }
  }
}