import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _storage = StorageService(); // بدلاً من StorageService.I
  bool _loading = false;

  Future<void> _uploadDummy() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      // مثال بسيط (بدّل بالمحتوى الحقيقي عندك)
      // await _storage.uploadToBucket(bucket: 'photos', path: 'demo.txt', bytes: Uint8List.fromList([1,2,3]), contentType:'text/plain');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload ready (stub).')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: Center(
        child: ElevatedButton(
          onPressed: _loading ? null : _uploadDummy,
          child: Text(_loading ? 'Uploading…' : 'Upload demo'),
        ),
      ),
    );
  }
}