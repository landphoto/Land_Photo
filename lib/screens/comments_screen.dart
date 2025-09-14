import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _txt = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await SupaService.I.client
        .from('comments')
        .select('id, content, created_at, user_id')
        .eq('post_id', widget.postId)
        .order('created_at');
    setState(() => _items = rows);
  }

  Future<void> _send() async {
    final content = _txt.text.trim();
    if (content.isEmpty) return;
    final uid = SupaService.I.client.auth.currentUser!.id;
    await SupaService.I.client.from('comments').insert({
      'post_id': widget.postId,
      'user_id': uid,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });
    _txt.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التعليقات')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final c = _items[i];
                return ListTile(
                  title: Text(c['content'] ?? ''),
                  subtitle: Text('${c['user_id']}'.substring(0, 6)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _txt, decoration: const InputDecoration(hintText: 'اكتب تعليقاً...'))),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _send, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}