import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ????? ????? ?? ????? ???? + ????? ???? + ??????? ??? ????.
/// ???????? ?? ???? ??????? ????? ??????:
///   id  | image_url (?? url) | title (???????) | caption (???????)
class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post});

  final Map<String, dynamic> post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  final _s = Supabase.instance.client;

  int _likeCount = 0;
  bool _likedByMe = false;
  bool _busy = false;

  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
    _heartScale = CurvedAnimation(parent: _heartCtrl, curve: Curves.easeOutBack);

    _loadLikeState();
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post['id'] != widget.post['id']) {
      _loadLikeState();
    }
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  String get _postId => widget.post['id'].toString();

  Future<void> _loadLikeState() async {
    final uid = _s.auth.currentUser?.id;
    if (!mounted) return;

    try {
      // ??????? (????? ?????: ???? ids ?? ????? ?????)
      final rows = await _s
          .from('likes')
          .select('id')
          .eq('post_id', _postId);

      final likedRows = uid == null
          ? const []
          : await _s
              .from('likes')
              .select('id')
              .eq('post_id', _postId)
              .eq('user_id', uid);

      if (!mounted) return;
      setState(() {
        _likeCount = (rows as List).length;
        _likedByMe = (likedRows as List).isNotEmpty;
      });
    } catch (_) {
      // ????? ????? ?? ???? Snackbar ??? ?????
    }
  }

  Future<void> _toggleLike() async {
    if (_busy) return;
    final uid = _s.auth.currentUser?.id;
    if (uid == null) {
      // ???? ????? ???????? ????? ????? ??????
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('???? ???? ?????? ?? ???????')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      if (_likedByMe) {
        // ????? ??????
        await _s
            .from('likes')
            .delete()
            .eq('post_id', _postId)
            .eq('user_id', uid);
        if (!mounted) return;
        setState(() {
          _likedByMe = false;
          _likeCount = (_likeCount - 1).clamp(0, 1 << 31);
        });
      } else {
        // ????? ????
        await _s.from('likes').insert({
          'post_id': _postId,
          'user_id': uid,
        });
        if (!mounted) return;
        setState(() {
          _likedByMe = true;
          _likeCount++;
        });

        // ???? ??????? ?????
        _heartCtrl
          ..reset()
          ..forward();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('????? ????? ???????: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// ??? ??????? ??????? ?? ??????? ????????? (????? ???? ?????)
  Future<List<dynamic>> fetchComments() async {
    final rows = await _s
        .from('comments')
        .select(
            'id, content, user_id, created_at, profiles(username, avatar_url)')
        .eq('post_id', _postId)
        .order('created_at');
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        (widget.post['image_url'] ?? widget.post['url'] ?? '') as String? ?? '';

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ??????
            if (imageUrl.isNotEmpty)
              AspectRatio(
                aspectRatio: 1,
                child: Ink.image(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),

            // ???? ???????
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: _heartScale,
                    child: IconButton(
                      onPressed: _toggleLike,
                      icon: Icon(
                        _likedByMe ? Icons.favorite : Icons.favorite_border,
                        color: _likedByMe
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '$_likeCount',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      // ????: ???? ???? ????????? (?? ???? CommentsScreen)
                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: (_) => CommentsScreen(postId: _postId),
                      // ));
                      // ?? ??? ????????? ??????:
                      final comments = await fetchComments();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('??? ?????????: ${comments.length}'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.mode_comment_outlined),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}