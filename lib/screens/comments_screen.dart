import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui/gradient_scaffold.dart';
import '../ui/glass.dart';

class CommentsScreen extends StatefulWidget {
  static const String routeName = '/comments';
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> _commentsStream() {
    return _client
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', widget.postId)
        .order('created_at', ascending: true)
        .map((rows) => rows.cast<Map<String, dynamic>>());
  }

  Future<void> _addComment(String text) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('???? ???? ?????')),
      );
      return;
    }
    if (text.trim().isEmpty) return;
    try {
      await _client.from('comments').insert({
        'post_id': widget.postId,
        'user_id': user.id,
        'content': text.trim(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('??? ????? ???????: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('?????????')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _commentsStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final comments = snap.data ?? [];
                if (comments.isEmpty) {
                  return const Center(child: Text('???? ??????? ???'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = comments[i];
                    final content = c['content'] as String? ?? '';
                    return GlassContainer(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(child: Icon(Icons.person, size: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              content,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: _CommentComposer(onSubmit: _addComment),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatefulWidget {
  final Future<void> Function(String) onSubmit;
  const _CommentComposer({required this.onSubmit});

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final _controller = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    if (_sending) return;
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    setState(() => _sending = true);
    await widget.onSubmit(text);
    if (mounted) {
      _controller.clear();
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassContainer(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '???? ??????',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _sending
            ? const SizedBox(
                width: 36,
                height: 36,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(strokeWidth: 2.6),
                ),
              )
            : GlassButton(onPressed: _send, child: const Text('?????')),
      ],
    );
  }
}