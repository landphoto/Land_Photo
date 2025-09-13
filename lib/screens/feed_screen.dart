import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final posts = [
      {
        'username': 'مستخدم ١',
        'image_url': 'https://picsum.photos/600/280',
        'caption': 'أول منشور!'
      },
      {
        'username': 'مستخدم ٢',
        'image_url': 'https://picsum.photos/600/281',
        'caption': 'ثاني منشور 👍'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("المنشورات"),
        actions: [
          IconButton(
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await AuthService.signOut();
              // رجّع لصفحة الدخول
              if (context.mounted) context.go('/');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/upload'),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}