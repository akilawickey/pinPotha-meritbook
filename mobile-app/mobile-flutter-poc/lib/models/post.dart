import 'timestamp_data.dart';

class Post {
  final String postId;
  final String? note;
  final String? photoUrl;
  final TimestampData timeStamp;

  Post({
    required this.postId,
    this.note,
    this.photoUrl,
    required this.timeStamp,
  });

  factory Post.fromJson(Map<dynamic, dynamic> json, String postId) {
    return Post(
      postId: postId,
      note: json['note'] as String?,
      photoUrl: json['photoUrl'] as String?,
      timeStamp: TimestampData.fromJson(json['timeStamp'] as Map<dynamic, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'note': note,
      'photoUrl': photoUrl,
      'timeStamp': timeStamp.toJson(),
    };
  }

  Post copyWith({
    String? postId,
    String? note,
    String? photoUrl,
    TimestampData? timeStamp,
  }) {
    return Post(
      postId: postId ?? this.postId,
      note: note ?? this.note,
      photoUrl: photoUrl ?? this.photoUrl,
      timeStamp: timeStamp ?? this.timeStamp,
    );
  }
}


