import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeParser {
  DateTime? parseDateTime(String dateStr, String format) {
    try {
      final DateFormat formatter = DateFormat(format);
      return formatter.parse(dateStr);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }

  /// Format a DateTime object to a string using custom format
  String formatDateTime(DateTime dateTime, String format) {
    final DateFormat formatter = DateFormat(format);
    return formatter.format(dateTime);
  }
}
