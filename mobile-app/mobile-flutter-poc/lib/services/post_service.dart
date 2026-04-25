import '../models/post.dart';
import '../models/timestamp_data.dart';
import '../utils/post_utils.dart';

class PostService {

  Stream<List<Post>> getAllPosts(String userId) {
    final postsRef = PostUtils.getPostsRef(userId);
    
    return postsRef.onValue.handleError((error) {
      print('Error in getAllPosts stream: $error');
      // Return empty list on error instead of crashing
      return <Post>[];
    }).map((event) {
      final posts = <Post>[];
      
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          data.forEach((dateKey, dateData) {
            if (dateData is Map) {
              dateData.forEach((postId, postData) {
                if (postData is Map) {
                  try {
                    posts.add(Post.fromJson(postData, postId));
                  } catch (e) {
                    print('Error parsing post $postId: $e');
                  }
                }
              });
            }
          });
        }
      }
      
      // Sort by timestamp descending
      posts.sort((a, b) => b.timeStamp.serverTime.compareTo(a.timeStamp.serverTime));
      
      return posts;
    });
  }

  Stream<List<Post>> getPostsByDate(String userId, DateTime date) {
    final dateStr = PostUtils.formatDateForPath(date);
    final dateRef = PostUtils.getDatePostsRef(userId, dateStr);
    
    return dateRef.onValue.handleError((error) {
      print('Error in getPostsByDate stream: $error');
      // Return empty list on error instead of crashing
      return <Post>[];
    }).map((event) {
      final posts = <Post>[];
      
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          data.forEach((postId, postData) {
            if (postData is Map) {
              try {
                posts.add(Post.fromJson(postData, postId));
              } catch (e) {
                print('Error parsing post $postId: $e');
              }
            }
          });
        }
      }
      
      // Sort by timestamp descending
      posts.sort((a, b) => b.timeStamp.serverTime.compareTo(a.timeStamp.serverTime));
      
      return posts;
    });
  }

  Future<Post> createPost(
    String userId,
    String? note,
    String? photoUrl,
    DateTime date,
  ) async {
    final dateStr = PostUtils.formatDateForPath(date);
    final postsRef = PostUtils.getDatePostsRef(userId, dateStr);
    final newPostRef = postsRef.push();
    
    final post = Post(
      postId: newPostRef.key!,
      note: note,
      photoUrl: photoUrl,
      timeStamp: TimestampData(serverTime: date.millisecondsSinceEpoch),
    );
    
    await newPostRef.set(post.toJson());
    return post;
  }

  Future<Post> updatePost(
    String userId,
    String postId,
    DateTime date,
    String? note,
    String? photoUrl,
    String? oldPhotoUrl,
  ) async {
    final dateStr = PostUtils.formatDateForPath(date);
    final postRef = PostUtils.getPostRef(userId, dateStr, postId);
    
    final post = Post(
      postId: postId,
      note: note,
      photoUrl: photoUrl,
      timeStamp: TimestampData(serverTime: date.millisecondsSinceEpoch),
    );
    
    await postRef.set(post.toJson());
    
    // Delete old image if a new one was uploaded
    if (photoUrl != null && oldPhotoUrl != null && photoUrl != oldPhotoUrl) {
      await PostUtils.deleteImage(oldPhotoUrl);
    }
    
    return post;
  }

  Future<void> deletePost(
    String userId,
    String postId,
    DateTime date,
    String? photoUrl,
  ) async {
    final dateStr = PostUtils.formatDateForPath(date);
    final postRef = PostUtils.getPostRef(userId, dateStr, postId);
    
    await postRef.remove();
    
    // Delete image if it exists
    if (photoUrl != null) {
      await PostUtils.deleteImage(photoUrl);
    }
  }
}

