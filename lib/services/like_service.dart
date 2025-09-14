import 'package:supabase_flutter/supabase_flutter.dart';

class LikeService {
  final _s = Supabase.instance.client;

  Future<int> countLikes(String postId) async {
    final res = await _s
        .from('likes')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('post_id', postId);

    return res.count ?? 0;
  }

  Future<bool> likedByMe(String postId) async {
    final userId = _s.auth.currentUser!.id;

    final res = await _s
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId);

    return res.isNotEmpty;
  }

  Future<void> toggleLike(String postId) async {
    final userId = _s.auth.currentUser!.id;

    final liked = await likedByMe(postId);

    if (liked) {
      await _s.from('likes').delete().match({
        'post_id': postId,
        'user_id': userId,
      });
    } else {
      await _s.from('likes').insert({
        'post_id': postId,
        'user_id': userId,
      });
    }
  }
}