import 'package:intl/intl.dart';

String formattedTime({required int timeInSecond}) {
  int sec = timeInSecond % 60;
  int min = (timeInSecond / 60).floor();
  String minute = min.toString().length <= 1 ? "0$min" : "$min";
  String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
  return "$minute : $second";
}

/// Format date as singapore time
String formatDateTime(DateTime dateTime, String format) {
  return DateFormat(format).format(
    dateTime.add(
      const Duration(hours: 8), // Make It Singapore Time
    ),
  );
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
