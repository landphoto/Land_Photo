import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../ui/glass.dart';
import '../services/storage_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _store = StorageService();
  final _caption = TextEditingController();
  File? _file;
  String? _url;
  bool _loading = false;
  String? _error;

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _file = File(x.path));
  }

  Future<void> _upload() async {
    if (_file == null) return;
    setState(() { _loading = true; _error = null; _url = null; });
    try {
      final url = await _store.uploadImageAndCreatePost(file: _file!, caption: _caption.text.trim());
      if (mounted) { setState(() => _url = url); ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الرفع بنجاح'))); }
    } catch (_) { setState(() => _error = 'فشل الرفع'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('رفع صورة', style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Glass(
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: _file != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12),
                          child: Image.file(_file!, fit: BoxFit.cover))
                      : Container(alignment: Alignment.center, decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12), color: Colors.white10),
                          child: const Icon(Icons.image, size: 64, color: Colors.white54)),
                ),
                const SizedBox(height: 12),
                TextField(controller: _caption,
                  decoration: const InputDecoration(labelText: 'تعليق (اختياري)', prefixIcon: Icon(Icons.edit))),
                const SizedBox(height: 12),
                if (_url != null) ...[
                  SelectableText(_url!, style: t.bodySmall?.copyWith(color: AppColors.hint)),
                  const SizedBox(height: 8),
                ],
                if (_error != null) Text(_error!, style: const TextStyle(color: AppColors.danger)),
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: _pick, icon: const Icon(Icons.photo_library), label: const Text('اختيار صورة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text, side: const BorderSide(color: AppColors.mint),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: FilledButton.icon(
                      onPressed: _loading ? null : _upload,
                      icon: const Icon(Icons.cloud_upload),
                      label: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _loading
                            ? const SizedBox(width:18, height:18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('رفع'),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.mint, foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}