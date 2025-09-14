// lib/widgets/post_card.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/like_service.dart';

/// ????? ?????? ?????? ???? + ???? + ???? ??????? + ?????
class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  final _likes = LikeService();

  int _count = 0;
  bool _liked = false;

  // ???? ????? ??? ????????
  late final AnimationController _iconCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: .85,
    upperBound: 1.2,
  );

  // ?????? ???? ??????
  int _burstKey = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final postId = widget.post['id'].toString();
    final c = await _likes.countLikes(postId);
    final m = await _likes.likedByMe(postId);
    if (!mounted) return;
    setState(() {
      _count = c;
      _liked = m;
    });
  }

  Future<void> _toggle() async {
    final postId = widget.post['id'].toString();
    await _likes.toggleLike(postId);

    // ???? ????? ???????
    final c = await _likes.countLikes(postId);
    final m = await _likes.likedByMe(postId);

    if (!mounted) return;
    setState(() {
      _count = c;
      _liked = m;
      _burstKey++; // ???? ???? ???? ?????
    });

    _iconCtrl.forward(from: .9);
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = widget.post['image_url'] as String?;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      elevation: 6,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imgUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(imgUrl, fit: BoxFit.cover),
                    // ???? ?????? ???? ??? ??????
                    HeartBurst(
                      triggerKey: _burstKey,
                      // ?? ??? ?????? ???? ??? ??? ??????? ??? liked:
                      enabled: _liked,
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ScaleTransition(
                  scale: CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOutBack),
                  child: IconButton(
                    onPressed: _toggle,
                    icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
                  ),
                ),
                Text('$_count',
                    style: theme.textTheme.bodyMedium),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // TODO: ???? ???? ?????????
                  },
                  icon: const Icon(Icons.mode_comment_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ????? ???? ??????? ?????
class HeartBurst extends StatefulWidget {
  final int triggerKey; // ???? ????? ????? ????????
  final bool enabled;
  const HeartBurst({super.key, required this.triggerKey, this.enabled = true});

  @override
  State<HeartBurst> createState() => _HeartBurstState();
}

class _HeartBurstState extends State<HeartBurst> with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 600);
  static const _numHearts = 12;

  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: _duration);

  final Random _rand = Random();
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = _spawn();
  }

  @override
  void didUpdateWidget(covariant HeartBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerKey != oldWidget.triggerKey && widget.enabled) {
      _particles = _spawn();
      _ctrl.forward(from: 0);
    }
  }

  List<_Particle> _spawn() {
    // ???? ?????? ???? ????? ?????? ??????? ???????
    return List.generate(_numHearts, (i) {
      final angle = (_rand.nextDouble() * pi * 2);
      final dist = 30 + _rand.nextDouble() * 40; // ??? ??? ????????
      final size = 8 + _rand.nextDouble() * 10;
      return _Particle(angle: angle, distance: dist, size: size);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_ctrl.value);
          return Stack(
            clipBehavior: Clip.none,
            children: _particles.map((p) {
              final dx = cos(p.angle) * p.distance * t;
              final dy = sin(p.angle) * p.distance * t;
              final opacity = (1 - t).clamp(0.0, 1.0);
              final scale = 0.6 + 0.6 * (1 - t);
              return Positioned.fill(
                child: Transform.translate(
                  offset: Offset(dx, dy),
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: const _HeartDot(),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size; // ??????? ?? ???? ????? ????? ??????
  _Particle({required this.angle, required this.distance, required this.size});
}

/// ??? ??? ???? (????? + ???? ????):
class _HeartDot extends StatelessWidget {
  const _HeartDot();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Icon(Icons.favorite, color: color, size: 14);
  }
}