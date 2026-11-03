import 'package:firebase_database/firebase_database.dart';
import '../models/post.dart';
import '../utils/post_utils.dart';

abstract class PostRepository {
  Stream<List<Post>> watchPosts(String email);
  Stream<bool> watchConnection();
  String allocateId(String email);
  Future<void> savePost(String email, Post post);
  Future<void> updateNote(String email, Post post, String note);
  Future<void> removePost(String email, Post post);
  Future<void> deletePhoto(String url);
}

class PostService implements PostRepository {
  final DatabaseReference Function(String email, String dateKey, String postId)
      _postReference;
  PostService(
      {DatabaseReference Function(String, String, String)? postReference})
      : _postReference = postReference ?? PostUtils.getPostRef;
  @override
  Stream<List<Post>> watchPosts(String email) => PostUtils.getPostsRef(email)
      .onValue
      .map((event) => parsePosts(event.snapshot.value));

  static List<Post> parsePosts(Object? value) {
    if (value == null) return [];
    if (value is! Map) throw const FormatException('Invalid posts data');
    final posts = <Post>[];
    for (final date in value.entries) {
      if (date.value is! Map) {
        throw const FormatException('Invalid post date data');
      }
      for (final entry in (date.value as Map).entries) {
        if (entry.value is! Map) {
          throw const FormatException('Invalid post record');
        }
        posts.add(Post.fromJson(
            entry.value as Map, entry.key.toString(), date.key.toString()));
      }
    }
    posts.sort((a, b) {
      final order = b.timeStamp.serverTime.compareTo(a.timeStamp.serverTime);
      return order == 0 ? b.postId.compareTo(a.postId) : order;
    });
    return posts;
  }

  @override
  Stream<bool> watchConnection() => FirebaseDatabase.instance
      .ref('.info/connected')
      .onValue
      .map((event) => event.snapshot.value == true);
  @override
  String allocateId(String email) => PostUtils.getPostsRef(email).push().key!;
  @override
  Future<void> savePost(String email, Post post) =>
      _postReference(email, post.dateKey, post.postId).set(post.toJson());
  @override
  Future<void> updateNote(String email, Post post, String note) {
    if (note.trim().isEmpty) throw ArgumentError('Note cannot be empty');
    // Update only note. Do not rewrite legacy timestamp, photo, or bucket.
    return _postReference(email, post.dateKey, post.postId)
        .child('note')
        .set(note.trim());
  }

  @override
  Future<void> removePost(String email, Post post) =>
      _postReference(email, post.dateKey, post.postId).remove();
  @override
  Future<void> deletePhoto(String url) => PostUtils.deleteImage(url);
}
