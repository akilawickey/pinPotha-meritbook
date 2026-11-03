import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinpotha/models/post.dart';
import 'package:pinpotha/services/post_service.dart';

class RecordingReference implements DatabaseReference {
  final List<(String, Object?)> writes;
  final String location;
  RecordingReference(this.location, this.writes);
  @override
  DatabaseReference child(String path) =>
      RecordingReference('$location/$path', writes);
  @override
  Future<void> set(Object? value) async {
    writes.add((location, value));
  }

  @override
  Future<void> remove() async {
    writes.add((location, null));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
      'note edit and delete target source bucket despite a different displayed day',
      () async {
    final writes = <(String, Object?)>[];
    final service = PostService(
        postReference: (email, date, id) =>
            RecordingReference('$email/$date/$id', writes));
    final post = Post.fromJson({
      'photoUrl': 'https://example.com/p',
      'timeStamp': {
        'server_time': '${DateTime(2026, 11, 3).millisecondsSinceEpoch}'
      }
    }, 'legacy', '01-01-2020');
    await service.updateNote('a@example.com', post, ' updated ');
    expect(writes.single, ('a@example.com/01-01-2020/legacy/note', 'updated'));
    expect(post.toJson()['timeStamp'],
        {'server_time': '${DateTime(2026, 11, 3).millisecondsSinceEpoch}'});
    await service.removePost('a@example.com', post);
    expect(writes.last, ('a@example.com/01-01-2020/legacy', null));
    expect(() => service.updateNote('a@example.com', post, '  '),
        throwsArgumentError);
  });
}
