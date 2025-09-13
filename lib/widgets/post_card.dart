import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../ui/glass.dart';

class PostCard extends StatefulWidget {
  final String avatar;
  final String name;
  final String imageUrl;
  final String caption;
  final String time;
  final int likes;
  final int comments;
  final VoidCallback? onOpen;
  const PostCard({
    super.key,
    required this.avatar,
    required this.name,
    required this.imageUrl,
    required this.caption,
    required this.time,
    required this.likes,
    required this.comments,
    this.onOpen,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool liked = false;
  int likeCount = 0;
  @override void initState(){ super.initState(); likeCount = widget.likes; }

  void _toggleLike() {
    setState(() {
      liked = !liked;
      likeCount += liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            CircleAvatar(backgroundImage: CachedNetworkImageProvider(widget.avatar), radius: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.name, style: Theme.of(context).textTheme.titleMedium),
              Text(widget.time, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white70)),
            ])),
            IconButton(onPressed: (){}, icon: const Icon(Icons.more_horiz))
          ]),

          const SizedBox(height: 10),

          // Image
          GestureDetector(
            onDoubleTap: _toggleLike,
            onTap: widget.onOpen,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (c,_)=>Container(color: Colors.white10),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: liked ? 1 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Lottie.asset('assets/lottie/like.json', repeat: false),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Actions + counts
          Row(
            children: [
              IconButton(
                onPressed: _toggleLike,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (c, a)=>ScaleTransition(scale: a, child: c),
                  child: liked
                      ? const Icon(Icons.favorite, key: ValueKey('on'), color: Colors.pinkAccent)
                      : const Icon(Icons.favorite_border, key: ValueKey('off')),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(onPressed: widget.onOpen, icon: const Icon(Icons.mode_comment_outlined)),
              const Spacer(),
              Text('$likeCount إعجاب • ${widget.comments} تعليق', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Text(widget.caption, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}