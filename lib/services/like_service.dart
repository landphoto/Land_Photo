import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class LikeService {
  final _s = SupaService.I.client;

  Future<int> countLikes(String postId) async {
    final res = await _s
        .from('likes')
        .select('post_id', const FetchOptions(count: CountOption.exact))
        .eq('post_id', postId);
    return (res.count ?? 0);
  }

  Future<void> toggleLike(String postId) async {
    final uid = _s.auth.currentUser!.id;
    final existing = await _s
        .from('likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', uid)
        .maybeSingle();

    if (existing == null) {
      await _s.from('likes').insert({'post_id': postId, 'user_id': uid});
    } else {
      await _s.from('likes').delete().eq('id', existing['id']);
    }
  }

  Future<bool> likedByMe(String postId) async {
    final uid = _s.auth.currentUser!.id;
    final row = await _s
        .from('likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', uid)
        .maybeSingle();
    return row != null;
  }
}