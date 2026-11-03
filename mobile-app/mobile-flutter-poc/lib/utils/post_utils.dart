import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'date_utils.dart';

class ImageUploadFailure implements Exception {
  final String objectUrl;
  const ImageUploadFailure(this.objectUrl);
  @override
  String toString() => 'Photo upload failed. Retry or discard this draft.';
}

class PostUtils {
  static String getUserEmailPath(String email) {
    if (email.trim().isEmpty) {
      throw ArgumentError('A signed-in email is required');
    }
    return email.replaceAll('.', ',');
  }

  static String formatDateForPath(DateTime date) =>
      AppDateUtils.formatDate(date);
  static DatabaseReference getPostsRef(String email) =>
      FirebaseDatabase.instance.ref('posts/${getUserEmailPath(email)}');
  static DatabaseReference getPostRef(
          String email, String dateKey, String postId) =>
      getPostsRef(email).child(dateKey).child(postId);
  static Future<String> uploadImage(File file, String objectId) async {
    final ref = FirebaseStorage.instance.ref('photos/$objectId');
    try {
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (_) {
      // Even if fetching the download URL fails, the object may already exist.
      throw ImageUploadFailure('gs://${ref.bucket}/${ref.fullPath}');
    }
  }

  static Future<void> deleteImage(String url) async {
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
  }
}
