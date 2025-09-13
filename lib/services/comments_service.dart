import 'supabase_service.dart';

class CommentsService {
  final _s = S.c;

  Future<List<Map<String, dynamic>>> list(int postId) async {
    final res = await _s
        .from('comments')
        .select('id, content, created_at, user_id, profiles(username, avatar_url)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> add(int postId, String content) async {
    final uid = _s.auth.currentUser!.id;
    await _s.from('comments').insert({
      'post_id': postId,
      'user_id': uid,
      'content': content,
    });
  }

  RealtimeChannel subscribe(int postId, void Function() onChange) {
    final ch = _s
        .channel('comments_post_$postId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'comments',
          filter: PostgresChangeFilter('post_id=eq.$postId'),
          callback: (_) => onChange(),
        )
        .subscribe();
    return ch;
  }
}