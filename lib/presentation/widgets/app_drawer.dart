// lib/presentation/widgets/app_drawer.dart
// ignore_for_file: deprecated_member_use

import 'dart:math'; // min 함수 사용을 위해 필요
import 'package:flutter/material.dart';
import '../../calculator_screen.dart'; // 루프 계산기
import '../../settings_screen.dart'; // 스테이지 설정
import '../../accessory_screen.dart';
import '../../app_settings_screen.dart'; // 앱 설정 화면 import
import '../../gold_calculator_screen.dart'; // 골드 계산기 화면 import

// AppScreen enum (변경 없음)
enum AppScreen { home, calculator, goldCalculator, accessory, encyclopedia, settings, appSettings }

class AppDrawer extends StatelessWidget {
  final AppScreen currentScreen;
  const AppDrawer({super.key, required this.currentScreen});

  Widget _buildDrawerListTile(
    BuildContext context, {
    required IconData icon,
    required String text,
    required bool selected,
    required VoidCallback onTap,
    required bool showDrawerText,
    required ThemeData theme,
  }) {
    final TextStyle selectedTextStyle = TextStyle(
        color: theme.colorScheme.secondary,
        fontWeight: FontWeight.bold,
        fontSize: theme.textTheme.bodyLarge?.fontSize);
    final Color selectedIconColor = theme.colorScheme.secondary;

    final TextStyle defaultTextStyle = TextStyle(
        // ignore: duplicate_ignore
        // ignore: deprecated_member_use
        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
        fontSize: theme.textTheme.bodyLarge?.fontSize);
    // ignore: duplicate_ignore
    // ignore: deprecated_member_use
    final Color defaultIconColor = theme.iconTheme.color ?? theme.colorScheme.onSurface.withOpacity(0.7);

    Widget titleWidget = Text(
        text,
        style: selected ? selectedTextStyle : defaultTextStyle,
    );

    if (showDrawerText) {
      titleWidget = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: titleWidget,
      );
    } else {
      titleWidget = const SizedBox.shrink();
    }
    
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: selected ? selectedIconColor : defaultIconColor),
        title: showDrawerText ? titleWidget : null,
        selected: selected,
        onTap: onTap,
        // ignore: duplicate_ignore
        // ignore: deprecated_member_use
        selectedTileColor: theme.colorScheme.secondary.withOpacity(0.15),
        hoverColor: theme.colorScheme.onSurface.withOpacity(0.05),
        splashColor: theme.colorScheme.secondary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        horizontalTitleGap: 12.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // --- Drawer 너비 계산 로직 수정 ---
    const double preferredPercentage = 0.45; // 화면 너비의 45%를 목표로 함
    const double minAbsoluteWidth = 240.0;   // Drawer의 최소 절대 너비
    const double maxAbsoluteWidth = 304.0;   // Drawer의 최대 절대 너비 (Material Design 가이드라인 참고)
    
    double calculatedWidth = screenWidth * preferredPercentage; // 목표 너비 계산
    
    // 1. 절대 최소/최대 너비 적용
    calculatedWidth = calculatedWidth.clamp(minAbsoluteWidth, maxAbsoluteWidth);
    
    // 2. 화면 너비의 절반을 넘지 않도록 최종 제한
    final double capAtHalfScreen = screenWidth * 0.5;
    final double drawerWidth = min(calculatedWidth, capAtHalfScreen);
    // --- Drawer 너비 계산 로직 수정 끝 ---
        
    const double textVisibilityThreshold = 120.0; 
    final bool showDrawerText = drawerWidth > textVisibilityThreshold;
    
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final EdgeInsets systemPadding = MediaQuery.of(context).padding;

    return Container(
      width: drawerWidth,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow, 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10.0,
            offset: const Offset(2.0, 0),
          ),
        ],
      ),
      child: Drawer(
        elevation: 0, 
        backgroundColor: Colors.transparent,
        child: Column(
          children: <Widget>[
            Container(
              height: 120.0 + systemPadding.top,
              width: double.infinity,
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 20.0,
                top: systemPadding.top + 20.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withOpacity(0.8),
                    colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDrawerText)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'GOH Calculator',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: false,
                      ),
                    ),
                  if (showDrawerText) const SizedBox(height: 4),
                  if (showDrawerText)
                    Text(
                      '메뉴',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                      softWrap: false,
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                children: [
                  _buildDrawerListTile(context, icon: Icons.home_rounded, text: '홈', selected: currentScreen == AppScreen.home, onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.home) { Navigator.of(context).popUntil((route) => route.isFirst); } }, showDrawerText: showDrawerText, theme: theme),
                  _buildDrawerListTile(context, icon: Icons.calculate_rounded, text: '루프 계산기', selected: currentScreen == AppScreen.calculator, onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.calculator) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CalculatorScreen())); } }, showDrawerText: showDrawerText, theme: theme),
                  _buildDrawerListTile(context, icon: Icons.monetization_on_rounded, text: '골드 효율 계산기', selected: currentScreen == AppScreen.goldCalculator, onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.goldCalculator) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GoldCalculatorScreen())); } }, showDrawerText: showDrawerText, theme: theme),
                  _buildDrawerListTile(context, icon: Icons.diamond_rounded, text: '악세사리', selected: currentScreen == AppScreen.accessory, onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.accessory) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccessoryScreen())); } }, showDrawerText: showDrawerText, theme: theme),
                  _buildDrawerListTile(context, icon: Icons.tune_rounded, text: '스테이지 설정', selected: currentScreen == AppScreen.settings, onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.settings) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsScreen())); } }, showDrawerText: showDrawerText, theme: theme),
                  _buildDrawerListTile(context, icon: Icons.menu_book_rounded, text: '백과사전 (미구현)', selected: currentScreen == AppScreen.encyclopedia, onTap: () { Navigator.of(context).pop(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('백과사전 기능은 아직 준비 중입니다.'))); }, showDrawerText: showDrawerText, theme: theme),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                top: 8.0,
                bottom: systemPadding.bottom > 0 ? systemPadding.bottom + 4.0 : 12.0,
              ),
              child: _buildDrawerListTile(context, icon: Icons.settings_rounded, text: '앱 설정', selected: currentScreen == AppScreen.appSettings, onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.appSettings) { Navigator.push(context, MaterialPageRoute(builder: (context) => const AppSettingsScreen())); } }, showDrawerText: showDrawerText, theme: theme),
            ),
          ],
        ),
      ),
    );
  }
}