// lib/presentation/simulator/accessory_enhancement_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // Random 사용
import '../../data/models/accessory.dart'; // Accessory model
import '../../core/constants/accessory_constants.dart'; // AccessoryDataManager().allAccessories 사용
import 'accessory_enhancement_screen_ui.dart';

const _autoEnhanceBatchSize = 15;

class AccessoryEnhancementScreen extends StatefulWidget {
  const AccessoryEnhancementScreen({super.key});

  @override
  State<AccessoryEnhancementScreen> createState() =>
      _AccessoryEnhancementScreenState();
}

class _AccessoryEnhancementScreenState
    extends State<AccessoryEnhancementScreen> {
  Accessory? _selectedAccessory;
  int _currentEnhancementLevel = 0;
  int? _targetEnhancementLevel; // 목표 등급은 현재 등급보다 높아야 하므로 nullable
  bool _isAutoEnhancing = false; // 자동 강화가 '실행 중'인지 여부
  bool _isAutoEnhanceMode = false; // 자동 강화 모드 상태
  String _selectedEnhancementAid = '선택 안함'; // 강화 보조제
  int _selectedOptionCount = 2; // 옵션 갯수 (기본값 2개 이상)
  int _totalConsumedStones = 0;
  int _totalConsumedGold = 0;

  // 강화 통계 변수
  int _attemptCount = 0;
  int _successCount = 0;
  int _failKeepCount = 0;
  int _failDowngradeCount = 0;
  final Map<String, int> _consumedAidsCount = {};
  // UI 파일의 _enhancementAidBonuses 키와 일치해야 합니다.
  final List<String> _enhancementAids = [
    '선택 안함',
    '하급 보조제',
    '중급 보조제',
    '상급 보조제',
    '스페셜 하급 보조제',
    '스페셜 중급 보조제',
    '스페셜 상급 보조제',
    '스페셜 특급 보조제',
  ];

  @override
  void initState() {
    super.initState();
    _resetScreenState(); // 최초 진입 시 화면 전체 초기화 (랜덤 악세사리 선택 포함)
  }

  void _selectAccessory(BuildContext context) {
    final allAccessories = AccessoryDataManager().allAccessories;
    if (allAccessories.isEmpty) return;

    final parts = allAccessories.map((a) => a.part).toSet().toList()..sort();
    String? selectedPart;
    String searchQuery = '';

    showModalBottomSheet<Accessory>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filtered = allAccessories.where((a) {
              final matchesPart =
                  selectedPart == null || a.part == selectedPart;
              final matchesSearch = searchQuery.isEmpty ||
                  a.name.toLowerCase().contains(searchQuery.toLowerCase());
              return matchesPart && matchesSearch;
            }).toList()
              ..sort((a, b) => a.name.compareTo(b.name));

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              minChildSize: 0.4,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            '악세사리 선택',
                            style: Theme.of(ctx)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    // 검색 + 부위 필터 칩 (인라인)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  FilterChip(
                                    label: const Text('전체'),
                                    showCheckmark: false,
                                    selected: selectedPart == null,
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onSelected: (_) => setSheetState(
                                        () => selectedPart = null),
                                  ),
                                  const SizedBox(width: 6),
                                  ...parts.map((p) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: FilterChip(
                                          label: Text(p),
                                          showCheckmark: false,
                                          selected: selectedPart == p,
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          onSelected: (_) => setSheetState(() =>
                                              selectedPart =
                                                  selectedPart == p ? null : p),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 96,
                            child: SearchTextField(
                              hintText: '검색',
                              onChanged: (v) =>
                                  setSheetState(() => searchQuery = v),
                              onSubmitted: (v) =>
                                  setSheetState(() => searchQuery = v.trim()),
                              textInputAction: TextInputAction.search,
                              prefixIcon: Icons.search,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              width: 96,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 8),
                    // 그리드
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('검색 결과가 없습니다.'))
                          : GridView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 90,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (_, index) {
                                final acc = filtered[index];
                                final isCurrent =
                                    _selectedAccessory?.id == acc.id;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(sheetContext);
                                    if (mounted) {
                                      setState(() {
                                        _selectedAccessory = acc;
                                        _resetForNewAccessorySelection();
                                      });
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isCurrent
                                                ? Theme.of(ctx)
                                                    .colorScheme
                                                    .primary
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: CachedNetworkImage(
                                            imageUrl: acc.imageUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) =>
                                                const SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 1.5)),
                                            ),
                                            errorWidget: (_, __, ___) =>
                                                const SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Icon(Icons
                                                  .image_not_supported_outlined),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        acc.name,
                                        style:
                                            Theme.of(ctx).textTheme.labelSmall,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // 통계 초기화 함수
  void _resetStatistics() {
    if (!mounted) return;
    setState(() {
      _attemptCount = 0;
      _successCount = 0;
      _failKeepCount = 0;
      _failDowngradeCount = 0;
      _isAutoEnhancing = false;
      _totalConsumedStones = 0; // 누적 소모 숫돌이 초기화
      _totalConsumedGold = 0; // 누적 소모 골드 초기화
      _consumedAidsCount.clear();
    });
  }

  // 화면 전체를 초기 상태로 리셋하는 함수 (랜덤 악세사리 선택 포함)
  void _resetScreenState() {
    if (!mounted) return;
    setState(() {
      if (AccessoryDataManager().allAccessories.isNotEmpty) {
        final randomIndex =
            Random().nextInt(AccessoryDataManager().allAccessories.length);
        _selectedAccessory = AccessoryDataManager().allAccessories[randomIndex];
      } else {
        _selectedAccessory = null;
      }
      _resetForNewAccessorySelection(); // 나머지 상태 초기화
    });
  }

  // 새 악세사리 선택 또는 전체 리셋 시 공통으로 사용될 상태 초기화
  void _resetForNewAccessorySelection() {
    _currentEnhancementLevel = 0;
    _targetEnhancementLevel = null;
    _isAutoEnhancing = false;
    _isAutoEnhanceMode = false;
    _selectedEnhancementAid = '선택 안함';
    _selectedOptionCount = 2; // 옵션 갯수 기본값을 2로 변경
    _resetStatistics(); // 모든 카운트 및 누적 재화 초기화
  }

  // 강화 로직을 수행하는 함수
  Future<void> _handleEnhanceButtonPressed() async {
    if (_isAutoEnhanceMode) {
      // 자동 강화 시작
      setState(() => _isAutoEnhancing = true);
      await _performEnhancementLoop();
      // 루프가 끝나면 (목표 달성, 중지 등) 상태를 리셋합니다.
      if (mounted) {
        setState(() {
          _isAutoEnhancing = false;
          _isAutoEnhanceMode = false; // 스위치도 끄기
        });
      }
    } else {
      // 단일 강화
      _performSingleEnhancement();
    }
  }

  // 단일 강화 시도 로직
  void _performSingleEnhancement() {
    if (_selectedAccessory == null || _currentEnhancementLevel >= 9) {
      return;
    }

    // 현재 강화 시도의 비용 가져오기
    final costs = _selectedOptionCount == 1
        ? AccessoryEnhancementScreenUI
            .enhancementCostsOneOption[_currentEnhancementLevel]
        : AccessoryEnhancementScreenUI
            .enhancementCostsTwoPlusOptions[_currentEnhancementLevel];

    // UI에서 확률 가져오기 (실제로는 UI의 static const를 직접 참조하거나, 별도 로직 클래스로 분리)
    final baseProbs = AccessoryEnhancementScreenUI
            .baseEnhancementProbabilities[_currentEnhancementLevel] ??
        {'success': 0.0, 'fail_no_change': 0.0, 'downgrade': 0.0};
    final double baseSuccess = baseProbs['success']!;
    final double baseFailNoChange = baseProbs['fail_no_change']!;
    final double baseDowngrade = baseProbs['downgrade']!;

    final double aidBonusValue = AccessoryEnhancementScreenUI
            .enhancementAidBonuses[_selectedEnhancementAid] ??
        0.0;
    bool isSpecialAidNoDowngrade = _selectedEnhancementAid.startsWith('스페셜') &&
        _selectedEnhancementAid != '스페셜 특급 보조제';
    bool isSuperSpecialAid100Success = _selectedEnhancementAid == '스페셜 특급 보조제';

    double finalSuccessChance;
    double finalDowngradeChance;

    if (isSuperSpecialAid100Success) {
      finalSuccessChance = 1.0;
      finalDowngradeChance = 0.0;
    } else {
      // 1. 보조제 기본 성공률 보너스 적용 (실패-유지 확률에서 차감)
      double bonusToApply = aidBonusValue;
      if (bonusToApply > baseFailNoChange) {
        bonusToApply = baseFailNoChange;
      }
      finalSuccessChance = baseSuccess + bonusToApply;
      finalDowngradeChance = baseDowngrade; // 하락 확률은 기본값 유지

      // 2. 스페셜 보조제의 "하락 방지" 효과 적용 (특급 제외)
      if (isSpecialAidNoDowngrade) {
        // 하락 확률을 실패-유지 확률로 전환
        finalDowngradeChance = 0.0;
      }
    }

    final int stoneCost = costs?['stones'] ?? 0;
    final int goldCost = costs?['gold'] ?? 0;

    // 상태 업데이트를 setState 블록으로 그룹화
    if (!mounted) return;
    setState(() {
      // 보조제 소모 기록 (실제 강화 시도 전에)
      if (_selectedEnhancementAid != '선택 안함') {
        if (mounted) {
          setState(() {
            _consumedAidsCount[_selectedEnhancementAid] =
                (_consumedAidsCount[_selectedEnhancementAid] ?? 0) + 1;
          });
        }
      }
      _totalConsumedStones += stoneCost;
      _totalConsumedGold += goldCost;
      _attemptCount++;
      final randomValue = Random().nextDouble();
      // String resultMessage; // 강화 결과 알림 제거로 인해 사용되지 않음
      // int previousLevel = _currentEnhancementLevel; // 강화 결과 알림 제거로 인해 사용되지 않음

      if (randomValue < finalSuccessChance) {
        // 성공
        if (mounted) {
          setState(() {
            _currentEnhancementLevel++;
            _successCount++;
          });
        }
        // resultMessage = '${_selectedAccessory!.name} 강화 성공! (${_currentEnhancementLevel - 1}강 -> $_currentEnhancementLevel강)'; // 이전 레벨을 직접 계산하거나, 필요시 previousLevel 다시 사용
      } else if (randomValue < finalSuccessChance + finalDowngradeChance) {
        // 하락 (하락 확률이 0이 아닌 경우)
        if (mounted) {
          setState(() {
            _failDowngradeCount++;
            _currentEnhancementLevel =
                max(0, _currentEnhancementLevel - 1); // 0강 밑으로 내려가지 않도록
          });
        }
        // resultMessage = '${_selectedAccessory!.name} 강화 실패... 단계 하락. (${_currentEnhancementLevel + 1}강 -> $_currentEnhancementLevel강)'; // 이전 레벨을 직접 계산하거나, 필요시 previousLevel 다시 사용
        // 자동 강화 중지 조건은 아래에서 공통으로 처리
      } else {
        // 유지
        if (mounted) {
          setState(() {
            _failKeepCount++;
          });
        }
        // resultMessage = '${_selectedAccessory!.name} 강화 실패. 단계 유지. ($_currentEnhancementLevel강)';
        // 자동 강화 중지 조건은 아래에서 공통으로 처리
      }
    });
  }

  // 자동 강화 루프
  Future<void> _performEnhancementLoop() async {
    while (_isAutoEnhancing && mounted) {
      bool reachedTarget = false;
      for (int i = 0; i < _autoEnhanceBatchSize; i++) {
        if (!_isAutoEnhancing || !mounted) {
          break;
        }
        _performSingleEnhancement();

        // 목표 달성 또는 최대 강화 도달 시 자동 강화 중지
        if (_currentEnhancementLevel >= 9 ||
            (_targetEnhancementLevel != null &&
                _currentEnhancementLevel >= _targetEnhancementLevel!)) {
          reachedTarget = true;
          break;
        }
      }
      if (reachedTarget) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('자동 강화가 완료되었습니다.'),
                duration: Duration(seconds: 2)),
          );
        }
        break; // 루프 종료
      }

      await Future.delayed(const Duration(milliseconds: 1)); // 다음 강화 시도 전 짧은 지연
    }
    // 루프가 끝나면 (중지 버튼, 목표 달성 등) isAutoEnhancing 상태를 false로 변경
    if (mounted) {
      setState(() => _isAutoEnhancing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 디버깅: UI 빌드 시 선택된 악세사리 상태 출력
    debugPrint(
        "[AccessoryEnhancementScreen] Building UI. Selected Accessory: ${_selectedAccessory?.name ?? 'None'}");

    return AccessoryEnhancementScreenUI(
      selectedAccessory: _selectedAccessory,
      onSelectAccessoryPressed: () => _selectAccessory(context),
      currentEnhancementLevel: _currentEnhancementLevel,
      onCurrentEnhancementLevelChanged: (int? newValue) {
        if (newValue != null && mounted) {
          setState(() {
            _currentEnhancementLevel = newValue;
            // 현재 강화 단계가 변경되면 목표 강화 단계도 유효한지 확인하고 조정
            if (_targetEnhancementLevel != null &&
                _targetEnhancementLevel! <= _currentEnhancementLevel) {
              _targetEnhancementLevel =
                  null; // 또는 _currentEnhancementLevel + 1로 설정
            }
          });
        }
      },
      targetEnhancementLevel: _targetEnhancementLevel,
      onTargetEnhancementLevelChanged: (int? newValue) {
        if (mounted) {
          // newValue가 null일 수도 있음 (선택 해제)
          setState(() {
            _targetEnhancementLevel = newValue;
          });
        }
      },
      selectedEnhancementAid: _selectedEnhancementAid,
      enhancementAidOptions: _enhancementAids,
      onEnhancementAidChanged: (String? newValue) {
        if (newValue != null && mounted) {
          setState(() {
            _selectedEnhancementAid = newValue;
          });
        }
      },
      isAutoEnhanceMode: _isAutoEnhanceMode,
      onAutoEnhanceModeChanged: (bool value) {
        if (mounted) {
          setState(() {
            if (_isAutoEnhancing) return; // 강화 중에는 스위치 조작 방지
            _isAutoEnhanceMode = value;
            if (!value) {
              // 자동 강화 모드가 꺼지면 목표 레벨도 초기화 (선택적)
              _targetEnhancementLevel = null;
            } else {
              // 자동 강화 모드 켰을 때, 목표 레벨이 현재 레벨보다 낮거나 같으면 초기화
              if (_targetEnhancementLevel != null &&
                  _targetEnhancementLevel! <= _currentEnhancementLevel) {
                _targetEnhancementLevel = null;
              }
            }
          });
        }
      },
      isAutoEnhancing: _isAutoEnhancing,
      onEnhanceButtonPressed: _handleEnhanceButtonPressed, // 강화 실행 함수 연결
      onStopAutoEnhancePressed: () {
        // 중지 콜백
        if (mounted) {
          setState(() {
            _isAutoEnhancing = false;
            _isAutoEnhanceMode = false;
          });
        }
      },
      attemptCount: _attemptCount,
      successCount: _successCount,
      failKeepCount: _failKeepCount,
      failDowngradeCount: _failDowngradeCount,
      consumedAidsCount: _consumedAidsCount,
      totalConsumedStones: _totalConsumedStones,
      totalConsumedGold: _totalConsumedGold,
      onResetScreenPressed: _resetScreenState, // 리셋 콜백 전달
      selectedOptionCount: _selectedOptionCount,
      onOptionCountChanged: (int? newValue) {
        if (newValue != null && mounted) {
          setState(() {
            _selectedOptionCount = newValue;
          });
        }
      },
    );
  }
}
