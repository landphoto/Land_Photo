import 'package:flutter/material.dart';
import '../main.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed'), actions: [
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.upload),
          icon: const Icon(Icons.file_upload),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          icon: const Icon(Icons.person),
        ),
      ]),
      body: const Center(child: Text('Your feed goes here')),
    );
  }
}