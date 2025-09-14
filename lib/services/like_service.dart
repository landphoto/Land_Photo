import 'package:supabase_flutter/supabase_flutter.dart';

class LikeService {
  final supabase = Supabase.instance.client;

  /// ????? ???? ????
  Future<void> addLike(String postId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('likes').insert({
      'post_id': postId,
      'user_id': user.id,
    });
  }

  /// ??? ??????
  Future<void> removeLike(String postId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('likes')
        .delete()
        .match({'post_id': postId, 'user_id': user.id});
  }

  /// ?????? ??? ???????? ?????? ???? ????
  Future<bool> hasLiked(String postId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    final res = await supabase
        .from('likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', user.id);

    return res.isNotEmpty;
  }

  /// ??? ??? ???????? ??????
  Future<int> getLikesCount(String postId) async {
    final res = await supabase
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .withCount(CountOption.exact); // ? ??? ??????

    return res.count ?? 0;
  }
}