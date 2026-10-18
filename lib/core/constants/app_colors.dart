import 'package:flutter/material.dart';

/// Paleta de colores oficial de DentalCare Platform (Inspirada en Stitch UI)
class AppColors {
  AppColors._();

  // Primarios Médicos (Teal & Mint)
  static const Color primary = Color(0xFF00A896);
  static const Color primaryDark = Color(0xFF028090);
  static const Color accent = Color(0xFF02C39A);

  // Alertas Médicas Críticas
  static const Color allergyAlert = Color(0xFFD90429); // Badge de alerta severa (Penicilina, etc.)
  static const Color warning = Color(0xFFF77F00);

  // Estados Visuales del Odontograma FDI
  static const Color toothCavity = Color(0xFFE63946); // 🔴 Caries / Patología activa
  static const Color toothRestored = Color(0xFF1D3557); // 🔵 Obturación en buen estado / Corona
  static const Color toothPlanned = Color(0xFFF4A261); // 🟡 Tratamiento planificado
  static const Color toothExecutedToday = Color(0xFF2A9D8F); // 🟢 Tratamiento realizado hoy
  static const Color toothHealthy = Color(0xFFE9ECEF); // Blanco/Gris neutro sano

  // Fondos y Superficies
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F172A); // Modo Quirúrgico
  static const Color surfaceDark = Color(0xFF1E293B);

  // Textos y Bordes
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
}
