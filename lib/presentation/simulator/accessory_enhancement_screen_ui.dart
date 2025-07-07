// lib/presentation/simulator/ui/accessory_enhancement_screen_ui.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package
import '../../data/models/accessory.dart'; // Accessory model
import '../../core/widgets/app_drawer.dart'; // AppDrawer
import '../../core/constants/box_constants.dart'; // AppScreen enum을 위해 추가

class AccessoryEnhancementScreenUI extends StatelessWidget {
  final Accessory? selectedAccessory;
  final VoidCallback onSelectAccessoryPressed;
  final int currentEnhancementLevel;
  final ValueChanged<int?> onCurrentEnhancementLevelChanged;
  final int? targetEnhancementLevel;
  final ValueChanged<int?> onTargetEnhancementLevelChanged;
  final String selectedEnhancementAid;
  final List<String> enhancementAidOptions;
  final ValueChanged<String?> onEnhancementAidChanged;
  final bool isAutoEnhancing; // 자동 강화 실행 여부
  final bool isAutoEnhanceMode; // 자동 강화 모드 상태
  final ValueChanged<bool> onAutoEnhanceModeChanged; // 자동 강화 모드 변경 콜백
  final VoidCallback? onEnhanceButtonPressed; // 강화 버튼 콜백 추가
  final VoidCallback? onStopAutoEnhancePressed; // 자동 강화 중지 콜백
  // 강화 통계
  final int attemptCount;
  final int successCount;
  final int failKeepCount;
  final int failDowngradeCount;
  final int totalConsumedStones;
  final int totalConsumedGold;
  final VoidCallback onResetScreenPressed;
  final int selectedOptionCount;
  final ValueChanged<int?> onOptionCountChanged;
  final Map<String, int> consumedAidsCount;


  const AccessoryEnhancementScreenUI({
    super.key,
    this.selectedAccessory,
    required this.onSelectAccessoryPressed,
    required this.currentEnhancementLevel,
    required this.onCurrentEnhancementLevelChanged,
    required this.targetEnhancementLevel,
    required this.onTargetEnhancementLevelChanged,
    required this.selectedEnhancementAid,
    required this.enhancementAidOptions,
    required this.onEnhancementAidChanged,
    required this.isAutoEnhanceMode,
    required this.onAutoEnhanceModeChanged,
    required this.isAutoEnhancing,
    this.onEnhanceButtonPressed, // 생성자에 추가
    this.onStopAutoEnhancePressed,
    required this.attemptCount,
    required this.successCount,
    required this.failKeepCount,
    required this.failDowngradeCount,
    required this.totalConsumedStones,
    required this.totalConsumedGold,
    required this.onResetScreenPressed,
    required this.selectedOptionCount,
    required this.onOptionCountChanged,
    required this.consumedAidsCount,

  });

  // 강화 단계별 기본 확률: 성공, 실패(유지), 하락
  static const Map<int, Map<String, double>> baseEnhancementProbabilities = { // static으로 유지하되, private 해제하여 외부 참조 가능하도록
    // 현재레벨: {'success': 성공확률, 'fail_no_change': 유지확률, 'downgrade': 하락확률}
    0: {'success': 1.0,  'fail_no_change': 0.0,  'downgrade': 0.0},  // 0 -> 1
    1: {'success': 1.0,  'fail_no_change': 0.0,  'downgrade': 0.0},  // 1 -> 2
    2: {'success': 0.7,  'fail_no_change': 0.3,  'downgrade': 0.0},  // 2 -> 3
    3: {'success': 0.5,  'fail_no_change': 0.5,  'downgrade': 0.0},  // 3 -> 4
    4: {'success': 0.25, 'fail_no_change': 0.75, 'downgrade': 0.0},  // 4 -> 5
    5: {'success': 0.10, 'fail_no_change': 0.85, 'downgrade': 0.05}, // 5 -> 6
    6: {'success': 0.04, 'fail_no_change': 0.90, 'downgrade': 0.06}, // 6 -> 7
    7: {'success': 0.02, 'fail_no_change': 0.92, 'downgrade': 0.06}, // 7 -> 8
    8: {'success': 0.01, 'fail_no_change': 0.93, 'downgrade': 0.06}, // 8 -> 9
  };

  // 강화 보조제별 성공 확률 보너스
  static const Map<String, double> enhancementAidBonuses = { // static으로 유지하되, private 해제
    '선택 안함': 0.0, // 기본값
    '하급 보조제': 0.02,         // 성공확률 +2%
    '중급 보조제': 0.05,         // 성공확률 +5%
    '상급 보조제': 0.10,         // 성공확률 +10%
    '스페셜 하급 보조제': 0.10,    // 성공확률 +10%, 하락방지
    '스페셜 중급 보조제': 0.15,    // 성공확률 +15%, 하락방지
    '스페셜 상급 보조제': 0.20,    // 성공확률 +20%, 하락방지
    '스페셜 특급 보조제': 1.0,     // 성공확률 100% (특수처리), 하락방지
    // '일반 보조제', '고급 보조제'는 새로운 이름으로 대체되었으므로 제거 또는 주석 처리
  };

  // 옵션 1개 악세사리 강화 비용: {현재레벨: {'stones': 비용, 'gold': 비용}}
  static const Map<int, Map<String, int>> enhancementCostsOneOption = {
    0: {'stones': 10, 'gold': 5000},   // 0 -> 1
    1: {'stones': 10, 'gold': 5000},   // 1 -> 2
    2: {'stones': 10, 'gold': 10000},  // 2 -> 3
    3: {'stones': 20, 'gold': 15000},  // 3 -> 4
    4: {'stones': 30, 'gold': 20000},  // 4 -> 5
    5: {'stones': 40, 'gold': 25000},  // 5 -> 6
    6: {'stones': 50, 'gold': 30000},  // 6 -> 7
    7: {'stones': 70, 'gold': 35000},  // 7 -> 8
    8: {'stones': 90, 'gold': 40000},  // 8 -> 9
  };

  // 옵션 2개 이상 악세사리 강화 비용
  static const Map<int, Map<String, int>> enhancementCostsTwoPlusOptions = {
    0: {'stones': 20, 'gold': 5000},    // 0 -> 1
    1: {'stones': 30, 'gold': 5000},    // 1 -> 2
    2: {'stones': 40, 'gold': 10000},   // 2 -> 3
    3: {'stones': 50, 'gold': 15000},   // 3 -> 4
    4: {'stones': 80, 'gold': 20000},   // 4 -> 5
    5: {'stones': 110, 'gold': 25000},  // 5 -> 6
    6: {'stones': 150, 'gold': 30000},  // 6 -> 7
    7: {'stones': 200, 'gold': 35000},  // 7 -> 8
    8: {'stones': 270, 'gold': 40000},  // 8 -> 9
  };

  // Define aidImagesWithNames as a static const member
  static const String _baseAidImagePath = 'assets/images/enhancement_aids';
  static final List<Map<String, String>> _aidImageDetails = [
    {'name': '하급 보조제', 'path': '$_baseAidImagePath/low_grade_aid.png'},
    {'name': '중급 보조제', 'path': '$_baseAidImagePath/mid_grade_aid.png'},
    {'name': '상급 보조제', 'path': '$_baseAidImagePath/high_grade_aid.png'},
    {'name': '스페셜 하급 보조제', 'path': '$_baseAidImagePath/special_low_grade_aid.png'},
    {'name': '스페셜 중급 보조제', 'path': '$_baseAidImagePath/special_mid_grade_aid.png'},
    {'name': '스페셜 상급 보조제', 'path': '$_baseAidImagePath/special_high_grade_aid.png'},
    {'name': '스페셜 특급 보조제', 'path': '$_baseAidImagePath/special_super_grade_aid.png'},
  ];


  @override
  Widget build(BuildContext context) {
    // 디버깅: UI 위젯 빌드 시 전달받은 selectedAccessory 값 확인
    debugPrint("[AccessoryEnhancementScreenUI] Building. Received selectedAccessory: ${selectedAccessory?.name ?? 'None'}");

    final theme = Theme.of(context);
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    final TextStyle? titleStyle = appBarTheme.titleTextStyle;
    final bool isAccessorySelected = selectedAccessory != null;

    // 강화 버튼 활성화 조건 수정
    final bool canManuallyEnhance = !isAutoEnhancing && isAccessorySelected && currentEnhancementLevel < 9;
    final bool canStartAutoEnhance = isAutoEnhanceMode && !isAutoEnhancing && targetEnhancementLevel != null && currentEnhancementLevel < targetEnhancementLevel! && currentEnhancementLevel < 9;
    final bool canPressEnhanceButton = !isAutoEnhancing && onEnhanceButtonPressed != null &&
                                      isAccessorySelected && // 악세사리가 선택되어야 하고
                                      currentEnhancementLevel < 9 && // 현재 레벨이 9 미만이어야 하고
                                      (isAutoEnhanceMode ? canStartAutoEnhance : canManuallyEnhance); // 자동 모드 조건 또는 수동 모드 조건 만족

    // 현재 강화 단계의 기본 확률 가져오기
    final baseProbs = baseEnhancementProbabilities[currentEnhancementLevel] ??
        {'success': 0.0, 'fail_no_change': 0.0, 'downgrade': 0.0};
    final double baseSuccessChance = baseProbs['success']!;
    final double baseFailNoChangeChance = baseProbs['fail_no_change']!;
    final double baseDowngradeChance = baseProbs['downgrade']!;

    // 강화 보조제 효과 적용 로직 (AccessoryEnhancementScreen.dart의 _performEnhancement와 동일하게)
    final double aidBonusValue = enhancementAidBonuses[selectedEnhancementAid] ?? 0.0;
    bool isSpecialAidNoDowngrade = selectedEnhancementAid.startsWith('스페셜') && selectedEnhancementAid != '스페셜 특급 보조제';
    bool isSuperSpecialAid100Success = selectedEnhancementAid == '스페셜 특급 보조제';

    double finalSuccessChance;
    double finalFailNoChangeChance;
    double finalDowngradeChance;

    if (isSuperSpecialAid100Success) {
      finalSuccessChance = 1.0;
      finalFailNoChangeChance = 0.0;
      finalDowngradeChance = 0.0;
    } else {
      // 1. 보조제 기본 성공률 보너스 적용 (실패-유지 확률에서 차감)
      double bonusToApply = aidBonusValue;
      if (bonusToApply > baseFailNoChangeChance) {
        bonusToApply = baseFailNoChangeChance;
      }
      finalSuccessChance = baseSuccessChance + bonusToApply;
      finalFailNoChangeChance = baseFailNoChangeChance - bonusToApply;
      finalDowngradeChance = baseDowngradeChance;

      // 2. 스페셜 보조제의 "하락 방지" 효과 적용 (특급 제외)
      if (isSpecialAidNoDowngrade) {
        finalFailNoChangeChance += finalDowngradeChance;
        finalDowngradeChance = 0.0;
      }
    }

    // 확률 문자열 포맷팅
    final String successText = "${(finalSuccessChance * 100).toStringAsFixed(0)}%";
    final String failNoChangeText = "${(finalFailNoChangeChance * 100).toStringAsFixed(0)}%";
    final String downgradeText = "${(finalDowngradeChance * 100).toStringAsFixed(0)}%";


    // 목표 강화 단계 드롭다운 아이템 목록 생성
    List<DropdownMenuItem<int>> targetLevelItems = [];
    if (isAccessorySelected) {
      for (int i = currentEnhancementLevel + 1; i <= 9; i++) {
        targetLevelItems.add(DropdownMenuItem(value: i, child: Text('$i단계')));
      }
    }

    // 필요 재화 계산
    final costs = selectedOptionCount == 1
        ? enhancementCostsOneOption[currentEnhancementLevel]
        : enhancementCostsTwoPlusOptions[currentEnhancementLevel];
    final int stoneCost = (currentEnhancementLevel < 9 && costs != null) ? costs['stones']! : 0;
    final int goldCost = (currentEnhancementLevel < 9 && costs != null) ? costs['gold']! : 0;
    final formatter = NumberFormat('#,##0'); // 포맷터 추가

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '악세사리 강화', // 1. AppBar 제목 변경
          style: titleStyle?.copyWith(
            fontSize: (titleStyle.fontSize ?? 20), // Adjust size if needed
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '화면 초기화',
            onPressed: onResetScreenPressed,
          ),
        ],
      ),
      drawer: const AppDrawer(currentScreen: AppScreen.simulator),
      body: !isAccessorySelected
          ? Center( // 악세사리가 선택되지 않았을 때만 Center 사용
              child: GestureDetector( // 악세사리 미선택 시 선택 영역 - 이 GestureDetector는 유지합니다.
                  onTap: onSelectAccessoryPressed,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: theme.cardColor.withAlpha((0.5 * 255).round()),
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
                )) // "악세사리를 선택해 주세요" 영역 끝
            : Padding( // 악세사리 선택 시 전체 UI
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // 상세 내용 위에서부터 정렬
                  crossAxisAlignment: CrossAxisAlignment.center, // 가로축 중앙 정렬
                  children: [
                    // 악세사리 이름 및 옵션 갯수 선택
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline, // 세로 정렬을 baseline으로 변경하여 텍스트 기준 정렬
                      textBaseline: TextBaseline.alphabetic, // 텍스트 baseline 설정
                      children: [
                        Flexible( // 이름이 길 경우를 대비
                          child: Text(
                            selectedAccessory!.name, // 악세사리 이름
                            style: theme.textTheme.titleMedium, // 폰트 사이즈 더 줄임 (titleLarge -> titleMedium)
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 옵션 갯수 드롭다운 (이름 옆으로 이동)
                        DropdownButton<int>(
                          value: selectedOptionCount,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1옵')),
                            DropdownMenuItem(value: 2, child: Text('2옵+')),
                          ],
                          onChanged: onOptionCountChanged,
                          alignment: AlignmentDirectional.center,
                          style: theme.textTheme.bodyMedium, // 드롭다운 텍스트 스타일 조정
                          underline: Container(), // 기본 밑줄 제거 (선택 사항)
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // 이름과 이미지 사이 간격 조정 (16 -> 8)
                    // 3. 악세사리 이미지 (선택 영역으로도 동작)
                    GestureDetector(
                      onTap: onSelectAccessoryPressed,
                      child: SizedBox(
                        width: 100, // 이미지 크기 더 줄임 (120 -> 100)
                        height: 100, // 이미지 크기 더 줄임 (120 -> 100)
                        child: Image.asset(
                          selectedAccessory!.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image_outlined, size: 80, color: theme.hintColor);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // 이미지 아래 간격 조정 (24 -> 16)
                    // 현재 강화 단계 표시 및 조절 UI 변경
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_left_rounded),
                          iconSize: 36,
                          onPressed: currentEnhancementLevel > 0
                              ? () => onCurrentEnhancementLevelChanged(currentEnhancementLevel - 1)
                              : null,
                          tooltip: '강화 단계 감소',
                        ),
                        const SizedBox(width: 4),
                        // 별 표시
                        ...List.generate(9, (index) {
                            return Icon(
                              index < currentEnhancementLevel ? Icons.star_rounded : Icons.star_border_rounded,
                              color: index < currentEnhancementLevel ? Colors.amber : Colors.grey[400],
                              size: 30,
                            );
                          }),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.arrow_right_rounded),
                          iconSize: 36,
                          onPressed: currentEnhancementLevel < 9
                              ? () => onCurrentEnhancementLevelChanged(currentEnhancementLevel + 1)
                              : null,
                          tooltip: '강화 단계 증가',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // 강화 단계 표시 아래 간격 조정 (16 -> 8)

                    // 강화 확률 및 필요 재화 섹션 (Card로 묶음)
                    Card(
                      margin: EdgeInsets.zero, // 부모 Padding이 있으므로 Card 자체 마진은 0
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: theme.textTheme.titleMedium,
                                children: <TextSpan>[
                                  TextSpan(text: '성공: ', style: TextStyle(color: Colors.green[700])),
                                  TextSpan(text: successText, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
                                  const TextSpan(text: ' / '),
                                  TextSpan(text: '유지: ', style: TextStyle(color: Colors.orange[700])),
                                  TextSpan(text: failNoChangeText, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[700])),
                                  if (finalDowngradeChance > 0) ...[ // 하락 확률이 0보다 클 때만 표시
                                    const TextSpan(text: ' / '),
                                    TextSpan(text: '하락: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700])),
                                    TextSpan(text: downgradeText, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700])),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('필요 숫돌이: ${formatter.format(stoneCost)}', style: theme.textTheme.titleMedium),
                                Text('필요 골드: ${formatter.format(goldCost)}', style: theme.textTheme.titleMedium),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // 확률/재화 카드 아래 간격 조정 (24 -> 16)

                    // 강화 통계 표시
                    if (isAccessorySelected) ...[
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatisticItem(theme, '시도', attemptCount.toString(), suffix: '회'),
                                  _buildStatisticItem(theme, '성공', successCount.toString(), suffix: '회', valueColor: Colors.green[700]),
                                  _buildStatisticItem(theme, '유지', failKeepCount.toString(), suffix: '회', valueColor: Colors.orange[700]),
                                  _buildStatisticItem(theme, '하락', failDowngradeCount.toString(), suffix: '회', valueColor: Colors.red[700]),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text('누적 소모 재화', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('숫돌이: ${formatter.format(totalConsumedStones)}', style: theme.textTheme.bodyMedium),
                                  Text('골드: ${formatter.format(totalConsumedGold)}', style: theme.textTheme.bodyMedium),
                                  InkWell(
                                    onTap: () => _showConsumedAidsDialog(context, theme, consumedAidsCount),
                                    child: Text(
                                      '보조제: ${formatter.format(consumedAidsCount.values.fold(0, (sum, count) => sum + count))}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.secondary,
                                      )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // 통계 카드 아래 간격 조정 (24 -> 16)
                    ],

                    // 옵션 갯수 선택 UI는 악세사리 이름 옆으로 이동됨

                    // 자동 강화 스위치
                    if (isAccessorySelected) // 악세사리가 선택된 경우에만 표시
                      SwitchListTile( // 자동 강화 스위치
                        title: Text(
                          '자동 강화 모드',
                          style: theme.textTheme.titleMedium?.copyWith(color: isAutoEnhancing ? theme.disabledColor : null),
                        ),
                        value: isAutoEnhanceMode,
                        onChanged: isAutoEnhancing ? null : onAutoEnhanceModeChanged, // 강화 중에는 스위치 비활성화
                        secondary: Icon(isAutoEnhanceMode ? Icons.autorenew_rounded : Icons.play_arrow_rounded),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0), // 내부 패딩 조절
                      ),
                    if (isAccessorySelected) const SizedBox(height: 8), // 자동 강화 스위치 아래 간격 조정 (16 -> 8)

                    // 목표 강화 단계 (자동 강화 모드일 때만 표시) 및 강화 보조제 선택
                    Row( // 이 Row는 isAccessorySelected가 true일 때만 표시됨
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start, // DropdownButton 높이 다를 수 있으므로 상단 정렬
                      children: [
                        // Widget 1: 강화 보조제 (항상 왼쪽, 악세사리 선택 시)
                        if (isAccessorySelected)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center, // 문구와 아이콘을 중앙 정렬
                              children: [
                                Text('강화 보조제', style: theme.textTheme.titleSmall?.copyWith(color: theme.textTheme.bodySmall?.color)), // 레이블 복원
                                const SizedBox(height: 8), // 레이블과 아이콘 사이 간격
                                GestureDetector(
                                  onTap: () => _showEnhancementAidSelectionDialog(context, theme, onEnhancementAidChanged),
                                  child: _buildCurrentAidDisplay(theme), // Display + icon or large selected aid image
                                ),
                              ],
                            ), // 강화 보조제 Column 끝
                          ),

                        // 간격 (자동 강화 모드이고, 양쪽에 위젯이 있을 때만)
                        if (isAutoEnhanceMode) // isAccessorySelected는 이미 상위 Row에서 체크됨
                          const SizedBox(width: 16),

                        // Widget 2: 목표 강화 단계 (자동 강화 모드 ON 일 때) 또는 빈 공간 (자동 강화 모드 OFF 일 때)
                        if (isAccessorySelected) // 악세사리가 선택된 경우에만 두 번째 자식 영역을 그림
                          Expanded(
                            child: isAutoEnhanceMode
                                ? Column( // 자동 강화 ON: 목표 강화 단계
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('목표 강화 단계:', style: theme.textTheme.titleSmall),
                                      DropdownButton<int>(
                                        value: targetEnhancementLevel,
                                        hint: const Text('선택'),
                                        items: targetLevelItems.isEmpty && targetEnhancementLevel == null
                                            ? [const DropdownMenuItem(value: null, child: Text('선택'))]
                                            : targetLevelItems,
                                        onChanged: targetLevelItems.isEmpty ? null : onTargetEnhancementLevelChanged,
                                        isExpanded: true,
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(), // 자동 강화 OFF: 빈 공간 (Expanded가 빈 공간을 차지하지 않도록)
                          ),
                      ],
                    ),
                    const SizedBox(height: 24), // 강화 버튼 위 간격 조정 (32 -> 24)
                    // 9. 강화 버튼
                    isAutoEnhancing
                        ? ElevatedButton.icon( // 자동 강화 중일 때 "중지" 버튼
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: const Text('자동 강화 중지', style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: theme.colorScheme.onError,
                            ),
                            onPressed: onStopAutoEnhancePressed,
                          )
                        : ElevatedButton.icon( // 평상시 "강화" 또는 "자동 강화 시작" 버튼
                            icon: Icon(isAutoEnhanceMode ? Icons.autorenew_rounded : Icons.upgrade_rounded),
                            label: Text(isAutoEnhanceMode ? '자동 강화 시작' : '강화', style: const TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: canPressEnhanceButton ? onEnhanceButtonPressed : null,
                          ),
                    const SizedBox(height: 8), // 화면 하단 여백 조정 (16 -> 8)
                  ],
                ),
              ),
            ), // This was the missing closing parenthesis for Padding
      );
  } // build method ends here

  // Helper widget to display the current enhancement aid (either '+' icon or large image)
  Widget _buildCurrentAidDisplay(ThemeData theme) {
    if (selectedEnhancementAid == '선택 안함') {
      // "선택 안함"일 때: 원형 "+" 아이콘 표시 (크기 2/3로 줄임)
      final double iconContainerSize = 80 * (2 / 3); // 약 53.33
      final double iconSize = 40 * (2 / 3); // 약 26.66
      return Container(
        width: iconContainerSize,
        height: iconContainerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor,
          border: Border.all(color: theme.dividerColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          Icons.add_circle_outline_rounded,
          size: iconSize,
          color: theme.hintColor,
        ),
      );
    } else {
      // 보조제 선택 시: 선택된 보조제 이미지만 표시 (크기는 이전 요청대로 80x80)
      final String? imagePath = _getAidImagePath(selectedEnhancementAid);
      if (imagePath != null) {
        return Image.asset(
          imagePath,
          width: 80, 
          height: 80,
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, st) => const Icon(Icons.broken_image, size: 80), // Fallback for large image
        );
      }
      // Fallback if image path is somehow not found for a selected aid
      return SizedBox(width: 80, height: 80, child: Icon(Icons.help_outline, size: 40, color: theme.hintColor));
    }
  }

  // 통계 항목을 예쁘게 표시하기 위한 헬퍼 위젯
  Widget _buildStatisticItem(ThemeData theme, String label, String value, {String? suffix, Color? valueColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(color: theme.textTheme.bodySmall?.color),
        ),
        Text(
          '$value${suffix ?? ''}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  // Helper to get image path for a given aid name from _aidImageDetails
  static String? _getAidImagePath(String aidName) {
    final aidData = _aidImageDetails.firstWhere((aid) => aid['name'] == aidName, orElse: () => {'path': ''});
    return aidData['path']!.isNotEmpty ? aidData['path'] : null;
  }

  void _showEnhancementAidSelectionDialog(BuildContext context, ThemeData theme, ValueChanged<String?> onAidSelected) {
    Widget buildImageRow(List<Map<String, String>> imagesSublist) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: imagesSublist.map((imgMap) {
          return Expanded( // 이미지가 공간을 균등하게 차지하도록 Expanded 추가
            child: InkWell(
              onTap: () { // 변경: 전달받은 onAidSelected 콜백 사용
                onAidSelected(imgMap['name']!);
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0), // 이미지 간 간격
                child: Image.asset(
                  imgMap['path']!,
                  width: 120, // 보조제 선택창 이미지 크기 1.5배 (80*1.5 = 120)
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, st) => const Icon(Icons.broken_image, size: 70),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    List<Widget> imageRows = [];
    int itemsPerRow = 2; // Display 2 items per row
    for (int i = 0; i < _aidImageDetails.length; i += itemsPerRow) {
      int end = (i + itemsPerRow < _aidImageDetails.length) ? i + itemsPerRow : _aidImageDetails.length;
      List<Map<String, String>> sublist = _aidImageDetails.sublist(i, end);
      if (sublist.isNotEmpty) {
        imageRows.add(buildImageRow(sublist));
        if (end < _aidImageDetails.length) { // Add SizedBox if not the last row
          imageRows.add(const SizedBox(height: 12));
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('강화 보조제 선택', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16), // 패딩 조정
          content: SizedBox( // 다이얼로그 크기 제한
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...imageRows, // Use the generated list of rows
                  const SizedBox(height: 16),
                  const Divider(),
                  ListTile( // "선택 안함" 옵션 추가
                    title: const Text('선택 안함', textAlign: TextAlign.center),
                    onTap: () {
                      onAidSelected('선택 안함');
                      Navigator.of(dialogContext).pop();
                    },
                  )
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showConsumedAidsDialog(BuildContext context, ThemeData theme, Map<String, int> consumedCounts) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('소모된 강화 보조제', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.fromLTRB(8, 20, 8, 8), // 패딩 조정
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _aidImageDetails.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final aidDetail = _aidImageDetails[index];
                final String aidName = aidDetail['name']!;
                final String imagePath = aidDetail['path']!;
                final int count = consumedCounts[aidName] ?? 0;

                return ListTile(
                  leading: Image.asset(
                    imagePath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, st) => const Icon(Icons.broken_image, size: 30),
                  ),
                  title: Text(aidName, style: theme.textTheme.bodyMedium),
                  trailing: Text(
                    '$count개',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
} // AccessoryEnhancementScreenUI class ends here
