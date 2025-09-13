import 'package:flutter/material.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // مبدئياً نخلي بيانات تجريبية (ترتبط مع Supabase لاحقاً)
    final posts = [
      {
        'username': 'مستخدم ١',
        'image_url': 'https://picsum.photos/400/200',
        'caption': 'أول منشور!'
      },
      {
        'username': 'مستخدم ٢',
        'image_url': 'https://picsum.photos/400/201',
        'caption': 'ثاني منشور 👍'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("المنشورات")),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            username: post['username'] ?? 'مجهول',
            imageUrl: post['image_url']!,
            caption: post['caption'],
          );
        },
      ),
    );
  }
}