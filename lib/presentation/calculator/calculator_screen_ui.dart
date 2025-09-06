// lib/presentation/calculator/calculator_screen_ui.dart

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../core/constants/leader_constants.dart';
import '../../core/constants/monster_constants.dart';
import 'calculator_screen.dart'; // CalculatorSortOption Enum 사용
import '../../core/constants/box_constants.dart'; // AppScreen enum을 위해 추가
import '../../core/widgets/app_drawer.dart';

// StageDisplayData 클래스 정의 (변경 없음)
class StageDisplayData {
  final String stageName;
  final String totalTimeStr;
  final String soulStonesStr;        // 포맷팅된 루프 영혼석 문자열
  final String loopGoldStr;
  final String soulStonesPerMinStr; // 포맷팅된 분당 영혼석 문자열
  final String goldPerMinStr;
  final String location;
  final String configuredClearTime;
  final String configuredJjolCount;
  final String baseExpStr;
  final String baseGoldStr;
  final String finalExpPerLoopStr;
  final String finalGoldPerSingleLoopStr;
  final String expPerMinStr;
  final String runsToMaxStr;
  final String totalLoopsStr;
  final String totalStaminaStr;
  final bool settingsIncomplete;      // 스테이지 설정 미완료 여부 플래그 추가
  final double? soulStonesValue;       // 계산된 원본 루프 영혼석 값 (스타일링 위해)
  final double? soulStonesPerMinValue; // 계산된 원본 분당 영혼석 값 (스타일링 위해)

  const StageDisplayData({
    required this.stageName,
    required this.totalTimeStr,
    required this.soulStonesStr,
    required this.loopGoldStr,
    required this.soulStonesPerMinStr,
    required this.goldPerMinStr,
    required this.location,
    required this.configuredClearTime,
    required this.configuredJjolCount,
    required this.baseExpStr,
    required this.baseGoldStr,
    required this.finalExpPerLoopStr,
    required this.finalGoldPerSingleLoopStr,
    required this.expPerMinStr,
    required this.runsToMaxStr,
    required this.totalLoopsStr,
    required this.totalStaminaStr,
    required this.settingsIncomplete,     // 생성자 파라미터 추가
    required this.soulStonesValue,        // 생성자 파라미터 추가
    required this.soulStonesPerMinValue,  // 생성자 파라미터 추가
  });
}

// 버튼 스타일 적용된 스위치 토글 위젯 수정
class _NewSwitchStyleToggleWidget extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final IconData icon;

  const _NewSwitchStyleToggleWidget({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use a theme style that will be scaled globally by main.dart
    final textStyle = TextStyle(
      fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12.0) * 0.85,
      fontWeight: value ? FontWeight.bold : FontWeight.normal,
      color: theme.textTheme.bodySmall?.color,
    );

    final iconWidget = Icon(icon, size: 18 * 0.85, color: value ? theme.colorScheme.secondary : theme.textTheme.bodySmall?.color);
    final switchWidget = Transform.scale(
      scale: 0.75 * 0.85,
      alignment: Alignment.centerRight, // 스위치 자체의 스케일링 기준
      child: Switch(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    // 레이블 텍스트의 너비 측정
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    final textWidth = textPainter.width;

    // 아이콘과 스위치의 대략적인 너비 및 간격
    const double iconWidth = 18.0 * 0.85;
    const double switchEffectiveWidth = 40.0 * 0.85; // 스케일링된 스위치의 시각적 너비 추정치
    const double spacingBetweenIconText = 3.0;
    const double spacingBetweenTextSwitch = 2.0;

    // 한 줄 레이아웃에 필요한 총 너비 계산
    final double requiredRowWidth = iconWidth + spacingBetweenIconText + textWidth + spacingBetweenTextSwitch + switchEffectiveWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // 사용 가능한 너비보다 필요한 너비가 크면 레이아웃 변경
        final bool shouldChangeLayout = requiredRowWidth > availableWidth;

        if (shouldChangeLayout) {
          // 세로 레이아웃: 아이콘-텍스트 한 줄, 스위치는 아래 줄 중앙
          return Column(
            mainAxisAlignment: MainAxisAlignment.center, // Column 내용을 세로 중앙 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // Column 내용을 가로 중앙 정렬
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 아이콘과 텍스트를 가로 중앙 정렬
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  SizedBox(width: spacingBetweenIconText),
                  // Allow text to wrap in vertical layout
                  Flexible(
                    child: Text(
                      label,
                      style: textStyle,
                      textAlign: TextAlign.center,
                      softWrap: true, // Allow wrapping
                    ),
                  ),
                ],
              ),
              switchWidget,
            ],
          );
        } else {
          // 기존 가로 레이아웃
          // Ensure text doesn't overflow with ellipsis if it can be avoided
          // Using Flexible and potentially FittedBox if scaling is acceptable,
          // or ensuring the text itself is short enough.
          // For this case, if it's too long, the LayoutBuilder already switches to Column.
          // So, ellipsis here is a fallback if the Row is chosen but still too narrow.
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              SizedBox(width: spacingBetweenIconText),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  label,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis, // Fallback if Row is forced and too narrow
                  softWrap: false,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: spacingBetweenTextSwitch),
              switchWidget,
            ],
          );
        }
      },
    );
  }
}


class CalculatorScreenUI extends StatelessWidget {
  // ... (기존 파라미터들은 변경 없음) ...
  final bool expHotTime;
  final bool goldHotTime;
  final bool expBoost;
  final bool goldBoost;
  final bool pass;
  final bool reverseElement;
  final ValueChanged<bool> onExpHotTimeChanged;
  final ValueChanged<bool> onGoldHotTimeChanged;
  final ValueChanged<bool> onExpBoostChanged;
  final ValueChanged<bool> onGoldBoostChanged;
  final ValueChanged<bool> onPassChanged;
  final ValueChanged<bool> onReverseElementChanged;

  final String? selectedLeader;
  final String? selectedMonsterName;
  final String? selectedMonsterGrade;
  final ValueChanged<String?> onLeaderChanged;
  final ValueChanged<String?> onMonsterNameChanged;
  final ValueChanged<String?> onMonsterGradeChanged;

  final String selectedTimeFormat;
  final List<String> timeFormatOptions;
  final ValueChanged<String?> onTimeFormatChanged;
  final List<StageDisplayData> stageResults;
  final bool showSoulStonesPerMinute;
  final bool showGoldPerMinute;
  final VoidCallback onToggleSoulStoneView;
  final VoidCallback onToggleGoldView;

  final VoidCallback onShowInfoAlertPressed;
  final Function(String location) onStageNameTap;
  final Function(StageDisplayData stageData) onInfoButtonTap;

  final VoidCallback onStageSettingsPressed; // 스테이지 설정 버튼 콜백 추가
  final double? maxPositiveSoulStoneValue;

  final CalculatorSortOption selectedSortOption;
  final ValueChanged<CalculatorSortOption?> onSortOptionChanged;

  final bool hideUnconfiguredStages; // 새로운 파라미터
  final ValueChanged<bool> onHideUnconfiguredStagesChanged; // 새로운 파라미터

  const CalculatorScreenUI({
    super.key,
    required this.expHotTime,
    required this.goldHotTime,
    required this.expBoost,
    required this.goldBoost,
    required this.pass,
    required this.reverseElement,
    required this.onExpHotTimeChanged,
    required this.onGoldHotTimeChanged,
    required this.onExpBoostChanged,
    required this.onGoldBoostChanged,
    required this.onPassChanged,
    required this.onReverseElementChanged,
    required this.selectedLeader,
    required this.selectedMonsterName,
    required this.selectedMonsterGrade,
    required this.onLeaderChanged,
    required this.onMonsterNameChanged,
    required this.onMonsterGradeChanged,
    required this.selectedTimeFormat,
    required this.timeFormatOptions,
    required this.onTimeFormatChanged,
    required this.stageResults,
    required this.showSoulStonesPerMinute,
    required this.showGoldPerMinute,
    required this.onToggleSoulStoneView,
    required this.onToggleGoldView,
    required this.onShowInfoAlertPressed,
    required this.onStageNameTap,
    required this.onInfoButtonTap,
    required this.maxPositiveSoulStoneValue,
    required this.onStageSettingsPressed, // 생성자에 추가
    required this.selectedSortOption,
    required this.onSortOptionChanged,
    required this.hideUnconfiguredStages, // 생성자에 추가
    required this.onHideUnconfiguredStagesChanged, // 생성자에 추가
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    final TextStyle? titleStyle = appBarTheme.titleTextStyle;
    final TextStyle columnHeaderStyle = TextStyle(
      fontSize: (theme.textTheme.titleMedium?.fontSize ?? 15.0) * 0.85,
      fontWeight: FontWeight.bold,
      color: theme.textTheme.titleMedium?.color
    );

    // 컬럼 헤더 텍스트 스타일에 fontSize 명시적으로 추가
    final double defaultHeaderFontSize = theme.textTheme.bodyMedium?.fontSize ?? 14.0;
    final headerColumnTextStyle = TextStyle(
        fontSize: defaultHeaderFontSize * 0.9, // 기본값에서 약간 작게 설정하거나 고정값 사용
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface
    );
    final headerColumnClickableTextStyle = TextStyle(
        fontSize: defaultHeaderFontSize * 0.9, // 기본값에서 약간 작게 설정하거나 고정값 사용
        fontWeight: FontWeight.bold,
        color: colorScheme.secondary
    );


    const Map<CalculatorSortOption, String> sortOptionDisplayNames = {
      CalculatorSortOption.stageName: '스테이지명',
      CalculatorSortOption.soulStone: '영혼석',
      CalculatorSortOption.gold: '골드',
    };

    return Scaffold(
      drawer: const AppDrawer(currentScreen: AppScreen.calculator),
      body: SafeArea(
        top: false,
        bottom: true,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: true,
              title: Text(
                '루프 계산기',
                style: titleStyle?.copyWith(
                  fontSize: (titleStyle.fontSize ?? 20) + 2.0,
                ),
              ),
              iconTheme: IconThemeData(color: colorScheme.onSurface),
              actions: [
                TextButton.icon( // IconButton 대신 TextButton.icon 사용
                  icon: const Icon(Icons.settings_outlined), // 설정 아이콘
                  label: Text( // 텍스트 라벨 추가
                    '스테이지 설정',
                    style: TextStyle(fontSize: (theme.textTheme.labelLarge?.fontSize ?? 14.0) * 0.7), // 폰트 크기 조정 (약 10pt)
                  ),
                  onPressed: onStageSettingsPressed, // 전달받은 콜백 사용
                  style: TextButton.styleFrom( // 버튼 스타일 설정
                    foregroundColor: colorScheme.onSurface, // 아이콘 및 텍스트 색상
                    minimumSize: const Size(0, 23), // 버튼 최소 높이 설정
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0), // 패딩 조정
                    iconColor: colorScheme.onSurface, // 아이콘 색상 명시
                    iconSize: 16, // 아이콘 크기 조정
                  ),
                ),
                const SizedBox(width: 8), // 아이콘과 앱바 끝 사이 간격
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 0),
              sliver: SliverToBoxAdapter(
                child: ExpansionTile(
                  title: Text(
                    '계산 옵션 설정',
                     style: TextStyle(
                        fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16.0) + 2.0,
                        color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                        fontWeight: theme.textTheme.titleMedium?.fontWeight ?? FontWeight.normal,
                     ),
                  ),
                  iconColor: colorScheme.onSurface.withAlpha(179),
                  collapsedIconColor: colorScheme.onSurface.withAlpha(179),
                  textColor: colorScheme.secondary,
                  collapsedTextColor: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                  backgroundColor: colorScheme.surface.withAlpha(77),
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  childrenPadding: const EdgeInsets.only(bottom: 16.0, left: 4.0, right: 4.0),
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(child: Center(child: Text("경험치", style: columnHeaderStyle))),
                                // ignore: deprecated_member_use
                                VerticalDivider(width: 8, thickness: 1, color: theme.dividerColor.withOpacity(0.5)),
                                Expanded(child: Center(child: Text("골드", style: columnHeaderStyle))),
                                // ignore: deprecated_member_use
                                VerticalDivider(width: 8, thickness: 1, color: theme.dividerColor.withOpacity(0.5)),
                                Expanded(child: Center(child: Text("기타", style: columnHeaderStyle))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Center( // 각 토글을 Center 위젯으로 감싸서 셀 내에서 가운데 정렬
                                  child: _NewSwitchStyleToggleWidget(value: expHotTime, onChanged: onExpHotTimeChanged, icon: Icons.whatshot_outlined, label: "핫타임"),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Center(
                                  child: _NewSwitchStyleToggleWidget(value: goldHotTime, onChanged: onGoldHotTimeChanged, icon: Icons.local_fire_department_outlined, label: "핫타임"),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Center(
                                  child: _NewSwitchStyleToggleWidget(value: pass, onChanged: onPassChanged, icon: Icons.card_membership_outlined, label: "패스"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Center(
                                  child: _NewSwitchStyleToggleWidget(value: expBoost, onChanged: onExpBoostChanged, icon: Icons.arrow_circle_up_outlined, label: "부스트"),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Center(
                                  child: _NewSwitchStyleToggleWidget(value: goldBoost, onChanged: onGoldBoostChanged, icon: Icons.speed_outlined, label: "부스트"),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Center(
                                  child: _NewSwitchStyleToggleWidget(value: reverseElement, onChanged: onReverseElementChanged, icon: Icons.swap_horiz_outlined, label: "역속"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              buttonStyleData: ButtonStyleData(
                                height: 48, padding: const EdgeInsets.only(left: 12, right: 8),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade400,), color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor,),
                              ),
                              selectedItemBuilder: (context) => leaderList.map((item) => Container(alignment: Alignment.center, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child: Text(item, style: TextStyle(fontSize: 14, color: theme.textTheme.titleMedium?.color), softWrap: false)))).toList(),
                              hint: Container(alignment: Alignment.center, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child:Text('리더 선택', style: TextStyle(fontSize: 14, color: theme.hintColor), softWrap: false))),
                              items: leaderList.map((item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
                              value: selectedLeader,
                              onChanged: onLeaderChanged,
                              iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down), iconSize: 24),
                              dropdownStyleData: DropdownStyleData(maxHeight: 250, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), offset: const Offset(0, 0), scrollbarTheme: ScrollbarThemeData(radius: const Radius.circular(40), thickness: WidgetStateProperty.all(6), thumbVisibility: WidgetStateProperty.all(true))),
                              menuItemStyleData: const MenuItemStyleData(height: 40, padding: EdgeInsets.symmetric(horizontal: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Stack(
                            clipBehavior: Clip.none, // 텍스트가 Stack 경계를 넘어서도 보이도록 설정
                            alignment: Alignment.center, // 자식 위젯들의 기본 정렬
                            children: [
                              // 드롭다운이 주요 공간을 차지하는 기본 위젯
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  buttonStyleData: ButtonStyleData(
                                    height: 48, padding: const EdgeInsets.only(left: 12, right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: selectedMonsterName == null ? Colors.red : Colors.grey.shade400,
                                      ),
                                      color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor
                                    )
                                  ),
                                  selectedItemBuilder: (context) => monsterNameList.map((item) => Container(alignment: Alignment.center, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child: Text(item,style: TextStyle(fontSize: 14, color: theme.textTheme.titleMedium?.color), softWrap: false)))).toList(),
                                  hint: Container(alignment: Alignment.center, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child:Text('쫄 이름', style: TextStyle(fontSize: 14, color: theme.hintColor), softWrap: false))),
                                  items: monsterNameList.map((item) => DropdownMenuItem<String>(value: item, child: Text(item,style: const TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
                                  value: selectedMonsterName,
                                  onChanged: onMonsterNameChanged,
                                  iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down), iconSize: 24),
                                  dropdownStyleData: DropdownStyleData(maxHeight: 250, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), offset: const Offset(0, 0)),
                                  menuItemStyleData: const MenuItemStyleData(height: 40, padding: EdgeInsets.symmetric(horizontal: 16)),
                                ),
                              ),
                              // "필수" 텍스트를 드롭다운 위에 배치
                              if (selectedMonsterName == null)
                                Positioned(
                                  top: -13, // 드롭다운 상단보다 약간 위로 위치 조정 (텍스트 높이 고려)
                                  // left: 0, right: 0, // Stack 중앙 정렬을 위해 주석 처리 또는 삭제
                                  child: Container( // 텍스트 배경색 및 패딩을 위해 Container 사용 (선택 사항)
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                                    decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: theme.scaffoldBackgroundColor.withOpacity(0.85), // 배경색으로 가독성 확보
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '필수',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                   buttonStyleData: ButtonStyleData(height: 48, padding: const EdgeInsets.only(left: 12, right: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: selectedMonsterGrade == null ? Colors.red : Colors.grey.shade400,), color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor)),
                                   selectedItemBuilder: (context) => monsterGradeList.where((g) => !( (selectedMonsterName == '까마귀' || selectedMonsterName == '요원') && g == '6성')).map((item) => Container(alignment: Alignment.center, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child: Text(item,style: TextStyle(fontSize: 14, color: theme.textTheme.titleMedium?.color), softWrap: false)))).toList(),
                                  hint: Container(alignment: Alignment.center, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child:Text('쫄 등급', style: TextStyle(fontSize: 14, color: theme.hintColor), softWrap: false))),
                                  items: monsterGradeList
                                      .where((g) => !( (selectedMonsterName == '까마귀' || selectedMonsterName == '요원') && g == '6성'))
                                      .map((item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
                                  value: selectedMonsterGrade,
                                  onChanged: onMonsterGradeChanged,
                                  iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down), iconSize: 24),
                                  dropdownStyleData: DropdownStyleData(maxHeight: 200, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), offset: const Offset(0, 0)),
                                  menuItemStyleData: const MenuItemStyleData(height: 40, padding: EdgeInsets.symmetric(horizontal: 16)),
                                ),
                              ),
                              if (selectedMonsterGrade == null)
                                Positioned(
                                  top: -13, // 일관된 위치 조정
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                                     decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: theme.scaffoldBackgroundColor.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '필수',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0.0),
              sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded( // "스테이지 목록" 텍스트가 남은 공간을 차지하도록 함
                            child: Text('스테이지', style: TextStyle(fontSize: (theme.textTheme.titleLarge?.fontSize ?? 18.0) * 0.75, fontWeight: FontWeight.bold)),
                          ),
                          // "간략히" 텍스트와 스위치를 Row로 묶어 한 단위로 처리
                          Row(
                            mainAxisSize: MainAxisSize.min, // 자식 위젯 크기만큼만 차지
                            children: [
                              Text(
                                '미설정 숨기기',
                                style: TextStyle(fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12.0) * 0.75, color: theme.textTheme.bodySmall?.color),
                              ),
                              Transform.scale(
                                scale: 0.75,
                                alignment: Alignment.centerLeft, // 스위치 정렬
                                child: Switch(
                                  value: hideUnconfiguredStages,
                                  onChanged: onHideUnconfiguredStagesChanged,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8), // 간략히 토글과 정렬 버튼 사이 간격
                          // 정렬 드롭다운 버튼
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<CalculatorSortOption>(
                              isDense: true,
                              items: CalculatorSortOption.values
                                  .map((option) => DropdownMenuItem<CalculatorSortOption>(
                                        value: option,
                                        child: Text(
                                          sortOptionDisplayNames[option]!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ))
                                  .toList(),
                              value: selectedSortOption,
                              onChanged: onSortOptionChanged,
                              buttonStyleData: ButtonStyleData(
                                height: 40,
                                padding: const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade400),
                                  color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor,
                                ),
                              ),
                               iconStyleData: const IconStyleData(
                                icon: Icon(Icons.sort),
                                iconSize: 18,
                              ),
                               dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                                offset: const Offset(0, 0),
                                scrollbarTheme: ScrollbarThemeData(radius: const Radius.circular(40), thickness: WidgetStateProperty.all(6), thumbVisibility: WidgetStateProperty.all(true)),
                              ),
                               menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                                      ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(children: [
                          Expanded(flex: 3, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0), child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child: Text( '스테이지 명', style: headerColumnTextStyle, textAlign: TextAlign.center, softWrap: false,)))),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                customButton: Tooltip(
                                  message: "시간 표시 형식 변경",
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: colorScheme.secondary, width: 1)),
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('루프 시간', style: headerColumnClickableTextStyle.copyWith(fontSize: headerColumnClickableTextStyle.fontSize! * 0.75), softWrap: false),
                                            const SizedBox(width:2), // 아이콘과의 간격 조정 (이전에 2였던 것을 16으로 넓힘)
                                            // ignore: deprecated_member_use (이전 코드에서 아이콘 크기 계산 방식이 복잡했으나, 고정 크기로 변경)
                                            Icon(Icons.arrow_drop_down, size: 24.0, color: colorScheme.secondary.withOpacity(0.8)), // 아이콘 변경 및 크기 조정
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                items: timeFormatOptions.map((String choice) => DropdownMenuItem<String>(value: choice, child: Text(choice, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: theme.textTheme.bodyMedium?.fontSize)))).toList(),
                                onChanged: onTimeFormatChanged,
                                dropdownStyleData: DropdownStyleData(
                                  offset: const Offset(0, 0), // 버튼 하단 경계선 바로 아래에 나타나도록 조정
                                  // ignore: deprecated_member_use
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: theme.cardColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]),
                                ),
                                menuItemStyleData: const MenuItemStyleData(height: 40, padding: EdgeInsets.symmetric(horizontal: 16.0)),
                              ),
                            ),
                          ),
                          // ignore: deprecated_member_use
                          Expanded(flex: 3, child: InkWell(onTap: onToggleSoulStoneView, child: Container(padding: const EdgeInsets.symmetric(vertical: 4.0), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colorScheme.secondary, width: 1))), child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [Text(showSoulStonesPerMinute ? '분당 영혼석' : '루프 영혼석', style: headerColumnClickableTextStyle.copyWith(fontSize: headerColumnClickableTextStyle.fontSize! * 0.75), softWrap: false), const SizedBox(width: 2), Icon(Icons.swap_horiz, size: 24.0, color: colorScheme.secondary.withOpacity(0.8))])))))),
                          // ignore: deprecated_member_use
                          Expanded(flex: 3, child: InkWell(onTap: onToggleGoldView, child: Container(padding: const EdgeInsets.symmetric(vertical: 4.0), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colorScheme.secondary, width: 1))), child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [Text(showGoldPerMinute ? '분당 골드' : '루프 골드', style: headerColumnClickableTextStyle.copyWith(fontSize: headerColumnClickableTextStyle.fontSize! * 0.75), softWrap: false), const SizedBox(width: 2), Icon(Icons.swap_horiz, size: 24.0, color: colorScheme.secondary.withOpacity(0.8))])))))),
                          Expanded(flex: 1, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0), child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child: Text( '정보', style: headerColumnTextStyle, textAlign: TextAlign.center, softWrap: false,)))),
                        ]),
                      const Divider(),
                    ],
                  ),
                ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    // 필터링된 스테이지 목록 생성
                    final List<StageDisplayData> displayedStageResults = hideUnconfiguredStages
                        ? stageResults.where((data) => !data.settingsIncomplete).toList()
                        : stageResults;

                    final data = displayedStageResults[index];
                    final double? currentSoulStoneValue = showSoulStonesPerMinute
                        ? data.soulStonesPerMinValue
                        : data.soulStonesValue;

                    TextStyle soulStoneStyle = TextStyle(
                      fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14.0) * 0.75,
                      color: colorScheme.onSurface,
                    );

                    if (currentSoulStoneValue != null) {
                      if (currentSoulStoneValue < 0) {
                        soulStoneStyle = soulStoneStyle.copyWith(color: Colors.blue);
                      } else if (maxPositiveSoulStoneValue != null && currentSoulStoneValue > 0 && currentSoulStoneValue == maxPositiveSoulStoneValue) {
                        soulStoneStyle = soulStoneStyle.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        );
                      }
                    }
                     final itemBackgroundColor = data.settingsIncomplete
                        // ignore: deprecated_member_use
                        ? theme.disabledColor.withOpacity(0.1)
                        : colorScheme.surface.withAlpha(153);

                    Widget itemContent;
                    if (data.settingsIncomplete) {
                      itemContent = Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0), // 기존 패딩 유지
                          child: Text(
                            "${data.stageName}: 스테이지 설정을 먼저 진행해주세요.",
                            style: (theme.textTheme.titleMedium ?? const TextStyle(fontSize: 15.0)).copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    } else {
                      itemContent = IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: InkWell( // settingsIncomplete가 false일 때만 InkWell
                                    onTap: () => onStageNameTap(data.location),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.center,
                                            child: Text(
                                              data.stageName,
                                              style: (theme.textTheme.titleMedium ?? const TextStyle(fontSize: 16.0)).copyWith(
                                                 color: colorScheme.onSurface,
                                              ),
                                              textAlign: TextAlign.center,
                                              softWrap: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                            // if (!data.settingsIncomplete) ...[ // 이 조건은 이미 외부에서 처리됨
                              const VerticalDivider(width: 1, thickness: 1, color: Color.fromARGB(132, 202, 202, 202)),
                              Expanded(
                                flex: 3,
                                child: Padding(padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0), child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child: Text(data.totalTimeStr, textAlign: TextAlign.center, style: (theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14.0)).copyWith(color: colorScheme.onSurface, fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14.0) * 0.75), softWrap: false)))
                              ),
                              const VerticalDivider(width: 1, thickness: 1, color: Color.fromARGB(132, 202, 202, 202)),
                              Expanded(
                                flex: 3, // 루프 영혼석 열 flex 조정
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown, alignment: Alignment.center,
                                    child: Text(
                                      showSoulStonesPerMinute ? data.soulStonesPerMinStr : data.soulStonesStr,
                                      textAlign: TextAlign.center,
                                      style: soulStoneStyle, // 이미 fontSize 포함
                                      softWrap: false,
                                    ),
                                  ),
                                )
                              ),
                              const VerticalDivider(width: 1, thickness: 1, color: Color.fromARGB(132, 202, 202, 202)),
                              Expanded(
                                flex: 3, // 루프 골드 열 flex 조정
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown, alignment: Alignment.center, child: Text(showGoldPerMinute ? data.goldPerMinStr : data.loopGoldStr, textAlign: TextAlign.center, style: (theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14.0)).copyWith(color: colorScheme.onSurface, fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14.0) * 0.75), softWrap: false)),
                                )
                              ),
                              const VerticalDivider(width: 1, thickness: 1, color: Color.fromARGB(132, 202, 202, 202)),
                              Expanded(
                                flex: 1, // 정보 열 flex 조정
                                child: InkWell(
                                  onTap: () => onInfoButtonTap(data),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      // ignore: deprecated_member_use
                                      color: colorScheme.onSurface.withOpacity(0.7),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            // ],
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: itemBackgroundColor,
                          border: Border.all(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(4.0)
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: itemContent,
                      ),
                    );
                  },
                  childCount: hideUnconfiguredStages ? stageResults.where((data) => !data.settingsIncomplete).length : stageResults.length,
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 20.0)),
          ],
        ),
      ),
    );
  }
}