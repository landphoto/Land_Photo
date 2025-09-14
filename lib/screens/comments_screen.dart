import 'package:flutter/material.dart';
import '../services/comments_service.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: CommentsService.I.fetch(widget.postId),
              builder: (c, s) {
                if (!s.hasData) return const Center(child: CircularProgressIndicator());
                final items = s.data!;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return ListTile(
                      title: Text(it['content'] ?? ''),
                      subtitle: Text(it['profiles']?['username'] ?? it['user_id'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _text, decoration: const InputDecoration(hintText: 'Write a comment...'))),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final t = _text.text.trim();
                    if (t.isEmpty) return;
                    await CommentsService.I.add(widget.postId, t);
                    if (!mounted) return;
                    setState(() => _text.clear());
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}