import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String imageUrl;
  final String? caption;

  const PostCard({
    Key? key,
    required this.username,
    required this.imageUrl,
    this.caption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Image.network(imageUrl, fit: BoxFit.cover),
          if (caption != null && caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(caption!),
            ),
        ],
      ),
    );
  }
}