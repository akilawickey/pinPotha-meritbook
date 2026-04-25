import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'date_utils.dart' as app_date_utils;

class PostUtils {
  static String getUserEmailPath(String email) {
    return email.replaceAll('.', ',');
  }

  static String formatDateForPath(DateTime date) {
    return app_date_utils.AppDateUtils.formatDate(date, format: 'dd-MM-yyyy');
  }

  static DatabaseReference getPostsRef(String userId) {
    final emailPath = getUserEmailPath(userId);
    return FirebaseDatabase.instance.ref('posts/$emailPath');
  }

  static DatabaseReference getPostRef(String userId, String date, String postId) {
    final emailPath = getUserEmailPath(userId);
    return FirebaseDatabase.instance.ref('posts/$emailPath/$date/$postId');
  }

  static DatabaseReference getDatePostsRef(String userId, String date) {
    final emailPath = getUserEmailPath(userId);
    return FirebaseDatabase.instance.ref('posts/$emailPath/$date');
  }

  static Future<String> uploadImage(File imageFile) async {
    final randomId = DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + (9999 - 1000) * (DateTime.now().millisecondsSinceEpoch % 1000)).toString();
    final imageRef = FirebaseStorage.instance.ref('photos/$randomId');
    
    await imageRef.putFile(imageFile);
    final downloadURL = await imageRef.getDownloadURL();
    
    return downloadURL;
  }

  static Future<void> deleteImage(String photoUrl) async {
    try {
      final url = Uri.parse(photoUrl);
      final pathMatch = RegExp(r'/o/(.+?)(\?|$)').firstMatch(url.path);
      if (pathMatch != null) {
        final decodedPath = Uri.decodeComponent(pathMatch.group(1)!);
        final imageRef = FirebaseStorage.instance.ref(decodedPath);
        await imageRef.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw - image deletion failure shouldn't prevent post deletion
    }
  }
}

