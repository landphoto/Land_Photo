import 'package:flutter/material.dart';
import '../main.dart' show RouteNames;
import '../services/like_service.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post});
  final Map<String, dynamic> post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _likes = LikeService();
  int _count = 0;
  bool _likedByMe = false;

  @override
  void initState() {
    super.initState();
    _loadLikes();
  }

  Future<void> _loadLikes() async {
    final postId = widget.post['id'].toString();
    final c = await _likes.countLikes(postId);
    final m = await _likes.likedByMe(postId);
    if (!mounted) return;
    setState(() {
      _count = c;
      _likedByMe = m;
    });
  }

  Future<void> _onHeartTap() async {
    final postId = widget.post['id'].toString();
    await _likes.toggleLike(postId);
    final c = await _likes.countLikes(postId);
    final m = await _likes.likedByMe(postId);
    if (!mounted) return;
    setState(() {
      _count = c;
      _likedByMe = m;
    });
  }

  void _openComments() {
    final postId = widget.post['id'].toString();
    Navigator.pushNamed(
      context,
      RouteNames.comments,
      arguments: {'postId': postId},
    );
  }

  void _openImage() {
    final url = widget.post['image_url'] as String?;
    if (url == null || url.isEmpty) return;
    Navigator.pushNamed(
      context,
      RouteNames.image,
      arguments: {'url': url},
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.post['title']?.toString() ?? '';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: _openImage,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: _onHeartTap,
                    icon: Icon(_likedByMe ? Icons.favorite : Icons.favorite_border),
                  ),
                  Text('$_count'),
                  const Spacer(),
                  TextButton(
                    onPressed: _openComments,
                    child: const Text('Comments'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}