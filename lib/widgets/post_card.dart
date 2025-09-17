import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../glass.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback onCommentTap;
  const PostCard({super.key, required this.post, required this.onCommentTap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _client = Supabase.instance.client;
  bool _liked = false;
  int _likes = 0;
  int _comments = 0;

  @override
  void initState() {
    super.initState();
    _seedCounts();
  }

  Future<void> _seedCounts() async {
    final postId = widget.post['id'] as String;
    final user = _client.auth.currentUser;

    _likes = (widget.post['likes_count'] ?? 0) as int;
    _comments = (widget.post['comments_count'] ?? 0) as int;

    try {
      if (user != null) {
        final likedRows = await _client
            .from('likes')
            .select('id')
            .eq('post_id', postId)
            .eq('user_id', user.id);
        _liked = likedRows.isNotEmpty;
      }
      if (_likes == 0) {
        final r = await _client
            .from('likes')
            .select('id', const FetchOptions(count: CountOption.exact))
            .eq('post_id', postId);
        _likes = (r.count ?? r.length);
      }
      if (_comments == 0) {
        final r = await _client
            .from('comments')
            .select('id', const FetchOptions(count: CountOption.exact))
            .eq('post_id', postId);
        _comments = (r.count ?? r.length);
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<bool> _toggleLike(bool liked) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('???? ???? ?????')));
      return liked;
    }
    final postId = widget.post['id'] as String;
    try {
      if (!liked) {
        await _client.from('likes').insert({'post_id': postId, 'user_id': user.id});
        setState(() => _likes++);
        return true;
      } else {
        await _client.from('likes').delete().eq('post_id', postId).eq('user_id', user.id);
        setState(() => _likes = (_likes > 0) ? _likes - 1 : 0);
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('??? ????? ???????: $e')));
      return liked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.post['image_url'] as String? ?? '';
    final caption = widget.post['caption'] as String? ?? '';

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (c, w, ev) =>
                      ev == null ? w : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 220,
                    child: Center(child: Text('???? ????? ??????')),
                  ),
                ),
              ),
            ),
          if (caption.isNotEmpty) const SizedBox(height: 8),
          if (caption.isNotEmpty)
            Text(caption, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Row(
            children: [
              LikeButton(
                isLiked: _liked,
                likeCount: _likes,
                size: 30,
                onTap: _toggleLike,
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed: widget.onCommentTap,
                icon: const Icon(Icons.mode_comment_outlined),
                label: Text('$_comments'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Share',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('??????: ?????? ??????')),
                  );
                },
                icon: const Icon(Icons.share_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}