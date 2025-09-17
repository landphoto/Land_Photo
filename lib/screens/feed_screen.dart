import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui/widgets/post_card.dart';
import '../ui/gradient_scaffold.dart';
import 'upload_screen.dart';
import 'profile_screen.dart';
import 'comments_screen.dart';

class FeedScreen extends StatefulWidget {
  static const String routeName = '/feed';
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> _postsStream() {
    return _client
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.cast<Map<String, dynamic>>());
  }

  void _openComments(String postId) {
    Navigator.pushNamed(context, CommentsScreen.routeName,
        arguments: {'postId': postId});
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            tooltip: 'Upload',
            onPressed: () => Navigator.pushNamed(context, UploadScreen.routeName),
            icon: const Icon(Icons.upload_rounded),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, ProfileScreen.routeName),
            icon: const Icon(Icons.person_rounded),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _postsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final posts = snap.data ?? [];
          if (posts.isEmpty) {
            return Center(
              child: Text('?? ???? ??????? ???',
                  style: Theme.of(context).textTheme.titleMedium),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final p = posts[i];
              return PostCard(
                post: p,
                onCommentTap: () => _openComments(p['id'] as String),
              );
            },
          );
        },
      ),
    );
  }
}