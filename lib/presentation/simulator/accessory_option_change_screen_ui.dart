// lib/presentation/simulator/ui/accessory_option_change_screen_ui.dart
import 'package:flutter/material.dart';
import '../../data/models/accessory.dart';
import 'package:intl/intl.dart'; // NumberFormat 사용을 위해 intl 임포트
import '../../core/widgets/app_drawer.dart';
import '../../core/constants/box_constants.dart'; // AppScreen enum을 위해 추가
// Import the screen to get the enum

import 'accessory_option_change_screen.dart';

class AccessoryOptionChangeScreenUI extends StatelessWidget {
  static final NumberFormat _formatter = NumberFormat('#,##0'); // 숫자 포맷터
  final Accessory? selectedAccessory;
  final List<AccessoryOption> currentOptions;
  final OptionChangeAction selectedAction;
  final VoidCallback onSelectAccessoryPressed;
  final VoidCallback onResetScreenPressed;
  final ValueChanged<OptionChangeAction> onActionSelected;
  final int totalSoulStonesConsumed;
  final int totalGrindstonesConsumed;
  final int totalRainbowAnvilsConsumed;
  final int total9EnhanceAccessoriesConsumed;


  const AccessoryOptionChangeScreenUI({
    super.key,
    required this.selectedAccessory,
    required this.currentOptions,
    required this.selectedAction,
    required this.onSelectAccessoryPressed,
    required this.onResetScreenPressed,
    required this.onActionSelected,
    required this.totalSoulStonesConsumed,
    required this.totalGrindstonesConsumed,
    required this.totalRainbowAnvilsConsumed,
    required this.total9EnhanceAccessoriesConsumed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isAccessorySelected = selectedAccessory != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('악세사리 옵션 변경'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '화면 초기화',
            onPressed: onResetScreenPressed,
          ),
        ],
      ),
      drawer: const AppDrawer(currentScreen: AppScreen.simulator),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Selected Accessory Info
            if (isAccessorySelected)
              _buildAccessoryInfo(context, theme)
            else
              _buildAccessoryPicker(context, theme),

            const SizedBox(height: 24),

            // Section 2: Options
            if (isAccessorySelected) ...[ // Only show if accessory is selected
              Text('현재 옵션', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _OptionsListWidget( // Use the new stateful widget
                selectedAccessory: selectedAccessory!,
                currentOptions: currentOptions,
                selectedAction: selectedAction,
                onActionSelected: onActionSelected,
              ),
            ],

            const SizedBox(height: 24),

            // Section 3: Cost and Action Button
            if (isAccessorySelected) ...[ // This block remains, only the button inside is removed
              Text('변경 비용', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), // Moved title outside Card
              const SizedBox(height: 8), // Spacing between title and card
              _buildCostInfo(context, theme), // This now only builds the cost content
              const SizedBox(height: 24),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildAccessoryPicker(BuildContext context, ThemeData theme) {
    return Center(
      child: GestureDetector(
        onTap: onSelectAccessoryPressed,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: theme.cardColor.withAlpha(128),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '악세사리를 선택해 주세요',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessoryInfo(BuildContext context, ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              selectedAccessory!.name,
              style: theme.textTheme.titleMedium, // Reduced font size for accessory name
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8), // Reduced spacing
            GestureDetector(
              onTap: onSelectAccessoryPressed,
              child: SizedBox(
                width: 100, // Reduced image size
                height: 100, // Reduced image size
                child: Image.asset(
                  selectedAccessory!.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image_outlined, size: 80, color: theme.hintColor);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCostInfo(BuildContext context, ThemeData theme) {
    List<Widget> costWidgets = [];

    if (totalSoulStonesConsumed > 0) {
      costWidgets.add(Text('영혼석: ${_formatter.format(totalSoulStonesConsumed)}개', style: theme.textTheme.bodyLarge, textAlign: TextAlign.center));
    }
    if (totalGrindstonesConsumed > 0) {
      costWidgets.add(Text('숫돌이: ${_formatter.format(totalGrindstonesConsumed)}개', style: theme.textTheme.bodyLarge, textAlign: TextAlign.center));
    }
    if (totalRainbowAnvilsConsumed > 0) {
      costWidgets.add(Text('무지개 모루: ${_formatter.format(totalRainbowAnvilsConsumed)}개', style: theme.textTheme.bodyLarge, textAlign: TextAlign.center));
    }
    if (total9EnhanceAccessoriesConsumed > 0) {
      costWidgets.add(Text('3옵 9강 악세: ${_formatter.format(total9EnhanceAccessoriesConsumed)}개', style: theme.textTheme.bodyLarge, textAlign: TextAlign.center));
    }

    if (costWidgets.isEmpty) {
      costWidgets.add(Text('아직 소모된 재화가 없습니다.', style: theme.textTheme.bodyLarge, textAlign: TextAlign.center));
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap( // 여러 재화가 있을 경우 줄바꿈 처리
                    alignment: WrapAlignment.center,
                    spacing: 16.0, // 아이템 간 가로 간격
                    runSpacing: 8.0, // 줄 간 세로 간격
                    children: costWidgets,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionsListWidget extends StatefulWidget {
  final Accessory selectedAccessory;
  final List<AccessoryOption> currentOptions;
  final OptionChangeAction selectedAction;
  final ValueChanged<OptionChangeAction> onActionSelected;

  const _OptionsListWidget({
    required this.selectedAccessory,
    required this.currentOptions,
    required this.selectedAction,
    required this.onActionSelected,
  });

  @override
  State<_OptionsListWidget> createState() => _OptionsListWidgetState();
}

class _OptionsListWidgetState extends State<_OptionsListWidget> {
  // Helper to build a single option row
  Widget _buildOptionRow(ThemeData theme, {
    required String slot,
    required String optionName,
    String? optionValue,
    Widget? actionButton, // Now optional
    Color? optionTextColor, // 옵션 텍스트 색상
    VoidCallback? onTapOptionArea, // New: callback for tapping the option area
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(slot, style: theme.textTheme.titleMedium)),
          Expanded(
            child: InkWell( // Wrap with InkWell for tap functionality
              onTap: onTapOptionArea,
              borderRadius: BorderRadius.circular(4.0), // Optional: for visual feedback
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Add padding for tap area
                child: Row( // Use a Row to separate name and value, now with dynamic spacing
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Name left, Value right
                        children: [
                          Expanded(
                            // No flex needed, it will expand to fill remaining space
                            child: Text(
                              optionName,
                              style: theme.textTheme.bodyLarge?.copyWith(color: optionTextColor),
                              softWrap: true, // 줄바꿈 허용
                            ),
                          ),
                          if (optionValue != null && optionValue.isNotEmpty)
                            Text( // Option value takes only its content width
                                optionValue,
                                style: theme.textTheme.bodyLarge?.copyWith(color: optionTextColor),
                                textAlign: TextAlign.right,
                                softWrap: true, // 줄바꿈 허용
                              ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (actionButton != null) actionButton, // Only show if actionButton is provided
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int currentOptionCount = widget.currentOptions.length;
    List<Widget> optionWidgets = [];

    for (int i = 0; i < 4; i++) {
      final String slotText = '${i + 1}옵:';
      Widget? actionButton; // Optional action button
      Color? optionTextColor;
      String optionName;
      String? optionValue;
      VoidCallback? onTapOptionArea;

      if (i < currentOptionCount) {
        // Option exists
        final option = widget.currentOptions[i];
        optionName = option.optionName;
        optionValue = option.optionValue;
        optionTextColor = theme.textTheme.bodyLarge?.color;
        
        // Determine if this slot is a base option slot from the original accessory
        final bool isBaseOptionSlot = i < widget.selectedAccessory.options.length;

        if (isBaseOptionSlot) {
          // This is a base option slot (1st, 2nd, or 3rd if accessory has 3 base options)
          final baseOption = widget.selectedAccessory.options[i];
          optionName = baseOption.optionName;
          optionValue = baseOption.optionValue;
          optionTextColor = Colors.grey; // Base options are greyed out and fixed
          onTapOptionArea = null; // Cannot tap to change/expand base options
        } else { // This slot is not a base option slot, but it currently has an option (meaning it was expanded/changed)
          optionName = option.optionName;
          optionValue = option.optionValue;
          optionTextColor = theme.textTheme.bodyLarge?.color; // Regular color for changeable options

          // Set tap area for changing (only for 3rd and 4th slots)
          if (i == 2) { // 3rd option (expanded from 2-op accessory)
            onTapOptionArea = () => widget.onActionSelected(OptionChangeAction.changeThird);
          } else if (i == 3) { // 4th option
            onTapOptionArea = () => widget.onActionSelected(OptionChangeAction.changeFourth);
          }
        }
      } else { // This slot is not a base option slot and is currently empty (meaning it's expandable)
        optionName = '비어있음'; // Default for empty slots
        optionValue = null;
        optionTextColor = theme.hintColor;

        if (i == 2) { // Expanding to 3rd option
          if (widget.selectedAccessory.options.length < 3) {
            onTapOptionArea = () => widget.onActionSelected(OptionChangeAction.expandToThird);
          }
        } else if (i == 3) { // Expanding to 4th option
          // Can only expand to 4th if 3rd option exists (currentOptions.length >= 3)
          if (currentOptionCount >= 3) {
            onTapOptionArea = () => widget.onActionSelected(OptionChangeAction.expandToFourth);
          }
        }
      }
      optionWidgets.add(_buildOptionRow(
        theme,
        slot: slotText,
        optionName: optionName,
        optionValue: optionValue,
        actionButton: actionButton,
        optionTextColor: optionTextColor,
        onTapOptionArea: onTapOptionArea,
      ));
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: optionWidgets,
        ),
      ),
    );
  }
}
