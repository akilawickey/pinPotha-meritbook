class TimestampData {
  final int serverTime;
  final Object? rawValue;
  final bool isFallback;

  const TimestampData(
      {required this.serverTime, this.rawValue, this.isFallback = false});

  factory TimestampData.fromJson(Map<dynamic, dynamic> json,
      {required DateTime fallback}) {
    final value = json['server_time'];
    final parsed = value is int
        ? value
        : value is String
            ? int.tryParse(value)
            : null;
    // Guard DateTime's supported range; invalid history must never become "today".
    final valid = parsed != null &&
        parsed >= -8640000000000000 &&
        parsed <= 8640000000000000;
    return TimestampData(
      serverTime: valid ? parsed : fallback.millisecondsSinceEpoch,
      rawValue: value,
      isFallback: !valid,
    );
  }

  Map<String, dynamic> toJson() => {'server_time': rawValue ?? serverTime};
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(serverTime);
}
