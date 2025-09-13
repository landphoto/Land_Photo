import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool loading = true;
  final items = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    // محاكاة جلب بيانات (بدّلها لاحقًا بنداءات API)
    await Future.delayed(const Duration(milliseconds: 700));
    items
      ..clear()
      ..addAll(List.generate(8, (i) {
        return {
          'avatar': 'https://i.pravatar.cc/150?img=${(i + 3) % 70}',
          'name': 'User ${i + 1}',
          'image': 'https://picsum.photos/seed/${i + 33}/900/900',
          'caption': 'منظر خرافي! #landphoto #${i + 1}',
          'time': 'قبل ${i + 2} ساعة',
          'likes': (i + 1) * 3,
          'comments': (i + 1),
        };
      }));
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Land Photo', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemBuilder: (c, i) {
                  final x = items[i];
                  return _PostCard(
                    avatar: x['avatar'],
                    name: x['name'],
                    imageUrl: x['image'],
                    caption: x['caption'],
                    time: x['time'],
                    likes: x['likes'],
                    comments: x['comments'],
                    onOpenComments: () => Navigator.pushNamed(context, '/comment'),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemCount: items.length,
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // افتح شاشة الرفع
          await Navigator.pushNamed(context, '/upload');
          // بعد الرجوع، حدّث الفيد
          await _load();
        },
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('رفع صورة'),
      ),
      bottomNavigationBar: const _GlassNavBar(),
    );
  }
}

class _PostCard extends StatefulWidget {
  final String avatar;
  final String name;
  final String imageUrl;
  final String caption;
  final String time;
  final int likes;
  final int comments;
  final VoidCallback onOpenComments;
  const _PostCard({
    required this.avatar,
    required this.name,
    required this.imageUrl,
    required this.caption,
    required this.time,
    required this.likes,
    required this.comments,
    required this.onOpenComments,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool liked = false;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.avatar),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(widget.time,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70)),
                  ]),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz))
          ]),
          const SizedBox(height: 10),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(widget.imageUrl, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 12),

          // Actions + counts
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    liked = !liked;
                    likeCount += liked ? 1 : -1;
                  });
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
                  child: liked
                      ? const Icon(Icons.favorite,
                          key: ValueKey('on'), color: Colors.pinkAccent)
                      : const Icon(Icons.favorite_border, key: ValueKey('off')),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: widget.onOpenComments,
                icon: const Icon(Icons.mode_comment_outlined),
              ),
              const Spacer(),
              Text('$likeCount إعجاب • ${widget.comments} تعليق',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
            child: Text(widget.caption),
          ),
        ]),
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withOpacity(.12)),
        ),
        height: 60,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.home_rounded),
            Icon(Icons.explore_outlined),
            Icon(Icons.add_box_outlined),
            Icon(Icons.chat_bubble_outline_rounded),
            Icon(Icons.person_outline_rounded),
          ],
        ),
      ),
    );
  }
}