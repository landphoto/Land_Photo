import 'package:flutter/material.dart';
import '../screens/comments_screen.dart';
import '../screens/image_viewer.dart';
import '../services/like_service.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post; // ???????: {id, image_url, user_id, created_at}
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _likes = LikeService();
  int _count = 0;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.post['id'].toString();
    final c = await _likes.countLikes(id);
    final m = await _likes.likedByMe(id);
    if (mounted) setState(() { _count = c; _liked = m; });
  }

  Future<void> _toggle() async {
    await _likes.toggleLike(widget.post['id'].toString());
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.post['image_url'] as String;
    final tag = 'img_${widget.post['id']}';
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ImageViewer(url: url, heroTag: tag))),
            child: Hero(
              tag: tag,
              child: AspectRatio(
                aspectRatio: 4/5,
                child: Image.network(url, fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggle,
                  icon: Icon(_liked ? Icons.favorite : Icons.favorite_border, color: _liked ? Colors.red : null),
                ),
                Text('$_count'),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CommentsScreen(postId: widget.post['id'].toString())),
                  ),
                  icon: const Icon(Icons.comment),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}