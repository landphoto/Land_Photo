import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

Future<String?> showEmojiBottomSheet(BuildContext context, {String init = ''}) async {
  String text = init;
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(12),
      child: Material(
        color: Colors.white.withOpacity(.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SizedBox(
          height: 340,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: EmojiPicker(
                  onEmojiSelected: (c, e) {
                    text += e.emoji;
                  },
                  config: const Config(columns: 8, emojiSizeMax: 28),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, text),
                  child: const Text('إدراج'),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}