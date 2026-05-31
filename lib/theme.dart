import 'package:flutter/material.dart';

/// Hawkstronix identity — near-black + gold + redline accents.
class Hawks {
  static const bg = Color(0xFF0D0D0D);
  static const surface = Color(0xFF161616);
  static const surface2 = Color(0xFF1E1E1E);
  static const surface3 = Color(0xFF242424);
  static const gold = Color(0xFFF5C400);
  static const goldBright = Color(0xFFFFD700);
  static const goldDeep = Color(0xFF5A4500);
  static const red = Color(0xFFFF3300);
  static const green = Color(0xFF39FF14);
  static const amber = Color(0xFFFF8C00);
  static const blue = Color(0xFF00BFFF);
  static const text = Color(0xFFFFF8DC);
  static const textMuted = Color(0xFFC8C4A0);
  static const textDim = Color(0xFF999980);
  static const border = Color(0xFF2A2A2A);

  /// Colour for a status word (orders / jobs / stock).
  static Color status(String s) {
    switch (s.toLowerCase()) {
      case 'paid':
      case 'done':
      case 'fulfilled':
      case 'ready':
      case 'in stock':
        return green;
      case 'pending':
      case 'low':
      case 'awaiting parts':
        return amber;
      case 'in progress':
      case 'building':
      case 'tuning':
        return gold;
      case 'new':
      case 'open':
      case 'quoted':
        return blue;
      case 'cancelled':
      case 'out of stock':
        return red;
      default:
        return textMuted;
    }
  }
}

ThemeData hawksTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: Hawks.bg,
    primaryColor: Hawks.gold,
    colorScheme: base.colorScheme.copyWith(
      primary: Hawks.gold,
      secondary: Hawks.gold,
      surface: Hawks.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0A0A),
      foregroundColor: Hawks.gold,
      elevation: 0,
      centerTitle: false,
    ),
    cardColor: Hawks.surface,
    textTheme: base.textTheme.apply(
      bodyColor: Hawks.text,
      displayColor: Hawks.text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Hawks.surface2,
      hintStyle: const TextStyle(color: Hawks.textDim),
      labelStyle: const TextStyle(color: Hawks.textMuted),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Hawks.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Hawks.gold, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Hawks.gold,
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

/// The HAWKS wordmark used in app bars.
Widget hawksWordmark({double size = 22}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('HAWKS',
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: size,
              letterSpacing: 1,
              color: Hawks.gold)),
      Text('troniX',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size * 0.7,
              color: Hawks.textMuted)),
    ],
  );
}
