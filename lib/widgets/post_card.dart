import 'package:like_button/like_button.dart';
import '../services/like_service.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _likes = LikeService();
  bool _liked = false;
  int  _count = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final id = widget.post['id'].toString();
    final c  = await _likes.countLikes(id);
    final m  = await _likes.likedByMe(id);
    if (!mounted) return;
    setState(() { _count = c; _liked = m; });
  }

  @override
  Widget build(BuildContext context) {
    final postId = widget.post['id'].toString();

    return Column(
      children: [
        // ... ?????/???
        Row(
          children: [
            LikeButton(
              isLiked: _liked,
              likeCount: _count,
              size: 30,
              bubblesColor: BubblesColor(
                dotPrimaryColor: Theme.of(context).colorScheme.primary,
                dotSecondaryColor: Theme.of(context).colorScheme.secondary,
              ),
              circleColor: CircleColor(
                start: Theme.of(context).colorScheme.primary,
                end: Theme.of(context).colorScheme.secondary,
              ),
              countBuilder: (count, isLiked, text) {
                return Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isLiked
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
              onTap: (isLiked) async {
                final next = !isLiked;

                // ????? ?????
                setState(() {
                  _liked = next;
                  _count += next ? 1 : -1;
                });

                await _likes.toggleLike(postId);

                // ???? ???????? ?? ??????? ?????
                final fresh = await _likes.countLikes(postId);
                if (!mounted) return next;
                setState(() => _count = fresh);

                return next;
              },
            ),
            const SizedBox(width: 8),
            // ?? ????????? ???? ????
          ],
        ),
      ],
    );
  }
}