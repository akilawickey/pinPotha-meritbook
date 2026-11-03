import 'package:flutter_test/flutter_test.dart';
import 'package:pinpotha/models/post.dart';
import 'package:pinpotha/models/post_page.dart';
import 'package:pinpotha/services/post_service.dart';
import 'package:pinpotha/utils/date_utils.dart';

void main() {
  test('legacy string timestamp and wire schema survive parsing', () {
    final millis = DateTime(2020, 2, 29, 12).millisecondsSinceEpoch;
    final post = Post.fromJson({
      'note': 'පින් දහම්',
      'photoUrl': 'https://example.com/photo',
      'timeStamp': {'server_time': '$millis'}
    }, 'legacy', '28-02-2020');
    expect(post.dateKey, '28-02-2020');
    expect(post.displayDate, DateTime(2020, 2, 29, 12));
    expect(post.toJson()['timeStamp'], {'server_time': '$millis'});
    expect(post.toJson().containsKey('dateKey'), false);
    expect(post.matches(' පින් '), true);
    expect(post.matches('29-02-2020'), true);
    expect(post.shareText, 'පින් දහම්\n\nhttps://example.com/photo');
  });
  test('malformed timestamps fall back to saved bucket rather than today', () {
    for (final timestamp in [
      null,
      'bad',
      -999999999999999999,
      999999999999999999,
      {'.sv': 'timestamp'}
    ]) {
      final post = Post.fromJson({
        'timeStamp': {'server_time': timestamp}
      }, 'photo-only', '29-02-2020');
      expect(post.displayDate, DateTime(2020, 2, 29));
      expect(post.timeStamp.isFallback, true);
      expect(post.note, isNull);
    }
  });
  test('invalid buckets fail visibly and never normalize to another day', () {
    expect(
        () => AppDateUtils.parseDateKey('31-02-2020'), throwsFormatException);
    expect(
        () => AppDateUtils.parseDateKey('2020-02-29'), throwsFormatException);
  });
  test('service parses date buckets independently even for duplicate IDs', () {
    final posts = PostService.parsePosts({
      '01-01-2020': {
        'same-id': {
          'timeStamp': {'server_time': '1577836800000'}
        }
      },
      '02-01-2020': {
        'same-id': {
          'photoUrl': 'https://example.com/p',
          'timeStamp': {'server_time': 1577923200000}
        }
      },
    });
    expect(posts.length, 2);
    expect(posts.first.dateKey, '02-01-2020');
    expect(() => PostService.parsePosts({'01-01-2020': 'broken'}),
        throwsFormatException);
  });
  test('page size changes work and deletions clamp the last page', () {
    final paging = PostPage()..resize(6);
    paging.page = 3;
    expect(paging.items(List.generate(13, (i) => i)), [12]);
    expect(paging.items(List.generate(12, (i) => i)), [6, 7, 8, 9, 10, 11]);
    expect(paging.page, 2);
    paging.resize(24);
    expect(paging.page, 1);
    expect(paging.items(<int>[]), isEmpty);
  });
  test('valid dates before 1970 keep their timestamp rather than fallback', () {
    final date = DateTime(1950, 1, 2);
    final post = Post.fromJson({
      'timeStamp': {'server_time': date.millisecondsSinceEpoch}
    }, 'historical', '01-01-1950');
    expect(post.timeStamp.isFallback, false);
    expect(post.displayDate, date);
    expect(post.dateKey, '01-01-1950');
  });
}
