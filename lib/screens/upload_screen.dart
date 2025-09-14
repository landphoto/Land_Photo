import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../secrets.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _file;
  bool _loading = false;

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (x != null) setState(() => _file = File(x.path));
  }

  Future<void> _upload() async {
    if (_file == null) return;
    setState(() => _loading = true);
    try {
      final uid = SupaService.I.client.auth.currentUser!.id;
      final name = 'img_${DateTime.now().millisecondsSinceEpoch}.png';
      final url = await StorageService().uploadToBucket(
        bucket: AppSecrets.imagesBucket,
        fileName: name,
        file: _file!,
      );
      // أنشئ بوست
      final row = await SupaService.I.client.from('posts').insert({
        'user_id': uid,
        'image_url': url,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الرفع بنجاح')),
      );
      Navigator.pop(context, row);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الرفع: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رفع صورة')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_file != null) Image.file(_file!, width: 260),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                OutlinedButton.icon(onPressed: _pick, icon: const Icon(Icons.image), label: const Text('اختيار صورة')),
                FilledButton.icon(
                  onPressed: _loading ? null : _upload,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('رفع'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}