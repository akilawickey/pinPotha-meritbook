import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinpotha/providers/posts_provider.dart';
import 'package:pinpotha/services/post_draft.dart';
import 'package:pinpotha/utils/post_utils.dart';
import 'package:pinpotha/models/post.dart';
import '../support/fake_repository.dart';

void main() {
  late FakeRepository repository;
  late PostsProvider owner;
  setUp(() async {
    repository = FakeRepository();
    owner = PostsProvider('a@example.com', repository: repository);
    await Future<void>.delayed(Duration.zero);
  });
  tearDown(() async {
    owner.dispose();
    await repository.close();
  });
  test('rejected save retries same post ID, date and frozen payload', () async {
    final draft = PostDraft(owner);
    repository.failSave = true;
    await draft.submit(note: 'original', date: DateTime(2020, 2, 29));
    expect(draft.error, isNotNull);
    expect(draft.frozen, true);
    repository.failSave = false;
    await draft.submit(note: 'changed', date: DateTime(2021, 1, 1));
    expect(repository.allocations, 1);
    expect(repository.records[owner.email]!.single.note, 'original');
    expect(repository.records[owner.email]!.single.dateKey, '29-02-2020');
    expect(repository.saves[0].postId, repository.saves[1].postId);
    draft.dispose();
  });
  test('pending save prevents duplicates, discard, and tracks active operation',
      () async {
    final draft = PostDraft(owner);
    repository.pendingSave = Completer<void>();
    final pending = draft.submit(note: 'one', date: DateTime(2020));
    expect(owner.activeOperations, 1);
    await draft.submit(note: 'two', date: DateTime(2021));
    expect(repository.saves.length, 1);
    expect(draft.discard(), throwsStateError);
    repository.pendingSave!.complete();
    await pending;
    expect(draft.saved, true);
    expect(owner.activeOperations, 0);
    draft.dispose();
  });
  test(
      'upload retained for retry and cleaned on explicit discard after rejection',
      () async {
    var uploads = 0;
    final draft = PostDraft(owner, upload: (_, id) async {
      uploads++;
      return 'https://example.com/$id';
    });
    repository.failSave = true;
    await draft.submit(
        note: '', date: DateTime(2020), image: File('/unused-fixture'));
    await draft.submit(
        note: '', date: DateTime(2020), image: File('/unused-fixture'));
    expect(uploads, 1);
    expect(repository.deletedPhotos, isEmpty);
    await draft.discard();
    expect(repository.deletedPhotos, ['https://example.com/post-1']);
    draft.dispose();
  });
  test(
      'cleanup rejection remains visible and retryable without restoring a post',
      () async {
    repository.failCleanup = true;
    await owner.cleanupPhoto('https://example.com/photo');
    expect(owner.cleanupPending, {'https://example.com/photo'});
    repository.failCleanup = false;
    await owner.retryCleanup();
    expect(owner.cleanupPending, isEmpty);
  });
  test(
      'offline submission keeps editable draft without allocating/uploading/writing',
      () async {
    owner.connected = false;
    final draft = PostDraft(owner);
    await draft.submit(note: 'offline', date: DateTime(2020));
    expect(draft.frozen, false);
    expect(repository.allocations, 0);
    expect(repository.saves, isEmpty);
    expect(draft.error, isNotNull);
    draft.dispose();
  });
  test('read failure clears stale data and retry owns exactly one subscription',
      () async {
    expect(repository.activeSubscriptions, 1);
    repository.deny(owner.email);
    await Future<void>.delayed(Duration.zero);
    expect(owner.error, isNotNull);
    expect(owner.posts, isEmpty);
    await owner.retry();
    expect(repository.activeSubscriptions, 1);
    expect(owner.error, isNull);
  });
  test('account disposal during upload prevents a database write', () async {
    final temporary =
        PostsProvider('other@example.com', repository: repository);
    await Future<void>.delayed(Duration.zero);
    final upload = Completer<String>();
    final draft = PostDraft(temporary, upload: (_, __) => upload.future);
    final pending = draft.submit(
        note: 'one', date: DateTime(2020), image: File('/unused-fixture'));
    temporary.dispose();
    upload.complete('https://example.com/new-photo');
    await pending;
    expect(repository.saves, isEmpty);
    expect(repository.deletedPhotos, contains('https://example.com/new-photo'));
    expect(draft.error, isNotNull);
    draft.dispose();
  });
  test('failed download URL lookup still cleans uploaded object on discard',
      () async {
    final draft = PostDraft(owner, upload: (_, id) async {
      throw ImageUploadFailure('gs://fixture/photos/$id');
    });
    await draft.submit(
        note: 'photo', date: DateTime(2020), image: File('/fixture'));
    expect(repository.saves, isEmpty);
    await draft.discard();
    expect(repository.deletedPhotos, ['gs://fixture/photos/post-1']);
    draft.dispose();
  });
  test(
      'successful retry after upload failure never schedules deletion of saved photo',
      () async {
    var attempts = 0;
    final draft = PostDraft(owner, upload: (_, id) async {
      if (attempts++ == 0) throw ImageUploadFailure('gs://fixture/photos/$id');
      return 'https://example.com/$id';
    });
    await draft.submit(
        note: 'photo', date: DateTime(2020), image: File('/fixture'));
    await draft.submit(
        note: 'photo', date: DateTime(2020), image: File('/fixture'));
    expect(draft.saved, true);
    draft.dispose();
    expect(repository.deletedPhotos, isEmpty);
    expect(owner.cleanupPending, isEmpty);
  });
  test(
      'deleting an old duplicate preserves a photo referenced by another record',
      () async {
    Post fixture(String day) => Post.fromJson({
          'photoUrl': 'https://example.com/shared',
          'timeStamp': {'server_time': DateTime(2020).millisecondsSinceEpoch}
        }, 'same-id', day);
    final first = fixture('01-01-2020');
    final second = fixture('02-01-2020');
    repository.records[owner.email] = [first, second];
    repository.emit(owner.email);
    await Future<void>.delayed(Duration.zero);
    await owner.deletePost(first);
    expect(repository.deletedPhotos, isEmpty);
    await Future<void>.delayed(Duration.zero);
    await owner.deletePost(second);
    expect(repository.deletedPhotos, ['https://example.com/shared']);
  });
}
