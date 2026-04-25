import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';
import '../models/post.dart';
import '../models/timestamp_data.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../widgets/bottom_navigation.dart';
import 'add_post_screen.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final PostService _postService = PostService();
  Post? _post;
  bool _loading = true;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  void _loadPost() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null || authProvider.user!.email == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      // Ensure we have a fresh token with email claim
      authProvider.user!.getIdToken(true).then((_) {
        _postService.getAllPosts(authProvider.user!.email!).listen(
          (posts) {
            if (mounted) {
              final post = posts.firstWhere(
                (p) => p.postId == widget.postId,
                orElse: () => Post(
                  postId: '',
                  timeStamp: TimestampData(serverTime: 0),
                ),
              );

              setState(() {
                _post = post.postId.isNotEmpty ? post : null;
                _loading = false;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _loading = false;
              });
              debugPrint('Error loading post: $error');
            }
          },
        );
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        debugPrint('Error getting token: $e');
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _deleting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null || _post == null) return;

      await _postService.deletePost(
        authProvider.user!.email!,
        _post!.postId,
        _post!.timeStamp.date,
        _post!.photoUrl,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting post: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
        });
      }
    }
  }

  void _handleEdit() {
    if (_post == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostScreen(
          postId: _post!.postId,
          initialDate: _post!.timeStamp.date,
          initialNote: _post!.note,
          initialPhotoUrl: _post!.photoUrl,
        ),
      ),
    ).then((_) => _loadPost());
  }

  Future<void> _handleShare() async {
    if (_post == null) return;

    try {
      await Share.share(
        _post!.note ?? 'Check out my good thought!',
        subject: 'PinPotha - Good Thought',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _post != null ? _handleEdit : null,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _post != null ? _handleShare : null,
          ),
          IconButton(
            icon: _deleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete),
            onPressed: _post != null && !_deleting ? _handleDelete : null,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
              ? const Center(child: Text('Post not found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Date Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor.withOpacity(0.1),
                              Theme.of(context).primaryColor.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).primaryColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Date',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                        app_date_utils.AppDateUtils.formatDate(
                                          _post!.timeStamp.date,
                                          format: 'dd MMMM yyyy',
                                        ),
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      app_date_utils.AppDateUtils.formatTime(_post!.timeStamp.date),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (_post!.photoUrl != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.photo,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text('With Photo'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Image Section
                      if (_post!.photoUrl != null)
                        CachedNetworkImage(
                          imageUrl: _post!.photoUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 300,
                            color: Colors.grey.shade200,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 300,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.error),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.book,
                              size: 128,
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                          ),
                        ),

                      // Note Section
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.book,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Your Good Thought',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_post!.note != null && _post!.note!.isNotEmpty)
                              Text(
                                _post!.note!,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                ),
                              )
                            else
                              Center(
                                child: Text(
                                  'No note added to this good thought',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: const BottomNavigation(currentScreen: CurrentScreen.other),
    );
  }
}

