import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/storage_service.dart';

final _s = Supabase.instance.client;

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? _bytes;

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    final b = await x.readAsBytes();
    setState(() => _bytes = Uint8List.fromList(b));
  }

  Future<void> _upload() async {
    if (_bytes == null) return;
    final uid = _s.auth.currentUser?.id;
    if (uid == null) return;

    // ارفع للصندوق (تأكد bucket موجود - مثلاً posts)
    final now = DateTime.now().millisecondsSinceEpoch;
    final url = await StorageService.I.uploadToBucket(
      bucket: 'posts',
      path: '$uid/$now.jpg',
      bytes: _bytes!,
      contentType: 'image/jpeg',
    );

    // خزّن المنشور بجدول posts
    await _s.from('posts').insert({
      'user_id': uid,
      'image_url': url,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رفع صورة')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_bytes != null) Image.memory(_bytes!, height: 260),
            const SizedBox(height: 14),
            OutlinedButton.icon(onPressed: _pick, icon: const Icon(Icons.image), label: const Text('اختيار صورة')),
            const SizedBox(height: 8),
            FilledButton.icon(onPressed: _upload, icon: const Icon(Icons.cloud_upload), label: const Text('رفع')),
          ],
        ),
      ),
    );
  }
}