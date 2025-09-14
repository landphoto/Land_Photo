import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart' show RealtimeChannel, PostgresChangeEvent;
import '../services/supabase_service.dart';
import '../widgets/post_card.dart';
import 'profile_screen.dart';
import 'upload_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Map<String, dynamic>> _posts = [];
  RealtimeChannel? _ch;

  @override
  void initState() {
    super.initState();
    _load();
    _listen();
  }

  Future<void> _load() async {
    final rows = await SupaService.I.client
        .from('posts')
        .select('id, image_url, user_id, created_at')
        .order('created_at', ascending: false);
    setState(() => _posts = rows);
  }

  void _listen() {
    _ch = SupaService.I.client
        .channel('public:posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'posts',
          callback: (_) => _load(),
        )
        .subscribe();
  }

  @override
  void dispose() {
    _ch?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LandPhoto'),
        actions: [
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())), icon: const Icon(Icons.person)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen()));
          if (res != null) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: _posts.length,
          itemBuilder: (_, i) => PostCard(post: _posts[i]),
        ),
      ),
    );
  }
}