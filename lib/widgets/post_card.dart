import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/like_service.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _likes = LikeService();

  int likeCount = 0;
  bool likedByMe = false;

  @override
  void initState() {
    super.initState();
    _loadLikes();
  }

  Future<void> _loadLikes() async {
    final postId = widget.post['id'].toString();
    final c = await _likes.countLikes(postId);
    final m = await _likes.likedByMe(postId);

    setState(() {
      likeCount = c;
      likedByMe = m;
    });
  }

  Future<void> _toggleLike() async {
    final postId = widget.post['id'].toString();
    await _likes.toggleLike(postId);
    await _loadLikes(); // ???? ??? ???????
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ????? ????????
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blueGrey[100],
                  child: Text(
                    widget.post['user_id'] != null
                        ? widget.post['user_id'][0].toUpperCase()
                        : "?",
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "User: ${widget.post['user_id'] ?? 'Unknown'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// ????? ??????
            Text(
              widget.post['content'] ?? '',
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 12),

            /// ????? ?????? ????????
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    likedByMe ? Icons.favorite : Icons.favorite_border,
                    color: likedByMe ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleLike,
                ),
                Text(
                  "$likeCount Likes",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.comment, color: Colors.grey),
                  onPressed: () {
                    // TODO: ??? ???? ???? ???? ?????????
                  },
                ),
                const Text("Comments"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}