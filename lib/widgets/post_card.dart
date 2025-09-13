import 'package:flutter/material.dart';
import '../theme.dart';
import '../ui/glass.dart';
import '../services/like_service.dart';
import '../screens/image_viewer.dart';
import '../screens/comments_screen.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onLiked;

  const PostCard({super.key, required this.post, this.onLiked});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _like = LikeService();
  bool _liked = false;
  int _count = 0;
  bool _loading = true;

  @override
  void initState() { super.initState(); _boot(); }

  Future<void> _boot() async {
    final id = widget.post['id'] as int;
    final liked = await _like.isLiked(id);
    final cnt = await _like.countLikes(id);
    if (mounted) setState(() { _liked = liked; _count = cnt; _loading = false; });
  }

  Future<void> _toggle() async {
    if (_loading) return;
    setState(() => _loading = true);
    final id = widget.post['id'] as int;
    await _like.toggleLike(id);
    final liked = await _like.isLiked(id);
    final cnt = await _like.countLikes(id);
    if (mounted) setState(() { _liked = liked; _count = cnt; _loading = false; });
    widget.onLiked?.call();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.post['image_url'] as String? ?? '';
    final caption = widget.post['caption'] as String? ?? '';
    final user = widget.post['profiles']?['username'] as String? ?? '??????';
    final id = widget.post['id'] as int;

    final tag = 'img_$id';

    return Glass(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(radius: 16, backgroundColor: AppColors.mintDim,
              child: Text(user.isNotEmpty ? user[0].toUpperCase() : '?')),
            const SizedBox(width: 8),
            Expanded(child: Text(user, style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600))),
            Text('LandPhoto', style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.mint, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ImageViewer(url: url, heroTag: tag))),
            child: Hero(
              tag: tag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(url, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.black12, alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined))),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(children: [
            IconButton(
              onPressed: _toggle, iconSize: 28, splashRadius: 22,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: _liked
                    ? const Icon(Icons.favorite, key: ValueKey('on'), color: Colors.pinkAccent)
                    : const Icon(Icons.favorite_border, key: ValueKey('off'), color: Colors.white),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text('$_count', key: ValueKey(_count),
                style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CommentsScreen(postId: id))),
              icon: const Icon(Icons.mode_comment_outlined), label: const Text('???????'),
            ),
            const Spacer(),
          ]),

          if (caption.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(caption, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}