import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.imagePlate,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.primary,
    required this.primarySoft,
    required this.success,
    required this.successSoft,
    required this.danger,
    required this.dangerSoft,
    required this.warning,
    required this.warningSoft,
    required this.navy,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color imagePlate;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color primary;
  final Color primarySoft;
  final Color success;
  final Color successSoft;
  final Color danger;
  final Color dangerSoft;
  final Color warning;
  final Color warningSoft;
  final Color navy;
  final Color shadow;

  static const light = AppPalette(
    background: Color(0xFFF4F8FC),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF8FAFD),
    imagePlate: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0B1220),
    textSecondary: Color(0xFF667085),
    border: Color(0xFFE6EDF6),
    primary: Color(0xFF2F8BF7),
    primarySoft: Color(0xFFDCEDFF),
    success: Color(0xFF12A150),
    successSoft: Color(0xFFE9F8EF),
    danger: Color(0xFFEF4444),
    dangerSoft: Color(0xFFFEECEC),
    warning: Color(0xFFF59E0B),
    warningSoft: Color(0xFFFFF5E5),
    navy: Color(0xFF0A1733),
    shadow: Color(0x140F2850),
  );

  static const dark = AppPalette(
    background: Color(0xFF0A1220),
    surface: Color(0xFF121C2E),
    surfaceAlt: Color(0xFF0F1828),
    imagePlate: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFF4F7FB),
    textSecondary: Color(0xFF95A3B8),
    border: Color(0xFF24314A),
    primary: Color(0xFF4AA3FF),
    primarySoft: Color(0xFF17345C),
    success: Color(0xFF34D399),
    successSoft: Color(0xFF123A2C),
    danger: Color(0xFFF87171),
    dangerSoft: Color(0xFF3A1A1E),
    warning: Color(0xFFFBBF24),
    warningSoft: Color(0xFF3A2E12),
    navy: Color(0xFF07101F),
    shadow: Color(0x66000000),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? imagePlate,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? primary,
    Color? primarySoft,
    Color? success,
    Color? successSoft,
    Color? danger,
    Color? dangerSoft,
    Color? warning,
    Color? warningSoft,
    Color? navy,
    Color? shadow,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      imagePlate: imagePlate ?? this.imagePlate,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      navy: navy ?? this.navy,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      imagePlate: Color.lerp(imagePlate, other.imagePlate, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      navy: Color.lerp(navy, other.navy, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
