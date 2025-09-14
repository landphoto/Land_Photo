import 'package:supabase_flutter/supabase_flutter.dart';

class LikeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// ????? ??? ???????? ?????? (???? CountOption ? ???? ??????)
  Future<int> countLikes(String postId) async {
    final res = await _supabase
        .from('likes')
        .select('id')      // ???? IDs ???
        .eq('post_id', postId);

    // select ????? List<dynamic>
    return (res as List).length;
  }

  /// ?? ???????? ?????? ???? ???? ???? ????????
  Future<bool> likedByMe(String postId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final res = await _supabase
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', user.id)
        .limit(1);

    return res.isNotEmpty;
  }

  /// ??? ???? ?????? (??? ????? ?????? ??? ??? ????? ??????)
  Future<void> toggleLike(String postId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final exists = await _supabase
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', user.id)
        .limit(1);

    if (exists.isNotEmpty) {
      await _supabase
          .from('likes')
          .delete()
          .match({'post_id': postId, 'user_id': user.id});
    } else {
      await _supabase.from('likes').insert({
        'post_id': postId,
        'user_id': user.id,
      });
    }
  }
}