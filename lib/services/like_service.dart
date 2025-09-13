import 'supabase_service.dart';

class LikeService {
  final _s = S.c;

  Future<bool> isLiked(int postId) async {
    final uid = _s.auth.currentUser!.id;
    final rows = await _s
        .from('likes')
        .select('post_id')
        .eq('post_id', postId)
        .eq('user_id', uid);
    return rows.isNotEmpty;
  }

  Future<int> countLikes(int postId) async {
    final rows = await _s
        .from('likes')
        .select('post_id', const FetchOptions(count: CountOption.exact))
        .eq('post_id', postId);
    return rows.count ?? 0;
  }

  Future<void> toggleLike(int postId) async {
    final uid = _s.auth.currentUser!.id;
    final liked = await isLiked(postId);
    if (liked) {
      await _s.from('likes').delete().eq('post_id', postId).eq('user_id', uid);
    } else {
      await _s.from('likes').insert({'post_id': postId, 'user_id': uid});
    }
  }
}