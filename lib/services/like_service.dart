import 'package:supabase_flutter/supabase_flutter.dart';

class LikeService {
  LikeService._();
  static final I = LikeService._();
  final _c = Supabase.instance.client;

  Future<void> toggleLike(String postId) async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) return;

    final exists = await _c
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', uid)
        .maybeSingle();

    if (exists != null) {
      await _c.from('likes').delete().eq('id', exists['id']);
    } else {
      await _c.from('likes').insert({'post_id': postId, 'user_id': uid});
    }
  }

  Future<int> countLikes(String postId) async {
    // ????? ????? ??????? supabase ?????? ????
    final rows = await _c.from('likes').select('id').eq('post_id', postId);
    return (rows as List).length;
    // ???? (?? ??? ???????): .select('id', count: CountOption.exact)
  }

  Future<bool> likedByMe(String postId) async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) return false;
    final row = await _c
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', uid)
        .maybeSingle();
    return row != null;
  }
}