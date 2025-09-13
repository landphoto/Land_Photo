import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/supabase_service.dart';
import '../widgets/post_card.dart';
import 'upload_screen.dart';
import 'profile_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _s = S.c;
  late Future<List<Map<String, dynamic>>> _future;
  RealtimeChannel? _ch;
  final _sc = ScrollController();
  bool _showUp = false;

  Future<List<Map<String, dynamic>>> _fetch() async {
    final res = await _s
        .from('posts')
        .select('id, image_url, caption, created_at, user_id, '
            'profiles!inner(id, username, avatar_url)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  @override
  void initState() {
    super.initState();
    _future = _fetch();
    _ch = _s.channel('posts_rt')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'posts',
        callback: (_) => setState(() => _future = _fetch()),
      )
      ..subscribe();
    _sc.addListener(() => setState(() => _showUp = _sc.offset > 400));
  }

  @override
  void dispose() { _ch?.unsubscribe(); _sc.dispose(); super.dispose(); }

  Future<void> _refresh() async => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('LandPhoto',
            style: t.headlineSmall?.copyWith(color: AppColors.mint, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              icon: const Icon(Icons.person_outline)),
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showUp)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton.small(
                heroTag: 'up',
                onPressed: () => _sc.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut),
                child: const Icon(Icons.keyboard_arrow_up),
              ),
            ),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UploadScreen()));
              _refresh();
            },
            label: const Text('رفع'),
            icon: const Icon(Icons.add_a_photo),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('خطأ في جلب البيانات'));
            }
            final data = snap.data ?? [];
            if (data.isEmpty) return Center(child: Text('لا توجد منشورات بعد', style: t.titleMedium));
            return ListView.separated(
              controller: _sc,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) => PostCard(post: data[i], onLiked: _refresh),
            );
          },
        ),
      ),
    );
  }
}