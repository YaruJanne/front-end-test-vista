import 'package:material_ui/material_ui.dart';

/// Minimal "SaaS" look: neutral slate/zinc surfaces, one indigo accent,
/// hairline borders and 8px rounded controls.
class AppTheme {
  static ThemeData light() => _build(_lightScheme);
  static ThemeData dark() => _build(_darkScheme);

  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF4F46E5),
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF4F46E5),
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFEEF2FF),
    onPrimaryContainer: const Color(0xFF3730A3),
    surface: Colors.white,
    onSurface: const Color(0xFF0F172A),
    onSurfaceVariant: const Color(0xFF64748B),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFF8FAFC),
    surfaceContainer: const Color(0xFFF1F5F9),
    surfaceContainerHigh: const Color(0xFFE2E8F0),
    surfaceContainerHighest: const Color(0xFFE2E8F0),
    outline: const Color(0xFFCBD5E1),
    outlineVariant: const Color(0xFFE2E8F0),
    error: const Color(0xFFDC2626),
    errorContainer: const Color(0xFFFEF2F2),
    onErrorContainer: const Color(0xFF991B1B),
  );

  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF4F46E5),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF818CF8),
    onPrimary: const Color(0xFF1E1B4B),
    primaryContainer: const Color(0xFF1E1B4B),
    onPrimaryContainer: const Color(0xFFC7D2FE),
    surface: const Color(0xFF18181B),
    onSurface: const Color(0xFFFAFAFA),
    onSurfaceVariant: const Color(0xFFA1A1AA),
    surfaceContainerLowest: const Color(0xFF18181B),
    surfaceContainerLow: const Color(0xFF0F0F12),
    surfaceContainer: const Color(0xFF1F1F23),
    surfaceContainerHigh: const Color(0xFF27272A),
    surfaceContainerHighest: const Color(0xFF27272A),
    outline: const Color(0xFF52525B),
    outlineVariant: const Color(0xFF27272A),
    error: const Color(0xFFF87171),
    errorContainer: const Color(0xFF450A0A),
    onErrorContainer: const Color(0xFFFECACA),
  );

  static ThemeData _build(ColorScheme scheme) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
    const label = TextStyle(fontWeight: FontWeight.w600);

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainerLow,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: shape, padding: padding, textStyle: label),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          padding: padding,
          textStyle: label,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: shape, textStyle: label),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
    );
  }
}
