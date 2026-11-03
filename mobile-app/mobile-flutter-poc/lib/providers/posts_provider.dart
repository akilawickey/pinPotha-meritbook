import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../utils/date_utils.dart';

class PostsProvider extends ChangeNotifier {
  final String email;
  final PostRepository repository;
  StreamSubscription<List<Post>>? _postsSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  List<Post> _posts = [];
  Object? error;
  bool loading = true;
  bool connected = false;
  bool _disposed = false;
  int activeOperations = 0;
  void beginOperation() {
    activeOperations++;
    _notify();
  }

  void endOperation() {
    if (activeOperations > 0) activeOperations--;
    _notify();
  }

  Completer<void>? _refresh;
  final Set<String> cleanupPending = {};

  PostsProvider(this.email, {PostRepository? repository})
      : repository = repository ?? PostService() {
    _connectionSubscription = this.repository.watchConnection().listen((value) {
      connected = value;
      _notify();
    }, onError: (Object _) {
      connected = false;
      _notify();
    });
    _subscribe();
  }
  List<Post> get posts => List.unmodifiable(_posts);
  bool get active => !_disposed;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _subscribe() {
    _postsSubscription = repository.watchPosts(email).listen((posts) {
      _posts = posts;
      loading = false;
      error = null;
      _refresh?.complete();
      _refresh = null;
      _notify();
    }, onError: (Object failure) {
      // Do not show a previously authorized snapshot after a read is denied.
      _posts = [];
      loading = false;
      error = failure;
      _refresh?.complete();
      _refresh = null;
      _notify();
    });
  }

  Future<void> retry() async {
    if (_refresh != null) return _refresh!.future;
    final completion = Completer<void>();
    _refresh = completion;
    await _postsSubscription?.cancel();
    if (_disposed) {
      if (!completion.isCompleted) completion.complete();
      _refresh = null;
      return;
    }
    loading = true;
    error = null;
    _notify();
    _subscribe();
    await completion.future;
  }

  List<Post> onDay(DateTime date) => _posts
      .where((post) => AppDateUtils.sameDay(post.displayDate, date))
      .toList();
  Post? find(String dateKey, String postId) {
    for (final post in _posts) {
      if (post.dateKey == dateKey && post.postId == postId) return post;
    }
    return null;
  }

  Future<void> deletePost(Post post) async {
    // Older date-edit implementations could leave two records sharing a photo.
    final sharedPhoto = post.photoUrl != null &&
        _posts.any((other) =>
            other.photoUrl == post.photoUrl &&
            (other.dateKey != post.dateKey || other.postId != post.postId));
    await repository.removePost(email, post);
    if (post.photoUrl != null && !sharedPhoto) {
      await cleanupPhoto(post.photoUrl!);
    }
  }

  Future<void> cleanupPhoto(String url) async {
    cleanupPending.add(url);
    _notify();
    try {
      await repository.deletePhoto(url);
      cleanupPending.remove(url);
    } catch (_) {/* Keep visible for explicit retry. */}
    _notify();
  }

  Future<void> retryCleanup() async {
    for (final url in cleanupPending.toList()) {
      await cleanupPhoto(url);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_postsSubscription?.cancel());
    unawaited(_connectionSubscription?.cancel());
    _refresh?.complete();
    _refresh = null;
    _posts = [];
    super.dispose();
  }
}
