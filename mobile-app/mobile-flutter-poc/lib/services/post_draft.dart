import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/timestamp_data.dart';
import '../providers/posts_provider.dart';
import '../utils/post_utils.dart';

typedef ImageUpload = Future<String> Function(File image, String objectId);

// Lives with the form. A failed commit keeps the exact same identity/payload for retry.
class PostDraft extends ChangeNotifier {
  final PostsProvider owner;
  final ImageUpload upload;
  Post? snapshot;
  File? _image;
  String? _uploadedUrl;
  String? _failedUploadUrl;
  bool busy = false;
  bool saved = false;
  bool waitingForServer = false;
  Object? error;
  bool _disposed = false;
  Timer? _timer;

  PostDraft(this.owner, {ImageUpload? upload})
      : upload = upload ?? PostUtils.uploadImage;
  bool get frozen => snapshot != null;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> submit(
      {required String note, required DateTime date, File? image}) async {
    if (busy || saved) return;
    if (!owner.active || !owner.connected) {
      error = StateError(
          'Connect to the internet before posting. Your draft is kept.');
      _notify();
      return;
    }
    if (snapshot == null) {
      if (note.trim().isEmpty && image == null) {
        error = ArgumentError('Add a note or photo.');
        _notify();
        return;
      }
      snapshot = Post(
          postId: owner.repository.allocateId(owner.email),
          dateKey: PostUtils.formatDateForPath(date),
          note: note.trim().isEmpty ? null : note.trim(),
          timeStamp: TimestampData(serverTime: date.millisecondsSinceEpoch));
      _image = image;
    }
    owner.beginOperation();
    busy = true;
    error = null;
    waitingForServer = false;
    _notify();
    _timer = Timer(const Duration(seconds: 15), () {
      waitingForServer = true;
      _notify();
    });
    try {
      if (_image != null && _uploadedUrl == null) {
        _uploadedUrl = await upload(_image!, snapshot!.postId);
        _failedUploadUrl = null;
      }
      // An upload may complete after logout; never start a new write for that session.
      if (!owner.active) throw StateError('The signed-in account changed.');
      final post = snapshot!;
      snapshot = Post(
          postId: post.postId,
          dateKey: post.dateKey,
          note: post.note,
          photoUrl: _uploadedUrl,
          timeStamp: post.timeStamp);
      await owner.repository.savePost(owner.email, snapshot!);
      saved = true;
    } catch (failure) {
      error = failure;
      if (failure is ImageUploadFailure) _failedUploadUrl = failure.objectUrl;
      if (!owner.active && (_uploadedUrl ?? _failedUploadUrl) != null) {
        await owner.cleanupPhoto((_uploadedUrl ?? _failedUploadUrl)!);
        _uploadedUrl = null;
        _failedUploadUrl = null;
      }
    } finally {
      owner.endOperation();
      _timer?.cancel();
      busy = false;
      waitingForServer = false;
      _notify();
    }
  }

  Future<void> discard() async {
    if (busy) throw StateError('Wait for the pending save before discarding.');
    busy = true;
    owner.beginOperation();
    _notify();
    try {
      if (!saved && (_uploadedUrl ?? _failedUploadUrl) != null) {
        await owner.cleanupPhoto((_uploadedUrl ?? _failedUploadUrl)!);
      }
      snapshot = null;
      _image = null;
      _uploadedUrl = null;
      _failedUploadUrl = null;
      saved = false;
      error = null;
    } finally {
      busy = false;
      owner.endOperation();
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    if (!busy && !saved && (_uploadedUrl ?? _failedUploadUrl) != null) {
      final url = (_uploadedUrl ?? _failedUploadUrl)!;
      // Cleanup notifications must not run synchronously during widget teardown.
      unawaited(Future<void>.microtask(() => owner.cleanupPhoto(url)));
    }
    super.dispose();
  }
}
