import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/post_card.dart';
import '../widgets/posts_status.dart';
import 'add_post_screen.dart';

class PostListScreen extends StatelessWidget {
  final DateTime date;
  const PostListScreen({super.key, required this.date});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<PostsProvider>();
    final posts = state.onDay(date);
    return Scaffold(
      appBar: AppBar(
          title: Text(AppDateUtils.formatDate(date, format: 'dd MMM yyyy'))),
      body: state.loading || state.error != null
          ? PostsStatus(posts: state)
          : posts.isEmpty
              ? const Center(
                  child: Text('No good things recorded for this day yet.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisExtent: 320,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12),
                  itemBuilder: (_, index) => PostCard(post: posts[index])),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final saved = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => AddPostScreen(initialDate: date)));
            if (saved == true && context.mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Good Thought')),
    );
  }
}
