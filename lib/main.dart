// lib/main.dart
import 'package:flutter/material.dart';
import 'loading_screen.dart';
import 'services/settings_service.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized(); // 필요 시 추가
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // --- 테마 생성 함수 (글꼴 크기 배율 적용) ---
  ThemeData _buildTheme(BuildContext context, Brightness brightness, double fontSizeMultiplier) {
    final bool isDark = brightness == Brightness.dark;

    // 기본 색상 정의
    const Color primaryColorLight = Color(0xFF3F51B5);
    const Color accentColorLight = Color(0xFFFFC107);
    const Color scaffoldBackgroundColorLight = Color(0xFFFAFAFA);
    const Color cardBackgroundColorLight = Colors.white;
    const Color textColorLight = Colors.black87;
    const Color secondaryTextColorLight = Colors.black54;

    const Color primaryColorDark = Color(0xFF303F9F);
    const Color accentColorDark = Color(0xFFFFAB00);
    const Color scaffoldBackgroundColorDark = Color(0xFF121212);
    const Color cardBackgroundColorDark = Color(0xFF1E1E1E);
    const Color textColorDark = Colors.white;
    const Color secondaryTextColorDark = Colors.white70;

    // 밝기 및 색상 설정 (런타임 값인 isDark에 의존하므로 const가 될 수 없음)
    final Color primaryColor = isDark ? primaryColorDark : primaryColorLight;
    final Color accentColor = isDark ? accentColorDark : accentColorLight;
    final Color scaffoldBackgroundColor = isDark ? scaffoldBackgroundColorDark : scaffoldBackgroundColorLight;
    final Color cardBackgroundColor = isDark ? cardBackgroundColorDark : cardBackgroundColorLight;
    final Color textColor = isDark ? textColorDark : textColorLight;
    final Color secondaryTextColor = isDark ? secondaryTextColorDark : secondaryTextColorLight;
    final Color onPrimaryColor = isDark ? Colors.white : Colors.white;
    final Color onSecondaryColor = isDark ? Colors.black : Colors.black;
    final Color errorColor = isDark ? Colors.redAccent : Colors.red;
    const Color onErrorColor = Colors.white;
    final Color onSurfaceColor = isDark ? Colors.white : textColorLight;
    final Color inputFillColor = isDark ? cardBackgroundColorDark : Colors.grey[100]!;
    final Color dividerColor = isDark ? Colors.grey[700]! : Colors.grey[400]!;
    // line 43 부근의 hintColor는 isDark에 의존하므로 const가 될 수 없습니다.
    final Color hintColor = isDark ? secondaryTextColorDark.withAlpha((255 * 0.7).round()) : secondaryTextColorLight.withAlpha(150);


    // 기본 TextTheme 가져오기 (런타임 값인 isDark 및 ThemeData 메서드 호출에 의존하므로 const가 될 수 없음)
    final TextTheme originalTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    // 글꼴 크기 배율 적용하여 TextTheme 생성 (originalTextTheme 및 fontSizeMultiplier에 의존하므로 const가 될 수 없음)
    final TextTheme customTextTheme = originalTextTheme.copyWith(
      bodyLarge: originalTextTheme.bodyLarge?.copyWith(color: textColor, fontSize: (originalTextTheme.bodyLarge?.fontSize ?? 14.0) * fontSizeMultiplier),
      bodyMedium: originalTextTheme.bodyMedium?.copyWith(color: textColor, fontSize: (originalTextTheme.bodyMedium?.fontSize ?? 14.0) * fontSizeMultiplier),
      bodySmall: originalTextTheme.bodySmall?.copyWith(color: secondaryTextColor, fontSize: (originalTextTheme.bodySmall?.fontSize ?? 12.0) * fontSizeMultiplier),
      displayLarge: originalTextTheme.displayLarge?.copyWith(color: textColor, fontSize: (originalTextTheme.displayLarge?.fontSize ?? 96.0) * fontSizeMultiplier),
      displayMedium: originalTextTheme.displayMedium?.copyWith(color: textColor, fontSize: (originalTextTheme.displayMedium?.fontSize ?? 60.0) * fontSizeMultiplier),
      displaySmall: originalTextTheme.displaySmall?.copyWith(color: textColor, fontSize: (originalTextTheme.displaySmall?.fontSize ?? 48.0) * fontSizeMultiplier),
      headlineLarge: originalTextTheme.headlineLarge?.copyWith(color: textColor, fontSize: (originalTextTheme.headlineLarge?.fontSize ?? 34.0) * fontSizeMultiplier),
      headlineMedium: originalTextTheme.headlineMedium?.copyWith(color: textColor, fontSize: (originalTextTheme.headlineMedium?.fontSize ?? 24.0) * fontSizeMultiplier),
      headlineSmall: originalTextTheme.headlineSmall?.copyWith(color: textColor, fontSize: (originalTextTheme.headlineSmall?.fontSize ?? 20.0) * fontSizeMultiplier), // AppBar title 기본
      titleLarge: originalTextTheme.titleLarge?.copyWith(color: textColor, fontSize: (originalTextTheme.titleLarge?.fontSize ?? 20.0) * fontSizeMultiplier), // Dialog title, List Title 등
      titleMedium: originalTextTheme.titleMedium?.copyWith(color: textColor, fontSize: (originalTextTheme.titleMedium?.fontSize ?? 16.0) * fontSizeMultiplier), // ListTile title, Input label 등
      titleSmall: originalTextTheme.titleSmall?.copyWith(color: secondaryTextColor, fontSize: (originalTextTheme.titleSmall?.fontSize ?? 14.0) * fontSizeMultiplier),
      labelLarge: originalTextTheme.labelLarge?.copyWith(color: onSecondaryColor, fontSize: (originalTextTheme.labelLarge?.fontSize ?? 14.0) * fontSizeMultiplier), // Button text
      labelMedium: originalTextTheme.labelMedium?.copyWith(color: textColor, fontSize: (originalTextTheme.labelMedium?.fontSize ?? 12.0) * fontSizeMultiplier),
      labelSmall: originalTextTheme.labelSmall?.copyWith(color: secondaryTextColor, fontSize: (originalTextTheme.labelSmall?.fontSize ?? 10.0) * fontSizeMultiplier),
    ).apply(
      // fontFamily: 'NanumGothic', // 필요시 여기에 전역 폰트 적용
    );

    // 최종 테마 데이터 생성 (대부분의 속성이 런타임에 결정되므로 const가 될 수 없음)
    return ThemeData(
      fontFamily: 'NanumGothic', // 기본 폰트 패밀리
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: onPrimaryColor,
        secondary: accentColor,
        onSecondary: onSecondaryColor,
        error: errorColor,
        onError: onErrorColor,
        surface: cardBackgroundColor, // Card 배경 등에 사용
        onSurface: onSurfaceColor,
        surfaceContainerHighest: cardBackgroundColor, // Dialog 배경 등에 사용 (Material 3)
        // Material 3에서 surfaceTintColor의 기본값으로 사용될 수 있는 색상 (보통 primary)
        surfaceTint: primaryColor, 
      ),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      cardColor: cardBackgroundColor,
      textTheme: customTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 4.0,
        titleTextStyle: customTextTheme.headlineSmall?.copyWith(color: onPrimaryColor),
        // 표면 색조 효과를 없애려면 surfaceTintColor를 Colors.transparent로 설정
        surfaceTintColor: Colors.transparent, // <--- 이 부분 추가 또는 수정
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: onSecondaryColor,
          textStyle: customTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: accentColor, width: 2.0),
        ),
        labelStyle: customTextTheme.titleMedium?.copyWith(color: secondaryTextColor),
        hintStyle: customTextTheme.bodyMedium?.copyWith(color: hintColor),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
           filled: true,
           fillColor: inputFillColor,
           border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(8.0),
             borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
           ),
           enabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(8.0),
             borderSide: BorderSide(color: dividerColor),
           ),
        ),
      ),
       dialogTheme: DialogTheme(
        backgroundColor: cardBackgroundColor,
        titleTextStyle: customTextTheme.titleLarge,
        contentTextStyle: customTextTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      sliderTheme: SliderThemeData( // 슬라이더 테마 설정
        activeTrackColor: accentColor,
        inactiveTrackColor: accentColor.withAlpha((0.3 * 255).round()),
        thumbColor: accentColor,
        overlayColor: accentColor.withAlpha((0.2 * 255).round()),
        valueIndicatorColor: primaryColor,
        valueIndicatorTextStyle: customTextTheme.labelSmall?.copyWith(color: onPrimaryColor),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SettingsService.instance.themeModeNotifier,
      builder: (_, ThemeMode currentThemeMode, __) {
        return ValueListenableBuilder<double>(
          valueListenable: SettingsService.instance.fontSizeNotifier,
          builder: (_, double currentFontSizeMultiplier, __) {
            return MaterialApp(
              title: 'GOH Calculator',
              theme: _buildTheme(context, Brightness.light, currentFontSizeMultiplier),
              darkTheme: _buildTheme(context, Brightness.dark, currentFontSizeMultiplier),
              themeMode: currentThemeMode,
              home: const LoadingScreen(),
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}