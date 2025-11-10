import 'package:flutter/material.dart';
import '../utils/password_validator.dart';

/// Widget que muestra la fortaleza de una contraseña visualmente
///
/// Características:
/// - Barra de progreso con colores según fortaleza
/// - Texto descriptivo (Débil, Media, Fuerte, Muy Fuerte)
/// - Lista de sugerencias para mejorar la contraseña
/// - Actualización en tiempo real mientras se escribe
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showSuggestions;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showSuggestions = true,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay contraseña, no mostrar nada
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final result = PasswordValidator.validate(password);
    final strength = result.strength;
    final suggestions = PasswordValidator.getSuggestions(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de progreso
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: result.strengthPercentage,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStrengthColor(strength),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Texto de fortaleza
            Text(
              result.strengthText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStrengthColor(strength),
              ),
            ),
          ],
        ),

        // Errores de validación
        if (result.errors.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...result.errors.map((error) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        error,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],

        // Sugerencias para mejorar
        if (showSuggestions && suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sugerencias para mejorar:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...suggestions.map((suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 2, left: 22),
                      child: Text(
                        '• $suggestion',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Obtiene el color según la fortaleza de la contraseña
  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return const Color(0xFFD32F2F); // Rojo
      case PasswordStrength.medium:
        return const Color(0xFFF57C00); // Naranja
      case PasswordStrength.strong:
        return const Color(0xFF388E3C); // Verde
      case PasswordStrength.veryStrong:
        return const Color(0xFF1976D2); // Azul
    }
  }
}

/// Widget simplificado que solo muestra la barra de progreso
/// (sin errores ni sugerencias)
class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final result = PasswordValidator.validate(password);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: result.strengthPercentage,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStrengthColor(result.strength),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          result.strengthText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _getStrengthColor(result.strength),
          ),
        ),
      ],
    );
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return const Color(0xFFD32F2F);
      case PasswordStrength.medium:
        return const Color(0xFFF57C00);
      case PasswordStrength.strong:
        return const Color(0xFF388E3C);
      case PasswordStrength.veryStrong:
        return const Color(0xFF1976D2);
    }
  }
}
