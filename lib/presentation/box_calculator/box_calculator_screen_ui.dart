// lib/presentation/box_calculator/box_calculator_screen_ui.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/app_drawer.dart';
import '../../domain/logic/box_calculator_logic.dart'; // ExpectedValueResult, CalculationOutput을 위해 필요
import '../../core/constants/box_constants.dart'; // AppScreen 및 상자 이름 상수들을 위해 필요

// 이미지 경로 상수 정의
const String _baseImagePath = 'assets/images/boxes';
const String _normalBoxImage = '$_baseImagePath/normal_box.png';
const String _rareBoxImage = '$_baseImagePath/rare_box.png';
const String _legendaryBoxImage = '$_baseImagePath/legendary_box.png';
class BoxCalculatorScreenUI extends StatelessWidget {
  final TextEditingController normalBoxCountController;
  final TextEditingController rareBoxCountController;
  final TextEditingController legendaryBoxCountController;
  final List<ExpectedValueResult> results;
  final int totalGoldCost;
  final VoidCallback onCalculatePressed;

  const BoxCalculatorScreenUI({
    super.key,
    required this.normalBoxCountController,
    required this.rareBoxCountController,
    required this.legendaryBoxCountController,
    required this.results,
    required this.totalGoldCost,
    required this.onCalculatePressed,
  });

  // Modified: Removed 'label' parameter, changed labelText to hintText
  Widget _buildBoxCountInput(BuildContext context, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0), // 행 높이 25% 감소
        hintText: '개수 입력', // 3. Shorter hint text for a more compact field
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
    );
  }

  // New helper method to build each box input row
  Widget _buildBoxInputRow(BuildContext context, String boxName, String imagePath, TextEditingController controller) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          boxName,
          style: textTheme.titleMedium,
          textAlign: TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(), // 상자 이름과 이미지 사이의 여백
        Image.asset(imagePath, width: 40, height: 40),
        const Spacer(), // 이미지와 입력칸 사이의 여백
        SizedBox(
          width: 150.0, // 입력창 너비 25% 증가 (120 -> 150)
          child: _buildBoxCountInput(context, controller), // Call the modified input field builder
        ),
        const Spacer(), // 입력칸과 '개' 단위 사이의 여백
        Text('개', style: textTheme.titleMedium),
      ],
    );
  }

  // 특정 아이템에 강조색을 반환하는 헬퍼 메서드
  // 다크/라이트 모드에 따라 다른 색상(혹은 null)을 반환
  Color? _getHighlightColor(String itemName, {required bool isDarkMode}) {
    if (isDarkMode) {
      // 다크 모드: 텍스트 색상 반환
      switch (itemName) {
        case '금코인':
          return Colors.yellow.shade400;
        case '은코인':
          return Colors.grey.shade500;
        case '조커 조각(120개 = 1조커)':
          return Colors.purple.shade300;
        case '스피릿 조커 선택권 조각':
          return Colors.lightGreen.shade300;
        case '영혼석':
          return Colors.cyan.shade300;
        case '무지개모루 조각(100개 = 1무지개모루)':
          return Colors.orange.shade300;
        case '콜라보 석판':
          return Colors.red.shade300;
        default:
          return null;
      }
    } else {
      // 라이트 모드: 배경색 반환
      switch (itemName) {
        case '금코인':
          return Colors.yellow[100];
        case '은코인':
          return Colors.grey[200];
        case '조커 조각(120개 = 1조커)':
          return Colors.purple[100];
        case '스피릿 조커 선택권 조각':
          return Colors.lightGreen[100];
        case '영혼석':
          return Colors.cyan[100];
        case '무지개모루 조각(100개 = 1무지개모루)':
          return Colors.orange[100];
        case '콜라보 석판':
          return Colors.red[100];
        default:
          return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final NumberFormat integerFormatter = NumberFormat('#,##0');
    final NumberFormat formatter = NumberFormat('#,##0.##');
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(currentScreen: AppScreen.boxCalculator), // 이제 AppScreen은 box_constants.dart에서 직접 가져옵니다.
      appBar: AppBar(
        title: const Text('상자 기대값 계산기'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 화면 다른 곳 터치 시 키보드 숨기기
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column( // Column의 crossAxisAlignment는 stretch로 유지하여 ElevatedButton 등이 전체 너비를 차지하도록 함
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              Text(
                '콜라보 던전 상자 기대값 계산기',
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: (textTheme.headlineSmall?.fontSize ?? 24.0) * 0.85,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Replaced with new helper method for Normal Box
              _buildBoxInputRow(context, normalBox, _normalBoxImage, normalBoxCountController),
              const SizedBox(height: 8),
              // Replaced with new helper method for Rare Box
              _buildBoxInputRow(context, rareBox, _rareBoxImage, rareBoxCountController),
              const SizedBox(height: 8),
              // Replaced with new helper method for Legendary Box
              _buildBoxInputRow(context, legendaryBox, _legendaryBoxImage, legendaryBoxCountController),
              const SizedBox(height: 16),
              Text(
                '상자 오픈 필요 골드: ${integerFormatter.format(totalGoldCost)}',
                style: textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error, // 강조색을 빨간색 계열로 변경
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onCalculatePressed,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('기대값 계산'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                '보상 기대값',
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              results.isEmpty && totalGoldCost == 0
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('상자 개수를 입력하고 계산 버튼을 눌러주세요.'),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: results.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final result = results[index];
                        final highlightColor = _getHighlightColor(result.itemName, isDarkMode: isDarkMode);

                        // 보상 목록의 폰트 스타일 정의 (기존 대비 20% 감소)
                        final baseResultTextStyle = textTheme.titleMedium?.copyWith(
                          fontSize: (textTheme.titleMedium?.fontSize ?? 16.0) * 0.8,
                        );

                        TextStyle? titleStyle = baseResultTextStyle;
                        TextStyle? trailingStyle = baseResultTextStyle?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        );

                        // 다크모드이고 하이라이트가 필요한 경우, 텍스트에 테두리 효과 추가
                        if (isDarkMode && highlightColor != null) {
                          const textOutline = [
                            Shadow(offset: Offset(-1, -1), color: Colors.black),
                            Shadow(offset: Offset(1, -1), color: Colors.black),
                            Shadow(offset: Offset(1, 1), color: Colors.black),
                            Shadow(offset: Offset(-1, 1), color: Colors.black),
                          ];
                          titleStyle = baseResultTextStyle?.copyWith(color: highlightColor, shadows: textOutline);
                          trailingStyle = trailingStyle?.copyWith(color: highlightColor, shadows: textOutline);
                        }

                        return ListTile(
                          dense: true, // 목록 높이 25% 감소
                          // 라이트 모드일 때만 배경색 적용
                          tileColor: !isDarkMode ? highlightColor : null,
                          title: Text(
                            result.itemName,
                            style: titleStyle,
                          ),
                          trailing: Text(
                            formatter.format(result.expectedValue),
                            style: trailingStyle,
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}