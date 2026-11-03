import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../screens/post_details_screen.dart';
import '../utils/date_utils.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});
  @override
  Widget build(BuildContext context) => Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (_) => PostDetailsScreen(
                    postId: post.postId, dateKey: post.dateKey))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: post.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: post.photoUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined)))
                  : Center(
                      child: Icon(Icons.menu_book,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary))),
          Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppDateUtils.formatDate(post.displayDate),
                        style: Theme.of(context).textTheme.labelSmall),
                    if (post.timeStamp.isFallback)
                      const Text('Date from saved day',
                          style: TextStyle(fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(post.note ?? 'Photo good thought',
                        maxLines: 3, overflow: TextOverflow.ellipsis),
                  ])),
        ]),
      ));
}
