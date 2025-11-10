import 'package:intl/intl.dart';

/// Utilidades para formatear fechas
class DateFormatter {
  DateFormatter._(); // Constructor privado

  /// Formato: dd/MM/yyyy
  static String toDateString(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formato: HH:mm
  static String toTimeString(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Formato: dd/MM/yyyy HH:mm
  static String toDateTimeString(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Formato: dd MMM yyyy (Ej: 15 Oct 2024)
  static String toLongDateString(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es').format(date);
  }

  /// Formato relativo (hace 5 minutos, hace 2 horas, etc)
  static String toRelativeString(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds} segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      return 'Hace ${(difference.inDays / 7).floor()} semanas';
    } else if (difference.inDays < 365) {
      return 'Hace ${(difference.inDays / 30).floor()} meses';
    } else {
      return 'Hace ${(difference.inDays / 365).floor()} años';
    }
  }

  /// Parsear string a DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parsear string con hora a DateTime
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }
}
