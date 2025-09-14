import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String url;
  final Object heroTag;

  const ImageViewer({
    Key? key,
    required this.url,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5,
              child: Center(
                child: Hero(
                  tag: heroTag,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                tooltip: '?????',
              ),
            ),
          ),
        ],
      ),
    );
  }
}