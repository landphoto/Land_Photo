import 'package:supabase_flutter/supabase_flutter.dart';

final _s = Supabase.instance.client;

/// ???? ????????
class LikeService {
  const LikeService._();
  static const LikeService I = LikeService._();

  /// ??? ???????? ??????
  Future<int> countLikes(String postId) async {
    final res = await _s
        .from('likes')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('post_id', postId);
    return (res.count ?? 0);
  }

  /// ?? ??? ???? ???? ????????
  Future<bool> likedByMe(String postId) async {
    final uid = _s.auth.currentUser?.id;
    if (uid == null) return false;

    final row = await _s
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', uid)
        .maybeSingle();
    return row != null;
  }

  /// ???/????? ???
  Future<bool> toggleLike(String postId) async {
    final uid = _s.auth.currentUser?.id;
    if (uid == null) throw Exception('Not signed in');

    final existing = await _s
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', uid)
        .maybeSingle();

    if (existing == null) {
      await _s.from('likes').insert({'post_id': postId, 'user_id': uid});
      return true; // ??? ????
    } else {
      await _s.from('likes').delete().eq('id', existing['id']);
      return false; // ????? ??????
    }
  }
}