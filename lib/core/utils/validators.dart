/// Utilidades de validación
class Validators {
  Validators._(); // Constructor privado

  /// Validar email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }

    return null;
  }

  /// Validar contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }

    return null;
  }

  /// Validar campo requerido
  static String? required(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Validar cantidad
  static String? quantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cantidad es requerida';
    }

    final quantity = int.tryParse(value);
    if (quantity == null || quantity < 1) {
      return 'Cantidad inválida';
    }

    return null;
  }

  /// Validar precio
  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'El precio es requerido';
    }

    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return 'Precio inválido';
    }

    return null;
  }

  /// Validar teléfono
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }

    final phoneRegex = RegExp(r'^\d{8,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Teléfono inválido';
    }

    return null;
  }

  /// Sanitizar entrada (prevenir XSS/Injection)
  static String sanitize(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[^\w\s\-\.\@]'), '') // Remove special chars
        .trim();
  }

  /// Validar longitud mínima
  static String? minLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }

    if (value.length < minLength) {
      return 'Mínimo $minLength caracteres';
    }

    return null;
  }

  /// Validar longitud máxima
  static String? maxLength(String? value, int maxLength) {
    if (value != null && value.length > maxLength) {
      return 'Máximo $maxLength caracteres';
    }

    return null;
  }
}
