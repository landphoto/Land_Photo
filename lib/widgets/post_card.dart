import 'dart:math';
import 'package:flutter/material.dart';
import '../services/like_service.dart';

/// ??? ????? ?? ???? + ???? + ??????? ???? ?????
class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post});

  final Map<String, dynamic> post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  final _likes = LikeService.I;
  late int _count;
  bool _liked = false;

  late final AnimationController _burstCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  final _rnd = Random();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final id = widget.post['id'].toString();
    final c = await _likes.countLikes(id);
    final m = await _likes.likedByMe(id);
    if (!mounted) return;
    setState(() {
      _count = c;
      _liked = m;
    });
  }

  Future<void> _onToggle() async {
    final id = widget.post['id'].toString();
    final nowLiked = await _likes.toggleLike(id);
    if (!mounted) return;
    setState(() {
      _liked = nowLiked;
      _count += nowLiked ? 1 : -1;
    });
    if (nowLiked) {
      _burstCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _burstCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = widget.post['image_url'] as String?;

    return Card(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(imageUrl, fit: BoxFit.cover),
                    // ??????? ??????
                    AnimatedBuilder(
                      animation: _burstCtrl,
                      builder: (_, __) {
                        final t = _burstCtrl.value;
                        return IgnorePointer(
                          child: CustomPaint(
                            painter: _HeartsPainter(progress: t, rnd: _rnd),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: _onToggle,
                  icon: AnimatedScale(
                    scale: _liked ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      _liked ? Icons.favorite : Icons.favorite_border,
                    ),
                  ),
                  color: _liked ? theme.colorScheme.primary : theme.iconTheme.color,
                ),
                Text('$_count', style: theme.textTheme.bodyMedium),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // ???? ???? ????????? (??????? ?????? ??? ??? ????)
                  },
                  icon: const Icon(Icons.comment_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ???? ???? ????? ???????
class _HeartsPainter extends CustomPainter {
  _HeartsPainter({required this.progress, required this.rnd});

  final double progress;
  final Random rnd;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final count = 10;
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi;
      final radius = (size.shortestSide * 0.12) * Curves.easeOut.transform(progress);
      final dx = size.width / 2 + radius * cos(angle + rnd.nextDouble() * 0.5);
      final dy = size.height / 2 + radius * sin(angle + rnd.nextDouble() * 0.5);
      paint.color = Colors.white.withOpacity(0.9 - progress * 0.9);
      _drawHeart(canvas, Offset(dx, dy), 6 * (1 - progress), paint);
    }
  }

  void _drawHeart(Canvas c, Offset center, double s, Paint p) {
    final path = Path()
      ..moveTo(center.dx, center.dy + s / 2)
      ..cubicTo(
        center.dx + s, center.dy + s * 1.2,
        center.dx + s * 1.2, center.dy,
        center.dx, center.dy - s / 3,
      )
      ..cubicTo(
        center.dx - s * 1.2, center.dy,
        center.dx - s, center.dy + s * 1.2,
        center.dx, center.dy + s / 2,
      );
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _HeartsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}