import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date, {String format = 'dd-MM-yyyy'}) {
    if (date.isBefore(DateTime(1900))) {
      return 'Invalid date';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    switch (format) {
      case 'dd MMM yyyy':
        return DateFormat('dd MMM yyyy').format(date);
      case 'dd MMMM yyyy':
        return DateFormat('dd MMMM yyyy').format(date);
      case 'dd-MM-yyyy':
        return '$day-$month-$year';
      default:
        return '$day-$month-$year';
    }
  }

  static DateTime getDateFromMillis(int millis) {
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  static int getMillisFromDate(DateTime date) {
    return date.millisecondsSinceEpoch;
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static String formatTime(DateTime date) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

