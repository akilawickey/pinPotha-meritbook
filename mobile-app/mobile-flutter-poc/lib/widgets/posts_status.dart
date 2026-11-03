import 'package:flutter/material.dart';
import '../providers/posts_provider.dart';

class PostsStatus extends StatelessWidget {
  final PostsProvider posts;
  const PostsStatus({super.key, required this.posts});
  @override
  Widget build(BuildContext context) {
    if (posts.loading) return const Center(child: CircularProgressIndicator());
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 16),
              const Text(
                  'Could not load your good thoughts. Check your connection and sign-in, then try again.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: posts.retry, child: const Text('Retry')),
            ])));
  }
}
