import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _caption = TextEditingController();
  XFile? _file;
  bool _loading = false;

  Future<void> _pick() async {
    final pic = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 88);
    if (pic != null) setState(() => _file = pic);
  }

  Future<void> _upload() async {
    if (_file == null) {
      _snack('اختر صورة أولاً');
      return;
    }
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser!;
      final bytes = await _file!.readAsBytes();

      final ext = p.extension(_file!.path); // .jpg / .png
      final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}$ext';

      // رفع إلى Storage bucket: photos
      await client.storage.from('photos').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // جلب رابط عام
      final publicUrl = client.storage.from('photos').getPublicUrl(path);

      // إدخال صف في posts
      await client.from('posts').insert({
        'user_id': user.id,
        'image_url': publicUrl,
        'caption': _caption.text.trim(),
      });

      _snack('تم النشر!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _snack('فشل الرفع: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نشر صورة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pick,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                  color: Colors.white.withOpacity(.04),
                ),
                child: _file == null
                    ? const Icon(Icons.add_a_photo, size: 48)
                    : Image.file(File(_file!.path), fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _caption,
            decoration: const InputDecoration(
              labelText: 'وصف/تعليق (اختياري)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _upload,
            icon: _loading
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.cloud_upload),
            label: const Text('رفع'),
          ),
        ],
      ),
    );
  }
}