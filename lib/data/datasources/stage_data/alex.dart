// lib/stage_data/angel_hell.dart
import '../../../core/constants/drop_item_constants.dart';

// 지옥엔젤 스테이지의 고정된 기본 데이터
const Map<String, dynamic> alexData = {
  'location': '시즌3-15-히든',              // 스테이지 위치 (고정)
  'baseClearRewardExp': 32000,   // 기본 클리어 보상 경험치 (고정)
  'baseClearRewardGold': 33000,        // 기본 클리어 보상 골드 (고정)
  'staminaCost': 20,                    // 루프당 소모 스테미너 (고정) - 예시값
  'drops': <DropInfo>[
    DropInfo(
      itemId: 'gold_demon_3star', // monster_constants.dart의 몬스터 이름과 일치시킬 수 있습니다.
      category: DropCategory.goldDemon,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.50, // 50%
    ),
  ],
};