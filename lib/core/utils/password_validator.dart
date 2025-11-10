/// Validador de contraseñas según estándares NIST 800-63B y OWASP
///
/// Características:
/// - Mínimo 8 caracteres (NIST recomienda 8+)
/// - Al menos una mayúscula
/// - Al menos una minúscula
/// - Al menos un número
/// - Al menos un carácter especial
/// - Detección de contraseñas comunes
/// - Cálculo de fortaleza (débil, media, fuerte, muy fuerte)
class PasswordValidator {
  // Contraseñas comunes a evitar (lista reducida para ejemplo)
  static const List<String> _commonPasswords = [
    'password',
    '123456',
    '12345678',
    'qwerty',
    'abc123',
    'monkey',
    '1234567',
    'letmein',
    'trustno1',
    'dragon',
    'baseball',
    'iloveyou',
    'master',
    'sunshine',
    'ashley',
    'bailey',
    'passw0rd',
    'shadow',
    'superman',
    'qazwsx',
    'michael',
    'football',
  ];

  /// Valida si una contraseña cumple con los requisitos mínimos
  static PasswordValidationResult validate(String password) {
    final errors = <String>[];

    // Validar longitud mínima (NIST 800-63B recomienda 8+)
    if (password.length < 8) {
      errors.add('La contraseña debe tener al menos 8 caracteres');
    }

    // Validar longitud máxima razonable (prevenir ataques de denegación de servicio)
    if (password.length > 128) {
      errors.add('La contraseña no debe exceder 128 caracteres');
    }

    // Validar que contenga al menos una mayúscula
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('La contraseña debe contener al menos una letra mayúscula');
    }

    // Validar que contenga al menos una minúscula
    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('La contraseña debe contener al menos una letra minúscula');
    }

    // Validar que contenga al menos un número
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('La contraseña debe contener al menos un número');
    }

    // Validar que contenga al menos un carácter especial
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]'))) {
      errors.add('La contraseña debe contener al menos un carácter especial (!@#\$%^&*...)');
    }

    // Validar contra contraseñas comunes
    if (_commonPasswords.contains(password.toLowerCase())) {
      errors.add('Esta contraseña es muy común. Por favor, usa una contraseña más segura');
    }

    // Validar que no contenga espacios
    if (password.contains(' ')) {
      errors.add('La contraseña no debe contener espacios');
    }

    final strength = calculateStrength(password);
    final isValid = errors.isEmpty;

    return PasswordValidationResult(
      isValid: isValid,
      errors: errors,
      strength: strength,
    );
  }

  /// Calcula la fortaleza de la contraseña (0-100)
  static PasswordStrength calculateStrength(String password) {
    int score = 0;

    // Longitud: +20 puntos por tener al menos 8 caracteres
    if (password.length >= 8) {
      score += 20;
      // +10 puntos adicionales por cada 2 caracteres extras
      score += ((password.length - 8) ~/ 2) * 10;
    }

    // Mayúsculas: +10 puntos
    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 10;
    }

    // Minúsculas: +10 puntos
    if (password.contains(RegExp(r'[a-z]'))) {
      score += 10;
    }

    // Números: +10 puntos
    if (password.contains(RegExp(r'[0-9]'))) {
      score += 10;
    }

    // Caracteres especiales: +15 puntos
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]'))) {
      score += 15;
    }

    // Diversidad de caracteres: +15 puntos
    final uniqueChars = password.split('').toSet().length;
    if (uniqueChars >= password.length * 0.7) {
      score += 15;
    }

    // No usar contraseñas comunes: -30 puntos
    if (_commonPasswords.contains(password.toLowerCase())) {
      score -= 30;
    }

    // Patrones repetitivos: -15 puntos
    if (_hasRepetitivePatterns(password)) {
      score -= 15;
    }

    // Secuencias: -15 puntos (123, abc, etc.)
    if (_hasSequences(password)) {
      score -= 15;
    }

    // Limitar score entre 0-100
    score = score.clamp(0, 100);

    // Determinar nivel de fortaleza
    if (score < 40) {
      return PasswordStrength.weak;
    } else if (score < 60) {
      return PasswordStrength.medium;
    } else if (score < 80) {
      return PasswordStrength.strong;
    } else {
      return PasswordStrength.veryStrong;
    }
  }

  /// Detecta patrones repetitivos (aaa, 111, etc.)
  static bool _hasRepetitivePatterns(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      if (password[i] == password[i + 1] && password[i] == password[i + 2]) {
        return true;
      }
    }
    return false;
  }

  /// Detecta secuencias (123, abc, etc.)
  static bool _hasSequences(String password) {
    final sequences = [
      '0123456789',
      '9876543210',
      'abcdefghijklmnopqrstuvwxyz',
      'zyxwvutsrqponmlkjihgfedcba',
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
      'ZYXWVUTSRQPONMLKJIHGFEDCBA',
      'qwertyuiop',
      'asdfghjkl',
      'zxcvbnm',
    ];

    for (final sequence in sequences) {
      for (int i = 0; i < sequence.length - 3; i++) {
        final substr = sequence.substring(i, i + 4);
        if (password.toLowerCase().contains(substr)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Genera sugerencias para mejorar la contraseña
  static List<String> getSuggestions(String password) {
    final suggestions = <String>[];

    if (password.length < 12) {
      suggestions.add('Usa al menos 12 caracteres para mayor seguridad');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      suggestions.add('Agrega letras mayúsculas');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      suggestions.add('Agrega letras minúsculas');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      suggestions.add('Agrega números');
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]'))) {
      suggestions.add('Agrega caracteres especiales (!@#\$%^&*...)');
    }

    if (_hasRepetitivePatterns(password)) {
      suggestions.add('Evita caracteres repetitivos (aaa, 111)');
    }

    if (_hasSequences(password)) {
      suggestions.add('Evita secuencias comunes (123, abc)');
    }

    if (_commonPasswords.contains(password.toLowerCase())) {
      suggestions.add('Esta contraseña es muy común, usa una única');
    }

    final uniqueChars = password.split('').toSet().length;
    if (uniqueChars < password.length * 0.6) {
      suggestions.add('Usa una mayor variedad de caracteres');
    }

    return suggestions;
  }
}

/// Resultado de la validación de contraseña
class PasswordValidationResult {
  final bool isValid;
  final List<String> errors;
  final PasswordStrength strength;

  const PasswordValidationResult({
    required this.isValid,
    required this.errors,
    required this.strength,
  });

  /// Obtiene el color asociado a la fortaleza (para UI)
  String get strengthColor {
    switch (strength) {
      case PasswordStrength.weak:
        return '#D32F2F'; // Rojo
      case PasswordStrength.medium:
        return '#F57C00'; // Naranja
      case PasswordStrength.strong:
        return '#388E3C'; // Verde
      case PasswordStrength.veryStrong:
        return '#1976D2'; // Azul
    }
  }

  /// Obtiene el texto descriptivo de la fortaleza
  String get strengthText {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Débil';
      case PasswordStrength.medium:
        return 'Media';
      case PasswordStrength.strong:
        return 'Fuerte';
      case PasswordStrength.veryStrong:
        return 'Muy Fuerte';
    }
  }

  /// Obtiene el porcentaje de fortaleza para barras de progreso (0.0 - 1.0)
  double get strengthPercentage {
    switch (strength) {
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.50;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }
}

/// Niveles de fortaleza de contraseña
enum PasswordStrength {
  weak,       // 0-39 puntos
  medium,     // 40-59 puntos
  strong,     // 60-79 puntos
  veryStrong, // 80-100 puntos
}
