import 'package:flutter/material.dart';
import '../widgets/emoji_sheet.dart';

class CommentComposer extends StatefulWidget {
  const CommentComposer({super.key});

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة تعليق')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'اكتب تعليق...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () async {
                    final updated = await showEmojiBottomSheet(
                      context,
                      init: _ctrl.text,
                    );
                    if (updated != null) {
                      _ctrl.text = updated;
                      _ctrl.selection = TextSelection.fromPosition(
                        TextPosition(offset: _ctrl.text.length),
                      );
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      // هنا تحط كود إرسال التعليق للباكند
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تم إرسال: ${_ctrl.text}')),
                      );
                      _ctrl.clear();
                    },
                    child: const Text('إرسال'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}