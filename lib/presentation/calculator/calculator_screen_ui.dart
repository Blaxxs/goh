// lib/presentation/calculator/calculator_screen_ui.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../constants/leader_constants.dart';
import '../../constants/monster_constants.dart';
import '../../calculator_screen.dart'; // CalculatorSortOption Enum 사용
import '../widgets/app_drawer.dart';

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
    final baseFontSize = theme.textTheme.bodyMedium?.fontSize ?? 13.0;
    final scaledFontSize = 12.5 * (baseFontSize / 13.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: value ? theme.colorScheme.secondary : theme.textTheme.bodySmall?.color),
        const SizedBox(width: 3),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            label,
            style: TextStyle(
              fontSize: scaledFontSize, // fontSize 명시
              fontWeight: value ? FontWeight.bold : FontWeight.normal,
              color: theme.textTheme.bodyMedium?.color,
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 2),
        Transform.scale(
          scale: 0.75,
          alignment: Alignment.centerRight,
          child: Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
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

  final double? maxPositiveSoulStoneValue;

  final CalculatorSortOption selectedSortOption;
  final ValueChanged<CalculatorSortOption?> onSortOptionChanged;

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
    required this.selectedSortOption,
    required this.onSortOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    final TextStyle? titleStyle = appBarTheme.titleTextStyle;
    final TextStyle columnHeaderStyle = TextStyle(
      fontSize: 15 * (theme.textTheme.titleMedium?.fontSize ?? 15.0) / 15.0, // fontSize 명시
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
      CalculatorSortOption.stageName: '스테이지명 순',
      CalculatorSortOption.soulStone: '영혼석 순',
      CalculatorSortOption.gold: '골드 순',
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
                TextButton.icon(
                    icon: Icon(Icons.info_outline, color: colorScheme.onSurface),
                    label: Text(
                      '정보',
                      style: TextStyle(fontSize: 16 * (theme.textTheme.labelLarge?.fontSize ?? 16.0) / 16.0 ),
                    ),
                    onPressed: onShowInfoAlertPressed,
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 0),
              sliver: SliverToBoxAdapter(
                child: ExpansionTile(
                  title: Text(
                    '계산 옵션 설정',
                     style: TextStyle(
                        fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16.0) + 2.0, // fontSize 명시
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
                                VerticalDivider(width: 8, thickness: 1, color: theme.dividerColor.withOpacity(0.5)),
                                Expanded(child: Center(child: Text("골드", style: columnHeaderStyle))),
                                VerticalDivider(width: 8, thickness: 1, color: theme.dividerColor.withOpacity(0.5)),
                                Expanded(child: Center(child: Text("기타", style: columnHeaderStyle))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: _NewSwitchStyleToggleWidget(value: expHotTime, onChanged: onExpHotTimeChanged, icon: Icons.whatshot_outlined, label: "핫타임")),
                              const SizedBox(width: 2),
                              Expanded(child: _NewSwitchStyleToggleWidget(value: goldHotTime, onChanged: onGoldHotTimeChanged, icon: Icons.local_fire_department_outlined, label: "핫타임")),
                              const SizedBox(width: 2),
                              Expanded(child: _NewSwitchStyleToggleWidget(value: pass, onChanged: onPassChanged, icon: Icons.card_membership_outlined, label: "패스")),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: _NewSwitchStyleToggleWidget(value: expBoost, onChanged: onExpBoostChanged, icon: Icons.arrow_circle_up_outlined, label: "부스트")),
                              const SizedBox(width: 2),
                              Expanded(child: _NewSwitchStyleToggleWidget(value: goldBoost, onChanged: onGoldBoostChanged, icon: Icons.speed_outlined, label: "부스트")),
                              const SizedBox(width: 2),
                              Expanded(child: _NewSwitchStyleToggleWidget(value: reverseElement, onChanged: onReverseElementChanged, icon: Icons.swap_horiz_outlined, label: "역속")),
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
                              selectedItemBuilder: (context) => leaderList.map((item) => Container(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(item, style: TextStyle(fontSize: 14, color: theme.textTheme.titleMedium?.color), softWrap: false)))).toList(),
                              hint: Container(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child:Text('리더 선택', style: TextStyle(fontSize: 14, color: theme.hintColor), softWrap: false))),
                              items: leaderList.map((item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
                              value: selectedLeader,
                              onChanged: onLeaderChanged,
                              iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down), iconSize: 24),
                              dropdownStyleData: DropdownStyleData(maxHeight: 250, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), offset: const Offset(0, -4), scrollbarTheme: ScrollbarThemeData(radius: const Radius.circular(40), thickness: WidgetStateProperty.all(6), thumbVisibility: WidgetStateProperty.all(true))),
                              menuItemStyleData: const MenuItemStyleData(height: 40, padding: EdgeInsets.symmetric(horizontal: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                               buttonStyleData: ButtonStyleData(height: 48, padding: const EdgeInsets.only(left: 12, right: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade400,), color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor)),
                              selectedItemBuilder: (context) => monsterNameList.map((item) => Container(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(item,style: TextStyle(fontSize: 14, color: theme.textTheme.titleMedium?.color), softWrap: false)))).toList(),
                              hint: Container(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child:Text('쫄 이름', style: TextStyle(fontSize: 14, color: theme.hintColor), softWrap: false))),
                              items: monsterNameList.map((item) => DropdownMenuItem<String>(value: item, child: Text(item,style: const TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
                              value: selectedMonsterName,
                              onChanged: onMonsterNameChanged,
                              iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down), iconSize: 24),
                              dropdownStyleData: DropdownStyleData(maxHeight: 250, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), offset: const Offset(0, -4)),
                              menuItemStyleData: const MenuItemStyleData(height: 40, padding: EdgeInsets.symmetric(horizontal: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                               buttonStyleData: ButtonStyleData(height: 48, padding: const EdgeInsets.only(left: 12, right: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade400,), color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor)),
                               selectedItemBuilder: (context) => monsterGradeList.where((g) => !( (selectedMonsterName == '까마귀' || selectedMonsterName == '요원') && g == '6성')).map((item) => Container(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(item,style: TextStyle(fontSize: 14, color: theme.textTheme.titleMedium?.color), softWrap: false)))).toList(),
                              hint: Container(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child:Text('쫄 등급', style: TextStyle(fontSize: 14, color: theme.hintColor), softWrap: false))),
                              items: monsterGradeList
                                  .where((g) => !( (selectedMonsterName == '까마귀' || selectedMonsterName == '요원') && g == '6성'))
                                  .map((item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
                              value: selectedMonsterGrade,
                              onChanged: onMonsterGradeChanged,
                              iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down), iconSize: 24),
                              dropdownStyleData: DropdownStyleData(maxHeight: 200, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), offset: const Offset(0, -4)),
                              menuItemStyleData: const MenuItemStyleData(height: 40, padding: EdgeInsets.symmetric(horizontal: 16)),
                            ),
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
                          Text('스테이지 목록', style: TextStyle(fontSize: 18 * (theme.textTheme.titleLarge?.fontSize ?? 18.0) / 18.0, fontWeight: FontWeight.bold)),
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
                          Expanded(flex: 3, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0), child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child: Text( '스테이지', style: headerColumnTextStyle, textAlign: TextAlign.center, softWrap: false,)))),
                          Expanded(flex: 3, child: PopupMenuButton<String>(onSelected: onTimeFormatChanged, itemBuilder: (BuildContext context) => timeFormatOptions.map((String choice) => PopupMenuItem<String>(value: choice, child: Text(choice, overflow: TextOverflow.ellipsis))).toList(), tooltip: "시간 표시 형식 변경", child: Container(padding: const EdgeInsets.symmetric(vertical: 4.0), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colorScheme.secondary, width: 1))), child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text('루프 시간', style: headerColumnClickableTextStyle, softWrap: false,)))))),
                          Expanded(flex: 2, child: InkWell(onTap: onToggleSoulStoneView, child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0), child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child: Text(showSoulStonesPerMinute ? '분당 영혼석' : '루프 영혼석', style: headerColumnTextStyle, textAlign: TextAlign.center, softWrap: false,))))),
                          Expanded(flex: 2, child: InkWell(onTap: onToggleGoldView, child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0), child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child:Text(showGoldPerMinute ? '분당 골드' : '루프 골드', style: headerColumnTextStyle, textAlign: TextAlign.center, softWrap: false,))))),
                          Expanded(flex: 2, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0), child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child: Text( '정보', style: headerColumnTextStyle, textAlign: TextAlign.center, softWrap: false,)))),
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
                    final data = stageResults[index];
                    final double? currentSoulStoneValue = showSoulStonesPerMinute
                        ? data.soulStonesPerMinValue
                        : data.soulStonesValue;

                    TextStyle soulStoneStyle = TextStyle(
                      fontSize: 14 * (theme.textTheme.bodyMedium?.fontSize ?? 14.0) / 14.0, // fontSize 명시
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
                        ? theme.disabledColor.withOpacity(0.1)
                        : colorScheme.surface.withAlpha(153);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: itemBackgroundColor,
                          border: Border.all(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(4.0)
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: data.settingsIncomplete
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          "스테이지 설정을 먼저 진행해주세요.",
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 15 * (theme.textTheme.titleMedium?.fontSize ?? 15.0) / 15.0, // fontSize 명시
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : InkWell(
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
                                                style: TextStyle(
                                                  fontSize: 16 * (theme.textTheme.titleMedium?.fontSize ?? 16.0) / 16.0, // fontSize 명시
                                                  color: colorScheme.onSurface
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
                              if (!data.settingsIncomplete) ...[
                                const VerticalDivider(width: 1, thickness: 1, color: Color.fromARGB(132, 202, 202, 202)),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown, alignment: Alignment.center,
                                      child: Text(data.totalTimeStr, textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14 * (theme.textTheme.bodyMedium?.fontSize ?? 14.0) / 14.0, color: colorScheme.onSurface), softWrap: false)), // fontSize 명시
                                  )
                                ),
                                const VerticalDivider(width: 1, thickness: 1, color: Color.fromARGB(132, 202, 202, 202)),
                                Expanded(
                                  flex: 2,
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
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown, alignment: Alignment.center,
                                      child: Text(showGoldPerMinute ? data.goldPerMinStr : data.loopGoldStr,
                                      textAlign: TextAlign.center, style: TextStyle(fontSize: 14 * (theme.textTheme.bodyMedium?.fontSize ?? 14.0) / 14.0, color: colorScheme.onSurface), softWrap: false)), // fontSize 명시
                                  )
                                ),
                                const VerticalDivider(width: 1, thickness: 1, color: Color.fromARGB(132, 202, 202, 202)),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () => onInfoButtonTap(data),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                                      child: Icon(
                                        Icons.info_outline_rounded,
                                        color: colorScheme.onSurface.withOpacity(0.7),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ]
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: stageResults.length,
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