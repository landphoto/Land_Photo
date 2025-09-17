import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../ui/gradient_scaffold.dart';
import '../ui/glass.dart';

class UploadScreen extends StatefulWidget {
  static const String routeName = '/upload';
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _client = Supabase.instance.client;
  final _picker = ImagePicker();
  final _captionCtrl = TextEditingController();
  bool _busy = false;

  Future<void> _pickAndUpload() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw 'رجاءً سجّل دخول أولاً';

      final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 88);
      if (img == null) {
        setState(() => _busy = false);
        return;
      }

      final bytes = await File(img.path).readAsBytes();
      final id = const Uuid().v4();
      final path = '${user.id}/$id.jpg';

      await _client.storage.from('images').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );

      final publicUrl = _client.storage.from('images').getPublicUrl(path);

      await _client.from('posts').insert({
        'id': id,
        'user_id': user.id,
        'image_url': publicUrl,
        'caption': _captionCtrl.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الرفع بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('فشل الرفع: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassContainer(
                  child: TextField(
                    controller: _captionCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Caption (اختياري)',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _busy
                    ? const SizedBox(
                        width: 42, height: 42, child: CircularProgressIndicator())
                    : GlassButton(
                        onPressed: _pickAndUpload,
                        child: const Text('Pick & Upload'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}