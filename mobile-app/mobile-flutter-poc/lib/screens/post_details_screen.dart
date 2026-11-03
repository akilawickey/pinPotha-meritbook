import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/posts_status.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;
  final String dateKey;
  const PostDetailsScreen(
      {super.key, required this.postId, required this.dateKey});
  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  bool _busy = false;
  Future<void> _edit(Post post) async {
    final owner = context.read<PostsProvider>();
    final note = await showDialog<String>(
        context: context,
        builder: (_) => _EditNoteDialog(note: post.note ?? ''));
    if (note == null || !mounted) return;
    if (!owner.connected) {
      _message('Connect to the internet before editing.');
      return;
    }
    setState(() => _busy = true);
    owner.beginOperation();
    try {
      await owner.repository.updateNote(owner.email, post, note);
      if (mounted) _message('Note updated.');
    } catch (_) {
      if (mounted) _message('Could not update the note. Please try again.');
    } finally {
      owner.endOperation();
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(Post post) async {
    final owner = context.read<PostsProvider>();
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Delete Good Thought?'),
                content: const Text('This action cannot be undone.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete')),
                ]));
    if (confirmed != true || !mounted) return;
    if (!owner.connected) {
      _message('Connect to the internet before deleting.');
      return;
    }
    setState(() => _busy = true);
    owner.beginOperation();
    try {
      await owner.deletePost(post);
      if (mounted) {
        setState(() => _busy = false);
        _message(owner.cleanupPending.isEmpty
            ? 'Good thought deleted.'
            : 'Good thought deleted. Photo cleanup can be retried in Settings.');
        await WidgetsBinding.instance.endOfFrame;
        if (mounted) Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        _message('Could not delete the good thought. Please try again.');
      }
    } finally {
      owner.endOperation();
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> _share(Post post, BuildContext buttonContext) async {
    final box = buttonContext.findRenderObject() as RenderBox?;
    try {
      await Share.share(
          post.shareText.isEmpty
              ? 'A good thought from PinPotha'
              : post.shareText,
          subject: 'PinPotha - Good Thought',
          sharePositionOrigin:
              box == null ? null : box.localToGlobal(Offset.zero) & box.size);
    } catch (_) {
      if (mounted) _message('Could not share this good thought.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<PostsProvider>();
    final post = owner.find(widget.dateKey, widget.postId);
    return PopScope(
        canPop: !_busy,
        child: Scaffold(
            appBar: AppBar(title: const Text('Good Thought'), actions: [
              IconButton(
                  tooltip: 'Edit note',
                  onPressed: post == null || _busy ? null : () => _edit(post),
                  icon: const Icon(Icons.edit)),
              Builder(
                  builder: (buttonContext) => IconButton(
                      tooltip: 'Share',
                      onPressed: post == null || _busy
                          ? null
                          : () => _share(post, buttonContext),
                      icon: const Icon(Icons.share))),
              IconButton(
                  tooltip: 'Delete',
                  onPressed: post == null || _busy ? null : () => _delete(post),
                  icon: const Icon(Icons.delete_outline)),
            ]),
            body: _busy
                ? const Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Waiting for the server. Keep this screen open.')
                  ]))
                : owner.loading || owner.error != null
                    ? PostsStatus(posts: owner)
                    : post == null
                        ? const Center(
                            child: Text('This good thought no longer exists.'))
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                                Text(
                                    AppDateUtils.formatDate(post.displayDate,
                                        format: 'dd MMMM yyyy'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall),
                                if (post.timeStamp.isFallback)
                                  const Text(
                                      'Date from saved day; original timestamp unavailable.'),
                                const SizedBox(height: 16),
                                if (post.photoUrl != null)
                                  CachedNetworkImage(
                                      imageUrl: post.photoUrl!,
                                      fit: BoxFit.contain,
                                      placeholder: (_, __) => const SizedBox(
                                          height: 200,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator())),
                                      errorWidget: (_, __, ___) =>
                                          const SizedBox(
                                              height: 200,
                                              child: Center(
                                                  child: Icon(Icons
                                                      .broken_image_outlined)))),
                                const SizedBox(height: 24),
                                SelectableText(
                                    post.note ?? 'Photo good thought',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ])));
  }
}

class _EditNoteDialog extends StatefulWidget {
  final String note;
  const _EditNoteDialog({required this.note});
  @override
  State<_EditNoteDialog> createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends State<_EditNoteDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.note);
  bool _invalid = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('Edit Note'),
          content: TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 5,
              decoration: InputDecoration(
                  labelText: 'Your Good Thought',
                  errorText: _invalid ? 'Note cannot be empty' : null)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () {
                  if (_controller.text.trim().isEmpty) {
                    setState(() => _invalid = true);
                  } else {
                    Navigator.pop(context, _controller.text.trim());
                  }
                },
                child: const Text('Save'))
          ]);
}
