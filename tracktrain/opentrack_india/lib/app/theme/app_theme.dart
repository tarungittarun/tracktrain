import 'package:flutter/material.dart';

/// Material 3 theme construction for Light, Dark, OLED pure-black and the
/// high-contrast outdoor mode.
class AppTheme {
  AppTheme._();

  static const Color seed = Color(0xFF0B57D0);

  static ThemeData light({required bool highContrast}) {
    var scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    if (highContrast) {
      scheme = scheme.copyWith(
        onSurface: Colors.black,
        primary: const Color(0xFF003A75),
        outline: Colors.black,
      );
    }
    return _base(scheme, highContrast: highContrast);
  }

  static ThemeData dark({required bool highContrast, required bool oled}) {
    var scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    if (oled) {
      // Pure-black surfaces: pixels switch off completely on AMOLED panels,
      // minimizing battery drain on night journeys.
      scheme = scheme.copyWith(
        surface: Colors.black,
        surfaceContainerHighest: const Color(0xFF101010),
        surfaceContainerHigh: const Color(0xFF0C0C0C),
        surfaceContainer: const Color(0xFF080808),
        surfaceContainerLow: Colors.black,
        surfaceContainerLowest: Colors.black,
        onSurface: highContrast ? Colors.white : const Color(0xFFE3E3E3),
      );
    } else if (highContrast) {
      scheme = scheme.copyWith(onSurface: Colors.white);
    }
    return _base(scheme, highContrast: highContrast);
  }

  static ThemeData _base(ColorScheme scheme, {required bool highContrast}) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
    );

    final titleStyle = base.textTheme.titleMedium?.copyWith(
      fontWeight: highContrast ? FontWeight.w800 : FontWeight.w600,
    );
    final bodyStyle = base.textTheme.bodyMedium?.copyWith(
      fontWeight: highContrast ? FontWeight.w700 : FontWeight.w400,
      height: 1.35,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: highContrast ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: highContrast ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      textTheme: base.textTheme.copyWith(
        titleMedium: titleStyle,
        bodyMedium: bodyStyle,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
