import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _file;
  String? _url;
  bool _loading = false;
  final picker = ImagePicker();

  Future<void> _pick() async {
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    // انسخ لـ directory مؤقت (Android 10+)
    final dir = await getTemporaryDirectory();
    final tmp = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${picked.name}');
    final data = await picked.readAsBytes();
    await tmp.writeAsBytes(data);

    setState(() => _file = tmp);
  }

  Future<void> _upload() async {
    if (_file == null) return;
    setState(() => _loading = true);
    try {
      final publicUrl = await StorageService.uploadImage(file: _file!);
      // مثال: حفظ بوست بجدول posts
      final uid = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client.from('posts').insert({
        'user_id': uid,
        'image_url': publicUrl,
        'caption': 'من التطبيق 📸',
      });
      setState(() => _url = publicUrl);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الرفع بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الرفع: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رفع صورة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_file != null) Image.file(_file!, height: 200),
            if (_url != null) SelectableText(_url!),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text('اختيار صورة'),
                    onPressed: _loading ? null : _pick,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('رفع'),
                    onPressed: _loading ? null : _upload,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}