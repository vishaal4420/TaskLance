import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _shortDate = DateFormat('MMM d, yyyy');
  static final _longDate = DateFormat('MMMM d, yyyy');
  static final _monthYear = DateFormat('MMM yyyy');
  static final _dayMonth = DateFormat('d MMM');
  static final _time = DateFormat('h:mm a');
  static final _dateTime = DateFormat('MMM d, yyyy • h:mm a');

  static String format(DateTime date) => _shortDate.format(date);

  static String formatLong(DateTime date) => _longDate.format(date);

  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  static String formatDayMonth(DateTime date) => _dayMonth.format(date);

  static String formatTime(DateTime date) => _time.format(date);

  static String formatDateTime(DateTime date) => _dateTime.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return _shortDate.format(date);
  }

  static String daysUntil(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff < 0) return '${diff.abs()} days overdue';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    return 'Due in $diff days';
  }

  static String deadlineLabel(DateTime date) {
    final diff = date.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Overdue by ${(-diff)} days';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    return 'Due ${_shortDate.format(date)}';
  }
}
