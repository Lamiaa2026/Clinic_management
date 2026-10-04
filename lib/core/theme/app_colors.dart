import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Medical Teal & Blue
  static const Color primary = Color(0xFF0F766E); // Deep Teal
  static const Color primaryDark = Color(0xFF115E59);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primarySubtle = Color(0xFFCCFBF1);

  // Secondary & Accents
  static const Color secondary = Color(0xFF0284C7); // Medical Sky Blue
  static const Color secondaryLight = Color(0xFFE0F2FE);
  static const Color accent = Color(0xFF6366F1); // Modern Indigo

  // Status Colors
  static const Color waiting = Color(0xFFF59E0B); // Amber for Waiting
  static const Color waitingBg = Color(0xFFFEF3C7);
  static const Color inProgress = Color(0xFF0284C7); // Blue for In Consultation
  static const Color inProgressBg = Color(0xFFE0F2FE);
  static const Color completed = Color(0xFF10B981); // Emerald for Completed
  static const Color completedBg = Color(0xFFD1FAE5);
  static const Color cancelled = Color(0xFFEF4444); // Red for Cancelled
  static const Color cancelledBg = Color(0xFFFEE2E2);

  // Neutrals & Backgrounds
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Colors.white;

  // Medical Vitals
  static const Color bpColor = Color(0xFFEF4444);
  static const Color pulseColor = Color(0xFFEC4899);
  static const Color tempColor = Color(0xFFF97316);
  static const Color sugarColor = Color(0xFF8B5CF6);
  static const Color weightColor = Color(0xFF06B6D4);
}
