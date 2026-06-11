import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String format(DateTime date, {String pattern = 'MMM d, yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatShort(DateTime date) => DateFormat('MMM d').format(date);

  static String formatFull(DateTime date) => DateFormat('MMMM d, yyyy').format(date);

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  static String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

  static String monthName(int month) {
    return DateFormat('MMM').format(DateTime(2024, month));
  }
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  static final _formatterDecimal = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  static String format(double amount, {bool showCents = false}) {
    return showCents ? _formatterDecimal.format(amount) : _formatter.format(amount);
  }

  static String compact(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}K';
    return '\$${amount.toStringAsFixed(0)}';
  }
}

class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? Function(String?) minLength(int min) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return 'This field is required';
      if (value.trim().length < min) return 'Minimum $min characters required';
      return null;
    };
  }

  static String? numeric(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value.trim()) == null) return 'Enter a valid number';
    return null;
  }
}
