import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/post_card.dart'; // إذا عندك PostCard استخدمه، وإلا خلي ListTile بسيط

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _client = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _future;

  Future<List<Map<String, dynamic>>> _load() async {
    final rows = await _client
        .from('posts')
        .select('id,image_url,caption,created_at,profiles(username,avatar_url)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  void initState() {
    super.initState();
    _future = _load();

    // realtime (اختياري)
    _client
        .channel('public:posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (_) => setState(() => _future = _load()),
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الخلاصة'),
        actions: [
          IconButton(
            onPressed: () async {
              await _client.auth.signOut();
              if (mounted) context.go('/');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/upload'),
        child: const Icon(Icons.add_a_photo),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (c, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.hasError) {
            return Center(child: Text('خطأ: ${s.error}'));
          }
          final data = s.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('لا توجد منشورات بعد'));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: data.length,
            itemBuilder: (_, i) {
              final p = data[i];
              final user = (p['profiles'] ?? {}) as Map<String, dynamic>;
              return PostCard(
                imageUrl: p['image_url'],
                caption: p['caption'] ?? '',
                username: user['username'] ?? 'مستخدم',
                avatarUrl: user['avatar_url'],
                createdAt: DateTime.tryParse(p['created_at'] ?? '') ?? DateTime.now(),
              );
            },
          );
        },
      ),
    );
  }
}