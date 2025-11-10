/// Utilidades para sanitizar entradas de usuario y prevenir patrones peligrosos.
class InputSanitizer {
  static final RegExp _controlCharsRegex = RegExp(r'[\u0000-\u001F\u007F]');
  static final RegExp _multiSpaceRegex = RegExp(r'\s+');
  static final RegExp _unsafeHtmlPattern = RegExp(
    r'(<script|</script|<iframe|</iframe|javascript:|onerror\s*=|onload\s*=|data:text/html)',
    caseSensitive: false,
  );

  /// Elimina caracteres de control y espacios sobrantes.
  static String sanitizeBasic(String input) {
    if (input.isEmpty) return '';
    var sanitized = input.replaceAll(_controlCharsRegex, '');
    sanitized = sanitized.replaceAll('\u202E', ''); // Right-to-left override
    sanitized = sanitized.trim();
    return sanitized;
  }

  /// Sanitiza texto de uso libre eliminando posibles etiquetas HTML.
  static String sanitizeFreeText(String input) {
    var sanitized = sanitizeBasic(input);
    sanitized = sanitized.replaceAll('<', '').replaceAll('>', '');
    sanitized = sanitized.replaceAll(_multiSpaceRegex, ' ');
    return sanitized;
  }

  /// Sanitiza valores alfanuméricos (documentos, códigos).
  static String sanitizeAlphanumeric(String input, {bool allowSpaces = true}) {
    var sanitized = sanitizeBasic(input);
    final pattern = allowSpaces
        ? RegExp(r'[^a-zA-Z0-9\s]')
        : RegExp(r'[^a-zA-Z0-9]');
    sanitized = sanitized.replaceAll(pattern, '');
    sanitized = sanitized.replaceAll(_multiSpaceRegex, ' ');
    return sanitized;
  }

  /// Sanitiza direcciones de correo.
  static String sanitizeEmail(String input) {
    final sanitized = sanitizeBasic(input).toLowerCase();
    return sanitized;
  }

  /// Sanitiza números telefónicos (permite + y espacios).
  static String sanitizePhone(String input) {
    final sanitized = sanitizeBasic(input).replaceAll(RegExp(r'[^0-9+\s]'), '');
    return sanitized.replaceAll(_multiSpaceRegex, ' ');
  }

  /// Sanitiza direcciones físicas.
  static String sanitizeAddress(String input) {
    return sanitizeFreeText(input);
  }

  /// Convierte a representación segura para HTML simple.
  static String sanitizeHtml(String input) {
    var sanitized = sanitizeBasic(input);
    sanitized = sanitized
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
    return sanitized;
  }

  /// Verifica si el texto contiene patrones potencialmente peligrosos.
  static bool isSafeText(String input) {
    if (input.isEmpty) return true;
    return !_unsafeHtmlPattern.hasMatch(input);
  }

  /// Devuelve una advertencia si alguno de los valores contiene patrones peligrosos.
  static String? firstSafetyWarning(Iterable<String?> values) {
    for (final value in values) {
      if (value == null) continue;
      if (!isSafeText(value)) {
        return 'Entrada contiene patrones potencialmente peligrosos';
      }
    }
    return null;
  }
}
