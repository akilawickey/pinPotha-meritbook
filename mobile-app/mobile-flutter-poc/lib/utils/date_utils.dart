import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date, {String format = 'dd-MM-yyyy'}) =>
      DateFormat(format).format(date);

  static DateTime parseDateKey(String key) {
    final match = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(key);
    if (match == null) throw FormatException('Invalid post date bucket', key);
    final day = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final year = int.parse(match[3]!);
    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month || date.year != year) {
      throw FormatException('Invalid post date bucket', key);
    }
    return date;
  }

  static DateTime getStartOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);
  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  static String formatTime(DateTime date) => DateFormat('HH:mm').format(date);
}
