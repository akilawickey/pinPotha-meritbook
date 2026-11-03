import 'timestamp_data.dart';
import '../utils/date_utils.dart';

class Post {
  final String postId;
  // The original Firebase bucket is identity, independent of display timezone.
  final String dateKey;
  final String? note;
  final String? photoUrl;
  final TimestampData timeStamp;

  const Post(
      {required this.postId,
      required this.dateKey,
      this.note,
      this.photoUrl,
      required this.timeStamp});

  factory Post.fromJson(
      Map<dynamic, dynamic> json, String postId, String dateKey) {
    final fallback = AppDateUtils.parseDateKey(dateKey);
    final timestamp = json['timeStamp'];
    return Post(
      postId: postId,
      dateKey: dateKey,
      note: json['note'] is String ? json['note'] as String : null,
      photoUrl:
          json['photoUrl'] is String && (json['photoUrl'] as String).isNotEmpty
              ? json['photoUrl'] as String
              : null,
      timeStamp: TimestampData.fromJson(timestamp is Map ? timestamp : {},
          fallback: fallback),
    );
  }

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'note': note,
        'photoUrl': photoUrl,
        'timeStamp': timeStamp.toJson(),
      };

  DateTime get displayDate => timeStamp.date;
  String get shareText => [
        if (note?.trim().isNotEmpty ?? false) note!.trim(),
        if (photoUrl != null) photoUrl!
      ].join('\n\n');
  bool matches(String query) {
    final text = query.trim().toLowerCase();
    return (note ?? '').toLowerCase().contains(text) ||
        AppDateUtils.formatDate(displayDate).contains(text);
  }
}
