import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static final _short = DateFormat('MMM d, yyyy');
  static final _long = DateFormat('MMMM d, yyyy');
  static final _time = DateFormat('h:mm a');
  static final _dateTime = DateFormat('MMM d, yyyy • h:mm a');

  static String short(DateTime date) => _short.format(date);
  static String long(DateTime date) => _long.format(date);
  static String time(DateTime date) => _time.format(date);
  static String dateTime(DateTime date) => _dateTime.format(date);

  /// Returns "Today", "Yesterday", or formatted date
  static String relative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return short(date);
  }
}
