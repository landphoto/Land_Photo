import 'package:supabase_flutter/supabase_flutter.dart';

class LikeService {
  final _s = Supabase.instance.client;

  /// ???? ??? ???????? ??????
  Future<int> countLikes(String postId) async {
    final res = await _s
        .from('likes')
        .select('id', count: CountOption.exact) // ? ??? ??????
        .eq('post_id', postId);

    return res.count ?? 0;
  }

  /// ????? ??? ???????? ?????? ???? ????
  Future<bool> likedByMe(String postId) async {
    final uid = _s.auth.currentUser?.id;
    if (uid == null) return false;

    final res = await _s
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', uid)
        .maybeSingle();

    return res != null;
  }

  /// ????? ???? ?????? (????? ?? ???)
  Future<void> toggleLike(String postId) async {
    final uid = _s.auth.currentUser?.id;
    if (uid == null) return;

    final existing = await _s
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', uid)
        .maybeSingle();

    if (existing == null) {
      // ??? ????
      await _s.from('likes').insert({
        'post_id': postId,
        'user_id': uid,
      });
    } else {
      // ???? ??????
      await _s.from('likes').delete().eq('id', existing['id']);
    }
  }
}