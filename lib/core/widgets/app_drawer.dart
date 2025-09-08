// lib/presentation/widgets/app_drawer.dart
// ignore_for_file: deprecated_member_use

import 'dart:math'; // min 함수 사용을 위해 필요
import 'package:flutter/material.dart';
import '../../presentation/calculator/calculator_screen.dart'; // 루프 계산기 import 추가
import '../../presentation/accessory/accessory_screen.dart';
import '../../presentation/box_calculator/box_calculator_screen.dart';
import '../services/event_manager.dart';
import '../../presentation/app_settings/app_settings_screen.dart'; // 앱 설정 화면 import
import '../../presentation/journal/journal_screen.dart'; // 일지 화면 import
import '../../presentation/simulator/accessory_enhancement_screen.dart'; // Corrected path
import '../constants/box_constants.dart'; // AppScreen enum을 box_constants.dart에서 가져옵니다.
import '../../presentation/simulator/accessory_option_change_screen.dart'; // 악세사리 옵션 변경 시뮬레이터 import
import '../../presentation/gold_calculator/gold_calculator_screen.dart'; // 골드 계산기 화면 import
import '../../presentation/damage_calculator/damage_calculator_screen.dart'; // 데미지 계산기 import

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
    required ThemeData theme, // Add theme parameter
    required TextStyle listItemTextStyle,
    required TextStyle selectedListItemTextStyle,
    required Color defaultIconColor,
    required Color selectedIconColor,
  }) {
    Widget titleWidget = Text(
        text,
        style: selected ? selectedListItemTextStyle : listItemTextStyle,
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

    final double baseBodyMediumFontSize = theme.textTheme.bodyMedium?.fontSize ?? 14.0;
    final double mainDrawerItemFontSize = baseBodyMediumFontSize * 0.9; // 10% smaller than bodyMedium
    final double subDrawerItemFontSize = baseBodyMediumFontSize * 0.8; // 20% smaller than bodyMedium

    // Main drawer item styles
    final TextStyle mainDrawerItemTextStyle = TextStyle(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
        fontSize: mainDrawerItemFontSize);
    final TextStyle selectedMainDrawerItemTextStyle = TextStyle(
        color: theme.colorScheme.secondary,
        fontWeight: FontWeight.bold,
        fontSize: mainDrawerItemFontSize);
    final Color defaultDrawerIconColor = theme.iconTheme.color ?? theme.colorScheme.onSurface.withOpacity(0.7); // This variable is used.
    final Color selectedDrawerIconColor = theme.colorScheme.secondary;
    final TextStyle subDrawerItemTextStyle = TextStyle(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
        fontSize: subDrawerItemFontSize);

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
                  _buildDrawerListTile(
                    context,
                    icon: Icons.home_rounded,
                    text: '홈',
                    selected: currentScreen == AppScreen.home,
                    onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.home) { Navigator.of(context).popUntil((route) => route.isFirst); } },
                    showDrawerText: showDrawerText,
                    theme: theme, // Pass theme
                    listItemTextStyle: mainDrawerItemTextStyle,
                    selectedListItemTextStyle: selectedMainDrawerItemTextStyle,
                    defaultIconColor: defaultDrawerIconColor,
                    selectedIconColor: selectedDrawerIconColor,
                  ),
                  _buildDrawerListTile(
                    context,
                    icon: Icons.calculate_rounded,
                    text: '루프 계산기',
                    selected: currentScreen == AppScreen.calculator,
                    onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.calculator) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CalculatorScreen())); } },
                    showDrawerText: showDrawerText,
                    theme: theme, // Pass theme
                    listItemTextStyle: mainDrawerItemTextStyle,
                    selectedListItemTextStyle: selectedMainDrawerItemTextStyle,
                    defaultIconColor: defaultDrawerIconColor,
                    selectedIconColor: selectedDrawerIconColor,
                  ),
                  _buildDrawerListTile(
                    context,
                    icon: Icons.monetization_on_rounded,
                    text: '골드 효율 계산기',
                    selected: currentScreen == AppScreen.goldCalculator,
                    onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.goldCalculator) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GoldCalculatorScreen())); } },
                    showDrawerText: showDrawerText,
                    theme: theme, // Pass theme
                    listItemTextStyle: mainDrawerItemTextStyle,
                    selectedListItemTextStyle: selectedMainDrawerItemTextStyle,
                    defaultIconColor: defaultDrawerIconColor,
                    selectedIconColor: selectedDrawerIconColor,
                  ),
                  _buildDrawerListTile(
                    context,
                    icon: Icons.edit_note_rounded,
                    text: '일지',
                    selected: currentScreen == AppScreen.journal,
                    onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.journal) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const JournalScreen())); } },
                    showDrawerText: showDrawerText,
                    theme: theme, // Pass theme
                    listItemTextStyle: mainDrawerItemTextStyle,
                    selectedListItemTextStyle: selectedMainDrawerItemTextStyle,
                    defaultIconColor: defaultDrawerIconColor,
                    selectedIconColor: selectedDrawerIconColor,
                  ),
                  if (EventManager.isEventPeriodActive()) // 이벤트 기간에만 표시
                    _buildDrawerListTile(
                      context,
                      icon: Icons.inventory_2_outlined, // 상자 아이콘
                      text: '상자 기대값 계산기',
                      selected: currentScreen == AppScreen.boxCalculator,
                      onTap: () {
                        Navigator.of(context).pop(); // Close drawer
                        if (currentScreen != AppScreen.boxCalculator) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BoxCalculatorScreen()));
                        }
                      },
                      showDrawerText: showDrawerText, theme: theme, listItemTextStyle: mainDrawerItemTextStyle,
                      selectedListItemTextStyle: selectedMainDrawerItemTextStyle, defaultIconColor: defaultDrawerIconColor, selectedIconColor: selectedDrawerIconColor,
                  ),
                  Theme( // ExpansionTile의 기본 구분선 색상을 투명하게 만듦
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: const PageStorageKey<String>('simulator_expansion_tile'), // 상태 유지를 위한 키
                      leading: Icon(Icons.precision_manufacturing_rounded, color: defaultDrawerIconColor),
                      title: showDrawerText ? Text('시뮬레이터', style: mainDrawerItemTextStyle) : const SizedBox.shrink(),
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0), // ListTile과 유사한 패딩
                      iconColor: theme.colorScheme.secondary, // 확장 아이콘 색상 (열렸을 때)
                      collapsedIconColor: defaultDrawerIconColor, // 확장 아이콘 색상 (닫혔을 때)
                      childrenPadding: EdgeInsets.only(left: showDrawerText ? 16.0 : 0), // 하위 항목 들여쓰기
                      children: <Widget>[
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.only(left: showDrawerText ? (16.0 + 12.0 + 16.0) : 16.0, right: 16.0), // 아이콘 공간(16+12) + 텍스트 시작 패딩(16)
                          title: Text('악세사리 강화', style: subDrawerItemTextStyle),
                          onTap: () {
                            Navigator.of(context).pop(); // Close drawer
                            // Navigate to the new AccessoryEnhancementScreen
                            // Ensure currentScreen != AppScreen.simulator or similar check if replacing
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AccessoryEnhancementScreen()));
                          },
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.only(left: showDrawerText ? (16.0 + 12.0 + 16.0) : 16.0, right: 16.0),
                          title: Text('악세사리 옵션 변경', style: subDrawerItemTextStyle),
                          onTap: () { // Navigate to the new AccessoryOptionChangeScreen
                            Navigator.of(context).pop(); // 서랍 닫기
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AccessoryOptionChangeScreen()));
                          },
                        ),
                      ],
                      // ExpansionTile 자체는 선택된 상태를 가지지 않으므로 selected 관련 스타일 제거
                    ),
                  ),
                  _buildDrawerListTile(
                    context,
                    icon: Icons.diamond_rounded,
                    text: '악세사리 도감',
                    selected: currentScreen == AppScreen.accessory,
                    onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.accessory) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccessoryScreen())); } },
                    showDrawerText: showDrawerText,
                    theme: theme, // Pass theme
                    listItemTextStyle: mainDrawerItemTextStyle,
                    selectedListItemTextStyle: selectedMainDrawerItemTextStyle,
                    defaultIconColor: defaultDrawerIconColor,
                    selectedIconColor: selectedDrawerIconColor,
                  ),
                  _buildDrawerListTile(
                    context,
                    icon: Icons.flash_on_rounded, // 데미지 계산기 아이콘
                    text: '데미지 계산기',
                    selected: currentScreen == AppScreen.damageCalculator,
                    onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.damageCalculator) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DamageCalculatorScreen())); } },
                    showDrawerText: showDrawerText,
                    theme: theme, // Pass theme
                    listItemTextStyle: mainDrawerItemTextStyle,
                    selectedListItemTextStyle: selectedMainDrawerItemTextStyle,
                    defaultIconColor: defaultDrawerIconColor,
                    selectedIconColor: selectedDrawerIconColor,
                  ),
                  _buildDrawerListTile(
                    context,
                    icon: Icons.menu_book_rounded,
                    text: '백과사전 (미구현)',
                    selected: currentScreen == AppScreen.encyclopedia,
                    onTap: () { Navigator.of(context).pop(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('백과사전 기능은 아직 준비 중입니다.'))); },
                    showDrawerText: showDrawerText,
                    theme: theme, // Pass theme
                    listItemTextStyle: mainDrawerItemTextStyle,
                    selectedListItemTextStyle: selectedMainDrawerItemTextStyle,
                    defaultIconColor: defaultDrawerIconColor,
                    selectedIconColor: selectedDrawerIconColor,
                  ),
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
              child: _buildDrawerListTile(
                context,
                icon: Icons.settings_rounded,
                text: '앱 설정',
                selected: currentScreen == AppScreen.appSettings,
                onTap: () { Navigator.of(context).pop(); if (currentScreen != AppScreen.appSettings) { Navigator.push(context, MaterialPageRoute(builder: (context) => const AppSettingsScreen())); } },
                showDrawerText: showDrawerText,
                theme: theme,
                listItemTextStyle: mainDrawerItemTextStyle,
                selectedListItemTextStyle: selectedMainDrawerItemTextStyle,
                defaultIconColor: defaultDrawerIconColor,
                selectedIconColor: selectedDrawerIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}