import 'package:flutter/material.dart';

/// Paleta de colores del sistema - Tema Munani (Barritas Nutritivas)
class AppColors {
  AppColors._(); // Constructor privado para prevenir instanciación

  // Colores Principales - Tema Marrón/Caramelo
  static const Color primaryBrown = Color(0xFF8B6F47); // Marrón principal para botones
  static const Color primaryCaramel = Color(0xFFD4A574); // Caramelo para fondos
  static const Color primaryLightCaramel = Color(0xFFE8D5B7); // Caramelo claro
  static const Color primaryDarkBrown = Color(0xFF6B5435); // Marrón oscuro
  
  // Colores de Superficie
  static const Color surfaceBeige = Color(0xFFF5E6D3); // Beige para cards
  static const Color surfaceLightBeige = Color(0xFFFAF0E6); // Beige muy claro
  
  // Colores Secundarios
  static const Color accentGold = Color(0xFFC9A961); // Dorado para bordes del logo
  static const Color accentLightGold = Color(0xFFE5D4A8); // Dorado claro
  
  // Colores de compatibilidad (para código existente)
  static const Color accentBlue = Color(0xFF5D7A8C); // Azul apagado que combina con marrón
  static const Color accentGreen = Color(0xFF6B8E5A); // Verde apagado que combina con marrón
  static const Color accentGrey = Color(0xFF8B7D6B); // Gris marrón

  // Colores de Estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF42A5F5);

  // Neutros
  static const Color background = Color(0xFFD4A574); // Fondo caramelo (splash/login)
  static const Color surface = Color(0xFFF5E6D3); // Superficie beige
  static const Color textPrimary = Color(0xFF3E2723); // Texto marrón oscuro
  static const Color textSecondary = Color(0xFF6B5435); // Texto marrón medio
  static const Color textLight = Color(0xFFFAFAFA); // Texto claro/blanco
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0D4C0); // Divisor beige

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryCaramel, primaryBrown],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGold, primaryBrown],
  );
  
  // Mantener compatibilidad con código existente
  static const Color primaryOrange = primaryBrown;
  static const Color primaryAmber = primaryCaramel;
}
