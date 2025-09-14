import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String url;
  final String? heroTag; // ???????

  const ImageViewer({super.key, required this.url, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final tag = heroTag ?? url;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: const Text('Preview')),
      body: Center(
        child: InteractiveViewer(
          child: Hero(tag: tag, child: Image.network(url, fit: BoxFit.contain)),
        ),
      ),
    );
  }
}