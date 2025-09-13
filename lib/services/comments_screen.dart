import 'package:flutter/material.dart';
import '../services/comments_service.dart';
import '../ui/glass.dart';

class CommentsScreen extends StatefulWidget {
  final int postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _svc = CommentsService();
  final _txt = TextEditingController();
  late Future<List<Map<String, dynamic>>> _future;
  RealtimeChannel? _ch;

  Future<List<Map<String, dynamic>>> _fetch() => _svc.list(widget.postId);

  @override
  void initState() {
    super.initState();
    _future = _fetch();
    _ch = _svc.subscribe(widget.postId, () => setState(() => _future = _fetch()));
  }

  @override
  void dispose() { _txt.dispose(); _ch?.unsubscribe(); super.dispose(); }

  Future<void> _send() async {
    final v = _txt.text.trim();
    if (v.isEmpty) return;
    await _svc.add(widget.postId, v);
    _txt.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('التعليقات')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, s) {
                if (s.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = s.data ?? [];
                if (data.isEmpty) return Center(child: Text('لا توجد تعليقات', style: t.bodyLarge));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final c = data[i];
                    final user = c['profiles']?['username'] ?? 'مستخدم';
                    return Glass(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(radius: 14, child: Text(user[0].toUpperCase())),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user, style: t.labelLarge),
                              const SizedBox(height: 4),
                              Text(c['content'] ?? ''),
                            ],
                          )),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: _txt, decoration: const InputDecoration(
                    hintText: 'اكتب تعليقاً...', prefixIcon: Icon(Icons.chat_outlined)))),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _send, child: const Icon(Icons.send)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}