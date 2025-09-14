import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _loading = false;
  String? _url;

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (x == null) return;

    setState(() => _loading = true);
    final bytes = await x.readAsBytes();
    final url = await StorageService.I.uploadToBucket(
      bucket: 'public', // غيّرها إن عندك bucket مختلف
      path: x.name,
      bytes: Uint8List.fromList(bytes),
      contentType: 'image/${x.name.split('.').last}',
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _url = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: _loading ? null : _pickAndUpload,
                child: _loading ? const CircularProgressIndicator() : const Text('Pick & Upload'),
              ),
              const SizedBox(height: 12),
              if (_url != null) Text('Uploaded: $_url'),
            ],
          ),
        ),
      ),
    );
  }
}