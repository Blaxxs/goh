// lib/presentation/settings/settings_screen_ui.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../constants/vip_constants.dart';
import '../../constants/stage_constants.dart';
import '../../constants/monster_constants.dart';
import '../widgets/app_drawer.dart'; // 공통 Drawer 사용

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
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle saveButtonStyle = Theme.of(context).elevatedButtonTheme.style ?? ElevatedButton.styleFrom();
    final ButtonStyle resetButtonStyle = OutlinedButton.styleFrom(
       foregroundColor: Theme.of(context).colorScheme.error,
       side: BorderSide(color: Theme.of(context).colorScheme.error.withAlpha(150)),
    );
    const EdgeInsets inputContentPadding = EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0);
    final theme = Theme.of(context);
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    final TextStyle? titleStyle = appBarTheme.titleTextStyle;

    return Scaffold(
      drawer: const AppDrawer(currentScreen: AppScreen.settings),
      appBar: AppBar(
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
                      child: TextFormField(
                        controller: teamLevelController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '팀 레벨',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) { return '팀 레벨 입력'; }
                          if (int.tryParse(value) == null) { return '숫자만'; }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: dalgijiLevelController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '달기지 레벨',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) { return '달기지 레벨 입력'; }
                          if (int.tryParse(value) == null) { return '숫자만'; }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField2<String>(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        isExpanded: true,
                        buttonStyleData: ButtonStyleData(
                          height: 50,
                          padding: const EdgeInsets.only(left:10, right:10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor,
                          ),
                        ),
                        hint: Container(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, child: Text('VIP 등급', style: TextStyle(fontSize: 14, color: theme.hintColor), softWrap: false,))),
                        items: vipLevels.map((String item) {
                          return DropdownMenuItem<String>(value: item, child: Text(item, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)));
                        }).toList(),
                        value: selectedVipLevel,
                        onChanged: onVipLevelChanged,
                        validator: (value) {
                          if (value == null || value.isEmpty) { return 'VIP 선택'; }
                          return null;
                        },
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                          iconSize: 24,
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
                          return vipLevels.map((item) => Container(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(item, style: TextStyle(fontSize: 14, color: theme.textTheme.titleMedium?.color), softWrap: false)))).toList();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('스테이지별 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stageNameList.length,
                  itemBuilder: (context, index) {
                    final stageName = stageNameList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '$stageName:',
                                style: const TextStyle(fontSize: 17),
                                softWrap: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: clearTimeControllers[stageName],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                              ],
                              decoration: const InputDecoration(
                                hintText: '클리어 시간 (초)',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: inputContentPadding,
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final double? parsedValue = double.tryParse(value);
                                  if (parsedValue == null) { return '숫자'; }
                                  if (parsedValue <= 0) { return '> 0'; }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField2<String>(
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              isExpanded: true,
                              hint: Container(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, child: Text('쫄 선택', style: TextStyle(fontSize: 14, color: theme.hintColor), softWrap: false,))),
                              items: jjolCounts.map((String count) {
                                return DropdownMenuItem<String>(value: count, child: Text(count, style: const TextStyle(fontSize: 14)));
                              }).toList(),
                              value: selectedJjolCounts[stageName],
                              onChanged: (String? value) {
                                 onJjolCountChanged(stageName, value);
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 42,
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor,
                                ),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                                iconSize: 24,
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
                                  return jjolCounts.map((item) => Container(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(item, style: TextStyle(fontSize: 14, color: theme.textTheme.titleMedium?.color), softWrap: false)))).toList();
                                },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
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
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}