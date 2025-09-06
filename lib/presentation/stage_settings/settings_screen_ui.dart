// lib/presentation/settings/settings_screen_ui.dart
import 'package:flutter/material.dart';
import 'dart:math'; // 난수 생성을 위해 추가
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../core/constants/vip_constants.dart';
import '../../core/constants/stage_constants.dart';
import '../../core/constants/monster_constants.dart';
import '../calculator/calculator_screen.dart'; // 루프 계산기 화면 import 추가

class SettingsScreenUI extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController teamLevelController;
  final TextEditingController dalgijiLevelController;
  final Map<String, TextEditingController> clearTimeControllers;
  final String? selectedVipLevel;
  final Map<String, String?> selectedJjolCounts;
  final ValueChanged<String?> onVipLevelChanged;
  final Function(String stageName, String? value) onJjolCountChanged;
  final VoidCallback onSavePressed;
  final VoidCallback onResetPressed;
  final bool isSetupMode; // 최초 설정 모드 여부

  const SettingsScreenUI({
    super.key,
    required this.formKey,
    required this.teamLevelController,
    required this.dalgijiLevelController,
    required this.clearTimeControllers,
    required this.selectedVipLevel,
    required this.selectedJjolCounts,
    required this.onVipLevelChanged,
    required this.onJjolCountChanged,
    required this.onSavePressed,
    required this.onResetPressed,
    required this.isSetupMode, // 생성자에 추가
  });

  // 스테이지 설정 테이블의 헤더를 생성하는 위젯
  Widget _buildStageSettingsHeader(BuildContext context) {
    final theme = Theme.of(context);
    final baseHeaderStyle = theme.textTheme.bodyMedium;
    final headerStyle = baseHeaderStyle?.copyWith(
      fontWeight: FontWeight.bold, // 폰트 크기 20% 증가 (기존 0.7에서 0.84로)
      fontSize: (baseHeaderStyle.fontSize ?? 14.0) * 0.84,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 30,
            child: Text('스테이지', style: headerStyle),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 30,
            child: Text('클리어 시간(초)', style: headerStyle, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 20,
            child: Text('쫄 갯수', style: headerStyle, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 17, child: Text('임의설정', style: headerStyle, textAlign: TextAlign.center)), // 비율 조정을 통해 15% 감소
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle saveButtonStyle = Theme.of(context).elevatedButtonTheme.style ?? ElevatedButton.styleFrom();
    final ButtonStyle resetButtonStyle = OutlinedButton.styleFrom(
       foregroundColor: Theme.of(context).colorScheme.error,
       side: BorderSide(color: Theme.of(context).colorScheme.error.withAlpha(150)),
    );
    final theme = Theme.of(context);
    // 스테이지 목록에 적용할 30% 감소된 폰트 스타일
    final reducedListTextStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16.0) * 0.7,
    );
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    final TextStyle? titleStyle = appBarTheme.titleTextStyle;

    // 테마에서 현재 적용된 titleMedium 폰트 크기를 가져옵니다.
    // (기본 16.0 * (2/3) * 사용자 설정 배율)이 적용된 값입니다.
    final double titleMediumFontSize = theme.textTheme.titleMedium?.fontSize ?? (16.0 * (2.0/3.0)); 

    // TextFormField와 Dropdown의 contentPadding 계산
    const double textFormFieldVerticalPadding = 12.0;
    const EdgeInsets textFormFieldContentPadding = EdgeInsets.symmetric(horizontal: 10.0, vertical: textFormFieldVerticalPadding);
    
    // 드롭다운 아이콘이 텍스트보다 클 경우를 고려하여 드롭다운의 수직 패딩을 동적으로 조정
    final double dropdownCalculatedVerticalPadding = (textFormFieldVerticalPadding - titleMediumFontSize * 0.25).clamp(9.0, textFormFieldVerticalPadding); // 최소 클램핑 값을 8.0에서 9.0으로 조정
    final EdgeInsets dropdownInputDecorationContentPadding = EdgeInsets.symmetric(horizontal: 10.0, vertical: dropdownCalculatedVerticalPadding);
    final double dynamicIconSize = titleMediumFontSize * 1.7; // 아이콘 크기도 동적으로 계산

    // 스테이지 이름을 한글 가나다순으로 정렬
    final List<String> sortedStageNames = List.from(stageNameList);
    sortedStageNames.sort((a, b) => a.compareTo(b));

    return Scaffold(
      appBar: AppBar(
        leading: isSetupMode // isSetupMode에 따라 뒤로가기 버튼 표시 여부 결정
            ? null // 최초 설정 모드에서는 뒤로가기 버튼 숨김
            : IconButton( 
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
        title: Text(
          '스테이지 설정',
          style: titleStyle?.copyWith(
            fontSize: (titleStyle.fontSize ?? 20) + 2.0, // 기존 폰트 크기에서 2.0 증가
          ),
        ),
      ),
      body: SafeArea( // 네비게이션 바와 겹침 방지
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3, // 팀 레벨 입력창 가로 길이 25% 감소 (기존 4에서 3으로)
                      child: TextFormField(
                        controller: teamLevelController,
                        keyboardType: TextInputType.number,
                        style: theme.textTheme.titleMedium, // 입력 텍스트 스타일
                        decoration: const InputDecoration(
                          labelText: '팀 레벨',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: textFormFieldContentPadding,
                        ),
                        validator: (value) {
                          if (isSetupMode && (value == null || value.isEmpty)) { // 최초 설정 모드일 때 필수 검사
                            return '팀 레벨 필수';
                          }
                          if (int.tryParse(value!) == null) { return '숫자만'; }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: dalgijiLevelController,
                        keyboardType: TextInputType.number,
                        style: theme.textTheme.titleMedium, // 입력 텍스트 스타일
                        decoration: const InputDecoration(
                          labelText: '달기지 레벨',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: textFormFieldContentPadding,
                        ),
                        validator: (value) {
                          if (isSetupMode && (value == null || value.isEmpty)) { // 최초 설정 모드일 때 필수 검사
                            return '달기지 레벨 필수';
                          }
                          if (int.tryParse(value!) == null) { return '숫자만'; }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: DropdownButtonFormField2<String>(
                        decoration: InputDecoration(
                          labelText: 'VIP 등급', // 레이블 추가
                          isDense: true,
                          contentPadding: dropdownInputDecorationContentPadding, // 드롭다운용 패딩 사용
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        isExpanded: true,
                        buttonStyleData: ButtonStyleData(
                          // height: 50, // 고정 높이 제거
                          padding: const EdgeInsets.only(left: 0, right: 10), // VIP 드롭다운 오른쪽 패딩 조정
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor,
                          ),
                        ),
                        hint: Container(alignment: Alignment.centerLeft, child: Text('VIP 등급', style: (theme.textTheme.titleMedium ?? const TextStyle(fontSize: 14.0)).copyWith(color: theme.hintColor), softWrap: false, overflow: TextOverflow.ellipsis)),
                        items: vipLevels.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item, overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium, // 테마 폰트 스타일 직접 사용
                            ),
                          );
                        }).toList(),
                        value: selectedVipLevel,
                        onChanged: onVipLevelChanged,
                        validator: (value) {
                          if (isSetupMode && (value == null || value.isEmpty)) { // 최초 설정 모드일 때 필수 검사
                            return 'VIP 등급 필수';
                          }
                          return null;
                        },
                        iconStyleData: IconStyleData( // const 제거
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey), // Icon은 const 유지 가능
                          iconSize: dynamicIconSize, // 계산된 동적 아이콘 크기 사용
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 300,
                          offset: const Offset(0, -4),
                           decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: WidgetStateProperty.all(6),
                            thumbVisibility: WidgetStateProperty.all(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        selectedItemBuilder: (context) {
                          return vipLevels.map((item) {
                            return Container(
                              alignment: Alignment.centerLeft, // 텍스트를 왼쪽에 정렬
                              padding: const EdgeInsets.symmetric(horizontal: 0.0), // 필요시 패딩 조정
                              child: Text(
                                item,
                                style: theme.textTheme.titleMedium, // 테마 폰트 스타일 직접 사용
                                softWrap: false, // 한 줄로 표시
                                overflow: TextOverflow.ellipsis, // 넘칠 경우 ... 처리
                              ),
                            );
                          }).toList();
                        },
                        // iconStyleData를 여기서 theme을 사용하여 동적으로 설정합니다.
                        // DropdownButtonFormField2의 파라미터 목록에서 iconStyleData는 한 번만 선언되어야 합니다.
                        // 기존 선언을 수정하거나, 이 위치로 옮깁니다. 여기서는 기존 선언을 수정하는 방식으로 접근합니다.
                        // (실제 diff에서는 기존 iconStyleData 선언 부분을 수정하는 형태로 나타납니다)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('스테이지별 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildStageSettingsHeader(context),
                const Divider(height: 1),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedStageNames.length, // 정렬된 리스트 사용
                  itemBuilder: (context, index) {
                    final stageName = sortedStageNames[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 30,
                            child: Text(
                              stageName,
                              style: reducedListTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            flex: 30,
                            child: TextFormField(
                              controller: clearTimeControllers[stageName],
                              style: reducedListTextStyle,
                              textAlign: TextAlign.center,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                              ],
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                isDense: true,
                                contentPadding: textFormFieldContentPadding,
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final double? parsedValue = double.tryParse(value);
                                  if (parsedValue == null) {
                                    return '숫자';
                                  }
                                  if (parsedValue <= 0) {
                                    return '> 0';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            flex: 20,
                            child: DropdownButtonFormField2<String>(
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: dropdownInputDecorationContentPadding,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              isExpanded: true,
                              items: jjolCounts.map((String count) {
                                return DropdownMenuItem<String>(
                                    value: count, child: Center(child: Text(count, style: reducedListTextStyle)));
                              }).toList(),
                              value: selectedJjolCounts[stageName],
                              onChanged: (String? value) {
                                onJjolCountChanged(stageName, value);
                              },
                              buttonStyleData: ButtonStyleData(
                                padding: const EdgeInsets.only(left: 0, right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor,
                                ),
                              ),
                              iconStyleData: IconStyleData(
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                iconSize: dynamicIconSize,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                offset: const Offset(0, -4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(40),
                                  thickness: WidgetStateProperty.all(6),
                                  thumbVisibility: WidgetStateProperty.all(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              selectedItemBuilder: (context) {
                                return jjolCounts.map((item) {
                                  return Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      item,
                                      style: reducedListTextStyle,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            flex: 17, // 비율 조정을 통해 15% 감소
                            child: IconButton(
                              onPressed: () {
                                final random = Random();
                                final randomClearTime = (random.nextInt(31) + 30).toString(); // 30 ~ 60
                                final randomJjolCount = (random.nextInt(4) + 1).toString(); // 1 ~ 4

                                clearTimeControllers[stageName]?.text = randomClearTime;
                                onJjolCountChanged(stageName, randomJjolCount);
                              },
                              icon: const Icon(Icons.casino_outlined),
                              tooltip: '임의 설정',
                              color: theme.colorScheme.secondary,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                //여기 아래부터
                // "모든 값 임의 설정" 버튼 추가 (릴리즈 시 주석 처리)
                // SizedBox(
                //   width: double.infinity,
                //   child: OutlinedButton.icon(
                //     icon: const Icon(Icons.casino_rounded),
                //     label: const Text('모든 값 임의 설정'),
                //     style: OutlinedButton.styleFrom(
                //       foregroundColor: theme.colorScheme.primary,
                //       side: BorderSide(color: theme.colorScheme.primary.withAlpha(150)),
                //       padding: const EdgeInsets.symmetric(vertical: 10.0),
                //     ),
                //     onPressed: () {
                //       final random = Random();
                //       // 1. 팀 레벨 (1~700)
                //       teamLevelController.text = (random.nextInt(700) + 1).toString();
                //       // 2. 달기지 레벨 (1~200)
                //       dalgijiLevelController.text = (random.nextInt(200) + 1).toString();
                //       // 3. VIP 등급 (랜덤 선택)
                //       onVipLevelChanged(vipLevels[random.nextInt(vipLevels.length)]);
                //       // 4 & 5. 모든 스테이지 클리어 시간 및 쫄 개수
                //       for (var stageName in sortedStageNames) {
                //         clearTimeControllers[stageName]?.text = (random.nextInt(31) + 30).toString(); // 30~60
                //         onJjolCountChanged(stageName, (random.nextInt(4) + 1).toString()); // 1~4
                //       }
                //     },
                //   ),
                // ),
                // const SizedBox(height: 12), // "모든 값 임의 설정" 버튼과 하단 버튼들 사이 간격
                //여기 위까지
                if (isSetupMode) // 최초 설정 모드일 때 "설정 완료" 버튼 표시
                  SizedBox( // 버튼 너비를 화면에 맞게 조절하기 위해 SizedBox 사용
                    width: double.infinity,
                    child: ElevatedButton(
                      style: saveButtonStyle.copyWith(
                        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                      ),
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          onSavePressed(); // 설정 저장
                          // 홈 화면 대신 루프 계산기 화면으로 이동
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const CalculatorScreen()),
                          );
                        } else {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('필수 항목을 모두 입력해주세요.')),
                          );
                        }
                      },
                      child: const Text('설정 완료', style: TextStyle(fontSize: 16)),
                    ),
                  )
                else // 일반 모드일 때 기존 버튼들 표시
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        style: resetButtonStyle,
                        onPressed: onResetPressed,
                        child: const Text('초기화'),
                      ),
                      ElevatedButton(
                        style: saveButtonStyle,
                        onPressed: onSavePressed,
                        child: const Text('설정 저장'),
                      ),
                    ], // Add a trailing comma here
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}