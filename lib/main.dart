// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Localizations delegate import
import 'package:intl/date_symbol_data_local.dart'; // For initializeDateFormatting
import 'presentation/loading/loading_screen.dart';
import 'core/services/settings_service.dart';

void main() async { // async로 변경
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 바인딩 초기화
  await initializeDateFormatting(); // 날짜 포맷 초기화 (모든 로케일 또는 특정 로케일)
                                    // 예: await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // --- 테마 생성 함수 (글꼴 크기 배율 적용) ---
  ThemeData _buildTheme(BuildContext context, Brightness brightness, double fontSizeMultiplier) {
    final bool isDark = brightness == Brightness.dark;

    // --- 화면 크기 기반 동적 폰트 스케일 계산 ---
    final double screenWidth = MediaQuery.of(context).size.width;
    const double referenceScreenWidth = 360.0; // 기준 화면 너비 (dp/pt)

    // 화면 반응형 스케일의 기본 기준 (예: Material 기본값의 8/9 수준을 목표)
    const double baseScaleFactorForScreenResponsiveness = 8.0 / 9.0;
    const double desiredBodyMediumSizeAtReference = 14.0 * baseScaleFactorForScreenResponsiveness;

    // 현재 화면 너비와 기준 너비의 비율
    final double screenWidthRatio = screenWidth / referenceScreenWidth;
    // 화면 너비에 따라 계산된 스케일 (아직 clamp 및 최종 조정 전)
    final double calculatedScreenResponsiveScale = (desiredBodyMediumSizeAtReference / 14.0) * screenWidthRatio;

    // 화면 크기에 따른 스케일 변동폭 제한 (예: Material 기본값의 0.8배 ~ 1.0배 사이로)
    final double clampedScreenResponsiveScale = calculatedScreenResponsiveScale.clamp(0.8, 1.0);

    // 요청사항: 현재 앱 설정의 130%가 새로운 기본 100%가 되도록 함.
    // 따라서, 화면 반응형으로 계산된 스케일에 1.3을 곱하여 새로운 기본 스케일로 설정.
    const double newBaseMultiplier = 1.3;
    final double deviceResponsiveFontScale = clampedScreenResponsiveScale * newBaseMultiplier;

    // 기본 색상 정의 (요청된 색상으로 변경)
// 파란색
    const Color accentColorLight = Colors.orange; // 주황색
    const Color scaffoldBackgroundColorLight = Colors.white; // 흰색
    const Color cardBackgroundColorLight = Colors.white; // 흰색
    const Color textColorLight = Colors.black87; // 어두운 회색 (텍스트)
    const Color secondaryTextColorLight = Colors.black54; // 중간 회색 (보조 텍스트)

    // 토글 색상 정의 (초록색 계열)
    const Color toggleGreenLight = Color(0xFF388E3C); // Material Design Green 700

    // 다크 모드 색상 정의 (요청된 색상으로 변경 및 순서 조정)
    // Material Design 다크 테마 권장 색상 사용
// 어두운 파랑 (Blue 800)
    const Color accentColorDark = Color(0xFFEF6C00); // 어두운 주황 (Orange 800)
    const Color scaffoldBackgroundColorDark = Color(0xFF121212); // 매우 어두운 회색 (배경)
    const Color cardBackgroundColorDark = Color(0xFF1E1E1E); // 어두운 회색 (카드/표면)
    const Color textColorDark = Colors.white; // 흰색 (텍스트)
    const Color secondaryTextColorDark = Colors.white70;

    // 다크 모드 토글 색상 정의 (밝은 초록색 계열)
    const Color toggleGreenDark = Color(0xFF00E676); // Material Design Green Accent 400

    // 밝기 및 색상 설정 (런타임 값인 isDark에 의존하므로 const가 될 수 없음)
    final Color primaryColor = isDark ? const Color.fromARGB(255, 30, 3, 124) : const Color.fromARGB(255, 0, 121, 202);
    final Color accentColor = isDark ? accentColorDark : accentColorLight;
    final Color scaffoldBackgroundColor = isDark ? scaffoldBackgroundColorDark : scaffoldBackgroundColorLight;
    final Color cardBackgroundColor = isDark ? cardBackgroundColorDark : cardBackgroundColorLight;
    final Color textColor = isDark ? textColorDark : textColorLight;
    final Color secondaryTextColor = isDark ? secondaryTextColorDark : secondaryTextColorLight;
    final Color onPrimaryColor = isDark ? Colors.white : Colors.white; // 기본 색상 위에 흰색 텍스트/아이콘
    final Color onSecondaryColor = isDark ? Colors.white : Colors.black87; // 강조 색상 위에 텍스트/아이콘 (밝은 모드는 어둡게, 다크 모드는 밝게)
    final Color errorColor = isDark ? const Color(0xFFC62828) : Colors.red; // 오류 색상 (다크 모드는 Red 800)
    const Color onErrorColor = Colors.white; // 오류 색상 위에 흰색 텍스트/아이콘
    final Color onSurfaceColor = isDark ? Colors.white : const Color(0xFF06202B); // 밝은 배경 색상 위에 어두운 텍스트/아이콘
    final Color inputFillColor = isDark ? cardBackgroundColorDark : Colors.grey[100]!; // cardBackgroundColorDark는 라인 34의 것을 사용
    final Color dividerColor = isDark ? Colors.grey[700]! : const Color.fromARGB(255, 223, 223, 223);
    // line 43 부근의 hintColor는 isDark에 의존하므로 const가 될 수 없습니다.
    final Color hintColor = isDark ? secondaryTextColorDark.withAlpha((255 * 0.7).round()) : secondaryTextColorLight.withAlpha(150);


    // 기본 TextTheme 가져오기 (런타임 값인 isDark 및 ThemeData 메서드 호출에 의존하므로 const가 될 수 없음)
    final TextTheme originalTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    // 글꼴 크기 배율 적용하여 TextTheme 생성 (originalTextTheme 및 fontSizeMultiplier에 의존하므로 const가 될 수 없음)
    final TextTheme customTextTheme = originalTextTheme.copyWith(
      bodyLarge: originalTextTheme.bodyLarge?.copyWith(color: textColor, fontSize: (originalTextTheme.bodyLarge?.fontSize ?? 14.0) * deviceResponsiveFontScale * fontSizeMultiplier),
      bodyMedium: originalTextTheme.bodyMedium?.copyWith(color: textColor, fontSize: (originalTextTheme.bodyMedium?.fontSize ?? 14.0) * deviceResponsiveFontScale * fontSizeMultiplier),
      bodySmall: originalTextTheme.bodySmall?.copyWith(color: secondaryTextColor, fontSize: (originalTextTheme.bodySmall?.fontSize ?? 12.0) * deviceResponsiveFontScale * fontSizeMultiplier),
      displayLarge: originalTextTheme.displayLarge?.copyWith(color: textColor, fontSize: (originalTextTheme.displayLarge?.fontSize ?? 96.0) * deviceResponsiveFontScale * fontSizeMultiplier),
      displayMedium: originalTextTheme.displayMedium?.copyWith(color: textColor, fontSize: (originalTextTheme.displayMedium?.fontSize ?? 60.0) * deviceResponsiveFontScale * fontSizeMultiplier),
      displaySmall: originalTextTheme.displaySmall?.copyWith(color: textColor, fontSize: (originalTextTheme.displaySmall?.fontSize ?? 48.0) * deviceResponsiveFontScale * fontSizeMultiplier),
      headlineLarge: originalTextTheme.headlineLarge?.copyWith(color: textColor, fontSize: (originalTextTheme.headlineLarge?.fontSize ?? 34.0) * deviceResponsiveFontScale * fontSizeMultiplier),
      headlineMedium: originalTextTheme.headlineMedium?.copyWith(color: textColor, fontSize: (originalTextTheme.headlineMedium?.fontSize ?? 24.0) * deviceResponsiveFontScale * fontSizeMultiplier),
      headlineSmall: originalTextTheme.headlineSmall?.copyWith(color: textColor, fontSize: (originalTextTheme.headlineSmall?.fontSize ?? 20.0) * deviceResponsiveFontScale * fontSizeMultiplier), // AppBar title 기본
      titleLarge: originalTextTheme.titleLarge?.copyWith(color: textColor, fontSize: (originalTextTheme.titleLarge?.fontSize ?? 20.0) * deviceResponsiveFontScale * fontSizeMultiplier), // Dialog title, List Title 등
      titleMedium: originalTextTheme.titleMedium?.copyWith(color: textColor, fontSize: (originalTextTheme.titleMedium?.fontSize ?? 16.0) * deviceResponsiveFontScale * fontSizeMultiplier), // ListTile title, Input label 등
      titleSmall: originalTextTheme.titleSmall?.copyWith(color: secondaryTextColor, fontSize: (originalTextTheme.titleSmall?.fontSize ?? 14.0) * deviceResponsiveFontScale * fontSizeMultiplier),
      labelLarge: originalTextTheme.labelLarge?.copyWith(color: onSecondaryColor, fontSize: (originalTextTheme.labelLarge?.fontSize ?? 14.0) * deviceResponsiveFontScale * fontSizeMultiplier), // Button text
      labelMedium: originalTextTheme.labelMedium?.copyWith(color: textColor, fontSize: (originalTextTheme.labelMedium?.fontSize ?? 12.0) * deviceResponsiveFontScale * fontSizeMultiplier),
      labelSmall: originalTextTheme.labelSmall?.copyWith(color: secondaryTextColor, fontSize: (originalTextTheme.labelSmall?.fontSize ?? 10.0) * deviceResponsiveFontScale * fontSizeMultiplier),
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
        surface: cardBackgroundColor, // Card 배경 등에 사용 (isDark에 따라 light/dark 배경 사용)
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
        // localizationsDelegates 및 supportedLocales는 MaterialApp 최상단에 이미 설정되어 있습니다.
        // MaterialApp(
        //   localizationsDelegates: GlobalMaterialLocalizations.delegates,
        //   supportedLocales: [
        //      const Locale('ko', 'KR'),
        //   ],
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
        backgroundColor: isDark ? cardBackgroundColorDark : cardBackgroundColorLight, // 다크 모드에서 검정 배경 사용
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
      switchTheme: SwitchThemeData( // Switch 위젯 테마 설정 추가
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {            
            if (!isDark) { // 일반 모드              
              return Colors.white; // ON/OFF 상태 모두 흰색
            } else { // 다크 모드              
              // thumbColor는 이제 색상만 담당하므로 null 반환
              return null;
            }
          },
        ),
        // thumbIcon을 사용하여 크기 조절 및 색상 지정
        thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
          (Set<WidgetState> states) {
            if (!isDark) {
              return Icon(
                Icons.circle,
                size: 24.0, // 흰색 원 크기 조절 (원하는 크기로 변경)
                color: Colors.white,
              );
            } else {
              // 다크 모드에서는 ON/OFF 상태와 관계없이 흰색 원형 아이콘 사용
              return const Icon(
                Icons.circle, // 원형 아이콘 사용
                size: 24.0, // 일반 모드와 동일한 크기 사용
                color: Colors.white, // 흰색으로 설정
              );
            }
// 다크 모드 OFF 상태 썸 기본값
          }
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (!isDark) { // 일반 모드
              if (states.contains(WidgetState.selected)) { // ON 상태
                return toggleGreenLight; // 초록색 배경
              } else { // OFF 상태
                return Colors.grey[400]; // 회색 배경
              }
            } else { // 다크 모드
              if (states.contains(WidgetState.selected)) { // ON 상태
                // ignore: deprecated_member_use
                return toggleGreenDark.withOpacity(0.5); // 다크 모드 ON 상태 트랙 색상 (기존 로직 유지 또는 필요시 변경)
              }
              return null; // 다크 모드 OFF 상태 트랙 기본값
            }
          },
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>( // Material 3 스위치 외곽선 색상
          (Set<WidgetState> states) {
            if (!isDark) { // 일반 모드
              if (states.contains(WidgetState.selected)) { // ON 상태
                return Colors.transparent; // 외곽선 없음 또는 toggleGreenLight와 동일하게 설정 가능
              } else { // OFF 상태
                return Colors.grey[500]; // 트랙보다 약간 어두운 회색 외곽선
              }
            }
            return null; // 다크 모드 기본값
          }
        ),
      ),
      // Drawer 배경색 설정 (Material 3)
      drawerTheme: DrawerThemeData(
        backgroundColor: isDark ? cardBackgroundColorDark : Theme.of(context).colorScheme.surfaceContainerLow, // 다크 모드에서 cardBackgroundColorDark 사용
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
          theme: _buildTheme(context, Brightness.light, currentFontSizeMultiplier), // Or _buildTheme(Brightness.light, currentFontSizeMultiplier)
          darkTheme: _buildTheme(context, Brightness.dark, currentFontSizeMultiplier), // Or _buildTheme(Brightness.dark, currentFontSizeMultiplier)
              themeMode: currentThemeMode,
              home: const LoadingScreen(),
              localizationsDelegates: const [ // MaterialApp 레벨에 설정
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [ // MaterialApp 레벨에 설정
                Locale('ko', 'KR'),
                Locale('en', 'US'), // 기본 로케일로 영어도 포함하는 것이 좋습니다.
              ],
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}