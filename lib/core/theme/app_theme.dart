import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const List<String> _koreanFontFallback = [
    'Malgun Gothic',
    'Apple SD Gothic Neo',
    'Noto Sans KR',
    'Nanum Gothic',
    'sans-serif',
  ];

  static ThemeData buildTheme({
    required Brightness brightness,
    required double fontSizeMultiplier,
  }) {
    final isDark = brightness == Brightness.dark;
    const seedColor = Color(0xFF1E3A5F);
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final scaffoldBackground =
        isDark ? const Color(0xFF0A0F1A) : const Color(0xFFF5F6F8);
    final cardColor =
        isDark ? const Color(0xFF121A2A) : const Color(0xFFFFFFFF);

    // 요청하신 팔레트: 본문(라이트=검정, 다크=흰색) + 포인트(빨강) + 보조(파랑/초록)
    final primaryColor =
        isDark ? const Color(0xFF4F8CFF) : const Color(0xFF1E3A5F);
    final accentColor =
        isDark ? const Color(0xFFFF5A64) : const Color(0xFFC62828);
    final tertiaryColor =
        isDark ? const Color(0xFF39D98A) : const Color(0xFF1F8A4C);

    final onSurface =
        isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111111);
    final secondaryText =
        isDark ? const Color(0xFFB8C4D9) : const Color(0xFF4A5568);
    final dividerColor =
        isDark ? const Color(0xFF2A3650) : const Color(0xFFD7DCE4);
    final inputFillColor =
        isDark ? const Color(0xFF18243A) : const Color(0xFFF1F4F8);

    final colorScheme = baseScheme.copyWith(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      onSecondary: Colors.white,
      tertiary: tertiaryColor,
      onTertiary: isDark ? const Color(0xFF062015) : Colors.white,
      surface: cardColor,
      onSurface: onSurface,
      error: isDark ? const Color(0xFFFF6B74) : const Color(0xFFD32F2F),
      onError: Colors.white,
      surfaceTint: primaryColor,
    );

    final baseTextTheme = isDark
        ? ThemeData.dark(useMaterial3: true).textTheme
        : ThemeData.light(useMaterial3: true).textTheme;
    final textTheme = _buildTextTheme(
      baseTextTheme,
      fontSizeMultiplier: fontSizeMultiplier,
      primaryTextColor: onSurface,
      secondaryTextColor: secondaryText,
    );

    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'NanumGothic',
      fontFamilyFallback: _koreanFontFallback,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      cardColor: cardColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: cardColor,
        margin: EdgeInsets.zero,
        shape: roundedShape,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: isDark ? const Color(0xFF0F1728) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? const Color(0xFF1B2A44) : const Color(0xFF1E3A5F),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          textStyle:
              textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          shape: roundedShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: dividerColor),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          textStyle:
              textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          shape: roundedShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle:
              textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        iconColor: secondaryText,
        textColor: onSurface,
        titleTextStyle: textTheme.titleSmall?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(color: secondaryText),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: textTheme.bodyMedium?.copyWith(color: secondaryText),
        labelStyle: textTheme.titleSmall?.copyWith(color: secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: primaryColor, width: 1.4),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: roundedShape,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withAlpha(56),
        thumbColor: primaryColor,
        overlayColor: primaryColor.withAlpha(30),
        valueIndicatorColor: primaryColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return isDark ? const Color(0xFFD7E3F8) : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tertiaryColor;
          }
          return isDark ? const Color(0xFF46516A) : const Color(0xFFD6DCE6);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: dividerColor),
          ),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static TextTheme _buildTextTheme(
    TextTheme base, {
    required double fontSizeMultiplier,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final scale = 1.0 + (fontSizeMultiplier - fontSizeMultiplier);

    TextStyle? restyle(
      TextStyle? style, {
      required Color color,
      FontWeight? weight,
      double? letterSpacing,
    }) {
      if (style == null) {
        return null;
      }

      return style.copyWith(
        color: color,
        fontSize: style.fontSize == null ? null : style.fontSize! * scale,
        fontWeight: weight ?? style.fontWeight,
        letterSpacing: letterSpacing,
        height: 1.3,
      );
    }

    return base.copyWith(
      displayLarge: restyle(base.displayLarge,
          color: primaryTextColor,
          weight: FontWeight.w800,
          letterSpacing: -1.3),
      displayMedium: restyle(base.displayMedium,
          color: primaryTextColor,
          weight: FontWeight.w800,
          letterSpacing: -1.0),
      displaySmall: restyle(base.displaySmall,
          color: primaryTextColor,
          weight: FontWeight.w800,
          letterSpacing: -0.8),
      headlineLarge: restyle(base.headlineLarge,
          color: primaryTextColor,
          weight: FontWeight.w800,
          letterSpacing: -0.7),
      headlineMedium: restyle(base.headlineMedium,
          color: primaryTextColor,
          weight: FontWeight.w800,
          letterSpacing: -0.5),
      headlineSmall: restyle(base.headlineSmall,
          color: primaryTextColor,
          weight: FontWeight.w800,
          letterSpacing: -0.3),
      titleLarge: restyle(base.titleLarge,
          color: primaryTextColor,
          weight: FontWeight.w800,
          letterSpacing: -0.2),
      titleMedium: restyle(base.titleMedium,
          color: primaryTextColor, weight: FontWeight.w700),
      titleSmall: restyle(base.titleSmall,
          color: primaryTextColor, weight: FontWeight.w700),
      bodyLarge: restyle(base.bodyLarge, color: primaryTextColor),
      bodyMedium: restyle(base.bodyMedium, color: primaryTextColor),
      bodySmall: restyle(base.bodySmall, color: secondaryTextColor),
      labelLarge: restyle(base.labelLarge,
          color: primaryTextColor, weight: FontWeight.w700),
      labelMedium: restyle(base.labelMedium,
          color: secondaryTextColor, weight: FontWeight.w600),
      labelSmall: restyle(base.labelSmall,
          color: secondaryTextColor, weight: FontWeight.w600),
    );
  }
}
