import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _s = Supabase.instance.client;

/// شاشة التعليقات لمنشور محدد
class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _text = TextEditingController();
  bool _sending = false;

  Future<List<Map<String, dynamic>>> _load() async {
    // comments: id, post_id, user_id, content, created_at
    // profiles: id, username
    final data = await _s
        .from('comments')
        .select('id, content, created_at, profiles ( username )')
        .eq('post_id', widget.postId)
        .order('created_at', ascending: true);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> _send() async {
    final content = _text.text.trim();
    if (content.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final uid = _s.auth.currentUser!.id;
      await _s.from('comments').insert({
        'post_id': widget.postId,
        'user_id': uid,
        'content': content,
      });
      _text.clear();
      setState(() {}); // يعيد التحميل عبر FutureBuilder (يُبنى من جديد)
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تعذّر إرسال التعليق: $e')));
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التعليقات')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _load(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('خطأ في التحميل: ${snap.error}'));
                }
                final items = snap.data ?? const [];
                if (items.isEmpty) {
                  return const Center(child: Text('لا توجد تعليقات بعد'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final row = items[i];
                    final username =
                        (row['profiles']?['username'] as String?) ?? 'مستخدم';
                    final content = row['content'] as String? ?? '';
                    final dt = DateTime.tryParse(row['created_at'] ?? '');
                    final subtitle =
                        dt != null ? '${dt.toLocal()}' : '—';
                    return ListTile(
                      title: Text(username, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(content),
                      trailing: Text(
                        subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'أكتب تعليقك...',
                        filled: true,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    tooltip: 'إرسال',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}