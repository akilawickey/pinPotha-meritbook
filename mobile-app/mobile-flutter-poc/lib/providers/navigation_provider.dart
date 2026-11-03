import 'package:flutter/foundation.dart';
import '../utils/date_utils.dart';

class NavigationProvider extends ChangeNotifier {
  int index = 0;
  DateTime selectedDate = AppDateUtils.getStartOfDay(DateTime.now());
  void select(int value) {
    if (index != value) {
      index = value;
      notifyListeners();
    }
  }

  void selectDate(DateTime date) {
    selectedDate = AppDateUtils.getStartOfDay(date);
    notifyListeners();
  }

  void showSavedDate(DateTime date) {
    selectedDate = AppDateUtils.getStartOfDay(date);
    index = 0;
    notifyListeners();
  }
}
