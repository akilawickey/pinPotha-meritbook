import 'dart:async';
import 'package:pinpotha/models/post.dart';
import 'package:pinpotha/services/post_service.dart';

class FakeRepository implements PostRepository {
  final Map<String, List<Post>> records = {};
  final Map<String, List<StreamController<List<Post>>>> controllers = {};
  final List<Post> saves = [];
  final List<String> deletedPhotos = [];
  int activeSubscriptions = 0;
  int allocations = 0;
  bool failSave = false;
  bool failCleanup = false;
  bool online = true;
  Completer<void>? pendingSave;
  @override
  Stream<List<Post>> watchPosts(String email) {
    late StreamController<List<Post>> controller;
    controller = StreamController<List<Post>>(onListen: () {
      activeSubscriptions++;
      scheduleMicrotask(() {
        if (!controller.isClosed) controller.add(List.of(records[email] ?? []));
      });
    }, onCancel: () {
      activeSubscriptions--;
    });
    controllers.putIfAbsent(email, () => []).add(controller);
    return controller.stream;
  }

  void emit(String email) {
    for (final controller
        in controllers[email] ?? <StreamController<List<Post>>>[]) {
      if (!controller.isClosed && controller.hasListener) {
        controller.add(List.of(records[email] ?? []));
      }
    }
  }

  void deny(String email) {
    for (final controller
        in controllers[email] ?? <StreamController<List<Post>>>[]) {
      if (!controller.isClosed && controller.hasListener) {
        controller.addError(StateError('Permission denied'));
      }
    }
  }

  @override
  Stream<bool> watchConnection() => Stream.value(online);
  @override
  String allocateId(String email) => 'post-${++allocations}';
  @override
  Future<void> savePost(String email, Post post) async {
    saves.add(post);
    if (pendingSave != null) await pendingSave!.future;
    if (failSave) throw StateError('Permission denied');
    final items = records.putIfAbsent(email, () => []);
    items.removeWhere(
        (item) => item.dateKey == post.dateKey && item.postId == post.postId);
    items.add(post);
    emit(email);
  }

  @override
  Future<void> updateNote(String email, Post post, String note) async {
    final items = records[email]!;
    final index = items.indexWhere(
        (item) => item.dateKey == post.dateKey && item.postId == post.postId);
    items[index] = Post(
        postId: post.postId,
        dateKey: post.dateKey,
        note: note.trim(),
        photoUrl: post.photoUrl,
        timeStamp: post.timeStamp);
    emit(email);
  }

  @override
  Future<void> removePost(String email, Post post) async {
    records[email]?.removeWhere(
        (item) => item.dateKey == post.dateKey && item.postId == post.postId);
    emit(email);
  }

  @override
  Future<void> deletePhoto(String url) async {
    if (failCleanup) throw StateError('Storage denied');
    deletedPhotos.add(url);
  }

  Future<void> close() async {
    for (final group in controllers.values) {
      for (final controller in group) {
        await controller.close();
      }
    }
  }
}
