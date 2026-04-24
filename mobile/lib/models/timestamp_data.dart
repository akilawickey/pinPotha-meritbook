class TimestampData {
  final int serverTime;

  TimestampData({required this.serverTime});

  factory TimestampData.fromJson(Map<dynamic, dynamic> json) {
    dynamic serverTime = json['server_time'];
    
    // Handle Firebase ServerValue.TIMESTAMP object format
    if (serverTime is Map && serverTime.containsKey('.sv')) {
      serverTime = DateTime.now().millisecondsSinceEpoch;
    }
    
    // Handle string timestamps
    if (serverTime is String) {
      serverTime = int.tryParse(serverTime) ?? DateTime.now().millisecondsSinceEpoch;
    }
    
    // Ensure it's a number
    if (serverTime is! int) {
      serverTime = DateTime.now().millisecondsSinceEpoch;
    }
    
    return TimestampData(serverTime: serverTime);
  }

  Map<String, dynamic> toJson() {
    return {
      'server_time': serverTime,
    };
  }

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(serverTime);
}

