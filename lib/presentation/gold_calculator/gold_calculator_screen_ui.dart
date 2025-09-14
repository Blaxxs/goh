// lib/presentation/gold_calculator/gold_calculator_screen_ui.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/app_drawer.dart';
import '../../domain/logic/gold_calculator_logic.dart'; // GoldEfficiencyResult 사용
import '../../core/constants/box_constants.dart'; // AppScreen enum을 위해 추가
import '../../core/constants/leader_constants.dart';
import 'gold_calculator_screen.dart'; // TimeOption, GoldSortOption Enum 사용

class GoldEfficiencyCalculatorScreenUI extends StatelessWidget {
  // ... (기존 파라미터들은 변경 없음) ...
  final List<TimeOption> timeOptions;
  final TimeOption? selectedTimeOption;
  final ValueChanged<TimeOption?> onTimeOptionChanged;
  final TextEditingController manualTimeController;
  final FocusNode manualTimeFocusNode;

  final bool sellGoldDemons;
  final ValueChanged<bool> onSellGoldDemonsChanged;

  final String? selectedLeader;
  final ValueChanged<String?> onLeaderChanged;
  final bool goldHotTime;
  final ValueChanged<bool> onGoldHotTimeChanged;
  final bool goldBoost;
  final ValueChanged<bool> onGoldBoostChanged;
  final TextEditingController boostDurationController;

  final List<GoldEfficiencyResult> results;
  final bool isLoading;
  final Function(GoldEfficiencyResult result) onStageNameTap;
  final VoidCallback onStageSettingsPressed; // 스테이지 설정 버튼 콜백 추가

  final GoldSortOption selectedSortOption;
  final ValueChanged<GoldSortOption?> onSortOptionChanged;

  final bool hideUnconfiguredStages; // "간략히" 보기 상태 필드 추가
  final ValueChanged<bool> onHideUnconfiguredStagesChanged; // 콜백 필드 추가

  final NumberFormat _integerFormatter = NumberFormat('#,##0');

  final VoidCallback? onManualTimeSubmitted;

  GoldEfficiencyCalculatorScreenUI({
    super.key,
    required this.hideUnconfiguredStages, // 생성자에 필드 초기화 추가
    required this.onHideUnconfiguredStagesChanged, // 생성자에 필드 초기화 추가
    required this.timeOptions,
    required this.selectedTimeOption,
    required this.onTimeOptionChanged,
    required this.manualTimeController,
    required this.manualTimeFocusNode,
    required this.sellGoldDemons,
    required this.onSellGoldDemonsChanged,
    required this.selectedLeader,
    required this.onLeaderChanged,
    required this.goldHotTime,
    required this.onGoldHotTimeChanged,
    required this.goldBoost,
    required this.onGoldBoostChanged,
    required this.boostDurationController,
    required this.results,
    required this.isLoading,
    required this.onStageNameTap,
    required this.onStageSettingsPressed, // 생성자에 추가
    required this.selectedSortOption,
    required this.onSortOptionChanged, 
    this.onManualTimeSubmitted,
  });

  // 설정 토글 위젯 수정: 스위치를 텍스트 아래로 이동
  Widget _buildSettingToggle(BuildContext context, {
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    // Use a theme style that will be scaled globally by main.dart
    final scaledFontSize = theme.textTheme.bodySmall?.fontSize; // Example: using bodySmall

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        child: Column( // 세로 배치로 변경하여 스위치를 아래로 내림
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // 자식들을 가로축 중앙에 정렬
          children: [
            Row( // 아이콘과 텍스트는 가로로 배치            
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: value ? theme.colorScheme.secondary : theme.textTheme.bodySmall?.color),
                const SizedBox(width: 4),
                // Flexible을 사용하여 텍스트가 공간 내에서 확장될 수 있도록 함
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: scaledFontSize, 
                      fontWeight: value ? FontWeight.bold : FontWeight.normal,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    softWrap: true, // Allow text to wrap
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0), // 텍스트와 스위치 사이의 수직 간격 (아주 작게)            
            Transform.scale(
              scale: 0.8, // 스위치 크기 조정
              child: Switch(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    final TextStyle? titleStyle = appBarTheme.titleTextStyle;
    final headerStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.textTheme.bodySmall?.color);
    const double inputFieldHeight = 48.0;
    const inputFieldLabelSize = 13.0;
    const inputFieldTextSize = 13.0;
    const inputFieldContentPaddingHorizontal = 10.0;
    const double dropdownContentVerticalPadding = (inputFieldHeight - inputFieldTextSize - 10) / 2;
    const double textFormFieldContentVerticalPadding = (inputFieldHeight - inputFieldTextSize - (inputFieldLabelSize*0.3) -10 ) /2 ;

    const Map<GoldSortOption, String> sortOptionDisplayNames = {
      GoldSortOption.stageName: '스테이지명',
      GoldSortOption.totalGold: '최종 골드',
    };

    return Scaffold(
      drawer: const AppDrawer(currentScreen: AppScreen.goldCalculator),
      appBar: AppBar(
        title: FittedBox( // AppBar 제목이 길어질 경우 축소되도록 FittedBox 추가
          fit: BoxFit.scaleDown,
          child: Text(
            '골드 효율 계산기',
            style: titleStyle?.copyWith(
              fontSize: (titleStyle.fontSize ?? 20) + 2.0,
            ),
          ),
        ),
        
      ), // AppBar 닫는 괄호
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    height: inputFieldHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField2<TimeOption>(
                                  decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.fromLTRB(inputFieldContentPaddingHorizontal, 0, 4, dropdownContentVerticalPadding*0.8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), labelText: '시간 선택', labelStyle: const TextStyle(fontSize: inputFieldLabelSize)),
                                  isExpanded: true,
                                  items: timeOptions.map((option) => DropdownMenuItem<TimeOption>(value: option, child: Text(option.display, style: const TextStyle(fontSize: inputFieldTextSize), overflow: TextOverflow.ellipsis))).toList(),
                                  value: selectedTimeOption,
                                  onChanged: onTimeOptionChanged,
                                  buttonStyleData: const ButtonStyleData(height: inputFieldHeight),
                                  iconStyleData: const IconStyleData(iconSize: 20),
                                  dropdownStyleData: DropdownStyleData(maxHeight: 250, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12))),
                                  menuItemStyleData: const MenuItemStyleData(height: 40),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.symmetric(horizontal: 6.0), child: Center(child: Text("또는", style: TextStyle(fontSize: inputFieldTextSize)))),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: manualTimeController,
                                  focusNode: manualTimeFocusNode,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(labelText: '분 입력', labelStyle: const TextStyle(fontSize: inputFieldLabelSize), hintText: '분', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: inputFieldContentPaddingHorizontal, vertical: textFormFieldContentVerticalPadding+6)),
                                  style: const TextStyle(fontSize: inputFieldTextSize),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      onEditingComplete: onManualTimeSubmitted, // 이 부분 추가

                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField2<String>(
                            decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.fromLTRB(inputFieldContentPaddingHorizontal, 0, 4, dropdownContentVerticalPadding*0.8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), labelText: '리더 선택', labelStyle: const TextStyle(fontSize: inputFieldLabelSize)),
                            isExpanded: true,
                            hint: const Text('리더', style: TextStyle(fontSize: inputFieldTextSize)),
                            items: leaderList.map((leader) => DropdownMenuItem<String>(value: leader, child: Text(leader, style: const TextStyle(fontSize: inputFieldTextSize), overflow: TextOverflow.ellipsis))).toList(),
                            value: selectedLeader,
                            onChanged: onLeaderChanged,
                            buttonStyleData: const ButtonStyleData(height: inputFieldHeight),
                            iconStyleData: const IconStyleData(iconSize: 20),
                            dropdownStyleData: DropdownStyleData(maxHeight: 200, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12))),
                            menuItemStyleData: const MenuItemStyleData(height: 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Column 자식들 상단 정렬
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSettingToggle(context, label: "골드 핫타임", value: goldHotTime, onChanged: onGoldHotTimeChanged, icon: Icons.local_fire_department_outlined),
                        const SizedBox(width: 4), // 토글 간 간격
                        _buildSettingToggle(context, label: "골드 부스트", value: goldBoost, onChanged: onGoldBoostChanged, icon: Icons.arrow_circle_up_outlined),
                        const SizedBox(width: 4), // 토글 간 간격
                        _buildSettingToggle(context, label: "돈악마 판매", value: sellGoldDemons, onChanged: onSellGoldDemonsChanged, icon: Icons.sell_outlined),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: goldBoost,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                      child: SizedBox(
                        height: inputFieldHeight,
                        child: TextFormField(
                          controller: boostDurationController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(labelText: '부스트 적용 시간 (분)', labelStyle: const TextStyle(fontSize: inputFieldLabelSize), hintText: '전체 시간 적용 시 0 또는 비워두기', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: inputFieldContentPaddingHorizontal, vertical: textFormFieldContentVerticalPadding+6)),
                          style: const TextStyle(fontSize: inputFieldTextSize),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2, // 정렬 드롭다운과의 공간 비율 조정을 위해 flex 추가
                        child: Text(
                          '스테이지',
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis, // 텍스트가 너무 길 경우 대비
                        ),
                      ),
                      // "간략히" 텍스트와 스위치를 Row로 묶어 한 단위로 처리
                      Row(
                        mainAxisSize: MainAxisSize.min, // 자식 위젯 크기만큼만 차지
                        children: [
                          Text(
                            '미설정 숨기기',
                            style: TextStyle(fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12.0) * 0.8, color: theme.textTheme.bodySmall?.color), // 폰트 크기 20% 감소
                          ),
                          Transform.scale(
                            scale: 0.6, // 스위치 크기 20% 추가 감소 (0.75 * 0.8)
                            alignment: Alignment.center,
                            child: Switch(
                              value: hideUnconfiguredStages,
                              onChanged: onHideUnconfiguredStagesChanged,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40), // 간략히 토글과 정렬 버튼 사이 간격 (왼쪽 이동 효과를 위해 증가)
                      // 정렬 드롭다운 버튼을 Flexible로 감싸서 공간이 부족할 때 축소되도록 함
                      Flexible(
                        flex: 3, // "스테이지" 텍스트와의 공간 비율 조정을 위해 flex 추가
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<GoldSortOption>(
                            isExpanded: true, // Flexible 내부에서 DropdownButton2가 확장되도록 설정
                            isDense: true,
                            items: GoldSortOption.values.map((option) => DropdownMenuItem<GoldSortOption>(
                                    value: option,
                                    child: Text( // 드롭다운 메뉴 아이템 텍스트
                                      sortOptionDisplayNames[option]!,
                                      style: TextStyle(fontSize: theme.textTheme.bodyMedium?.fontSize ?? 14), // 테마 폰트 크기 사용
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )).toList(),
                            value: selectedSortOption,
                            onChanged: onSortOptionChanged,
                            buttonStyleData: ButtonStyleData(
                              height: 40,
                              padding: const EdgeInsets.only(left: 14, right: 14), // 루프 계산기와 동일하게 패딩 조정
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.grey.shade400),
                                 color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor,
                               ),
                            ),
                            selectedItemBuilder: (context) { // 버튼에 표시될 선택된 아이템
                              return GoldSortOption.values.map((option) {
                                return Container(
                                  alignment: Alignment.center, // FittedBox 내부 Text 정렬을 위해 중요
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown, // 텍스트 크기를 줄여서 맞춤
                                    child: Text(
                                      sortOptionDisplayNames[option]!,
                                      style: TextStyle(fontSize: theme.textTheme.bodyMedium?.fontSize ?? 14, color: theme.textTheme.titleMedium?.color),
                                      // overflow: TextOverflow.ellipsis, // FittedBox 사용 시 불필요하거나 다르게 동작할 수 있음
                                      softWrap: false, // 한 줄로 표시되도록 강제
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                             iconStyleData: const IconStyleData(icon: Icon(Icons.sort), iconSize: 18),
                             dropdownStyleData: DropdownStyleData(
                               maxHeight: 200,
                               decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                               offset: const Offset(0, 0),
                               scrollbarTheme: ScrollbarThemeData(radius: const Radius.circular(40), thickness: WidgetStateProperty.all(6), thumbVisibility: WidgetStateProperty.all(true)),
                             ),
                             menuItemStyleData: const MenuItemStyleData(height: 40, padding: EdgeInsets.only(left: 14, right: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: Text('스테이지명', style: headerStyle, textAlign: TextAlign.left)),
                        Expanded(flex: 3, child: Text('스테이지 골드', style: headerStyle, textAlign: TextAlign.right)),
                        Expanded(flex: 3, child: Text('돈악마 골드', style: headerStyle, textAlign: TextAlign.right)),
                        Expanded(flex: 3, child: Text('최종 골드', style: headerStyle, textAlign: TextAlign.right)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : (hideUnconfiguredStages && results.where((r) => r.clearTimeSeconds != null && r.clearTimeSeconds! > 0).isEmpty && results.isNotEmpty) // 간략히 모드인데 보여줄 게 없을 때
                            ? const Center(child: Text('표시할 설정 완료된 스테이지가 없습니다.'))
                            : results.isEmpty // 아예 결과가 없을 때
                                ? const Center(child: Text('옵션을 확인하거나 시간을 입력해주세요.'))
                            : ListView.separated(
                                itemCount: hideUnconfiguredStages
                                    ? results.where((r) => r.clearTimeSeconds != null && r.clearTimeSeconds! > 0).length
                                    : results.length,
                                separatorBuilder: (context, index) => const Divider(height: 1, indent: 8, endIndent: 8),
                                itemBuilder: (context, index) {
                                  final List<GoldEfficiencyResult> displayedResults = hideUnconfiguredStages
                                      ? results.where((r) => r.clearTimeSeconds != null && r.clearTimeSeconds! > 0).toList()
                                      : results;
                                  final result = displayedResults[index];
                                  bool isIncomplete = result.clearTimeSeconds == null || result.clearTimeSeconds! <= 0;
                                  Color? rowColor = isIncomplete ? Colors.grey.withAlpha((0.1 * 255).round()) : null;

                                  if (isIncomplete) {
                                    return InkWell(
                                      onTap: () => onStageNameTap(result),
                                      child: Container(
                                        color: rowColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${result.stageName}: 스테이지 설정을 먼저 진행해주세요.",
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 15 * (theme.textTheme.titleMedium?.fontSize ?? 15.0) / 15.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  } else {
                                    String stageGoldText = _integerFormatter.format(result.expectedGoldFromStage.round());
                                    String demonGoldText;
                                    String totalGoldText;
                                    if (sellGoldDemons) {
                                      demonGoldText = _integerFormatter.format(result.expectedGoldFromDemons.round());
                                      totalGoldText = _integerFormatter.format(result.totalExpectedGold.round());
                                    } else {
                                      demonGoldText = '-';
                                      totalGoldText = stageGoldText;
                                    }
                                    TextStyle valueStyle = TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color);

                                    return InkWell(
                                      onTap: () => onStageNameTap(result),
                                      child: Container(
                                         color: rowColor,
                                         padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
                                         child: Row(
                                           children: [
                                             Expanded(
                                               flex: 4,
                                               child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                     Text(
                                                       result.stageName,
                                                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.textTheme.bodyLarge?.color),
                                                       textAlign: TextAlign.left,
                                                       overflow: TextOverflow.ellipsis,
                                                     ),
                                                  ],
                                                ),
                                             ),
                                             Expanded(flex: 3, child: Text(stageGoldText, textAlign: TextAlign.right, style: valueStyle)),
                                             Expanded(flex: 3, child: Text(demonGoldText, textAlign: TextAlign.right, style: valueStyle)),
                                             Expanded(
                                               flex: 3,
                                               child: Text(
                                                 totalGoldText,
                                                 style: valueStyle.copyWith(
                                                   fontWeight: FontWeight.bold,
                                                   color: theme.colorScheme.secondary,
                                                   fontSize: 15,
                                                 ),
                                                 textAlign: TextAlign.right,
                                               )
                                             ),
                                           ],
                                         ),
                                      ),
                                    );
                                  }
                                },
                              ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withAlpha((0.3 * 255).round()),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}