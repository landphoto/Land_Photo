import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _captionCtrl = TextEditingController();
  File? _imageFile;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _upload() async {
    if (_imageFile == null) return;
    setState(() => _loading = true);

    // TODO: هنا تكتب كود رفع الصورة + الكابشن للباكند (API)
    await Future.delayed(const Duration(seconds: 2)); // محاكاة رفع

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع الصورة بنجاح 🎉')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رفع صورة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: _imageFile == null
                    ? const Center(
                        child: Text('اضغط لاختيار صورة',
                            style: TextStyle(color: Colors.white70)),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _captionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'أضف تعليق للصورة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _upload,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_loading ? 'جاري الرفع...' : 'رفع الصورة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}