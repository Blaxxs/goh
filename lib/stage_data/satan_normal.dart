// lib/stage_data/angel_hell.dart
import '../constants/drop_item_constants.dart';

// 지옥엔젤 스테이지의 고정된 기본 데이터
const Map<String, dynamic> satanNormalData = {
  'location': '시즌4-14-히든',              // 스테이지 위치 (고정)
  'baseClearRewardExp': 35000,   // 기본 클리어 보상 경험치 (고정)
  'baseClearRewardGold': 30000,        // 기본 클리어 보상 골드 (고정)
  'staminaCost': 20,                    // 루프당 소모 스테미너 (고정) - 예시값

 'drops': <DropInfo>[
    DropInfo(
      itemId: 'gold_demon_2star',
      category: DropCategory.goldDemon,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.60, // 60%
    ),
    DropInfo(
      itemId: 'raven_3star',
      category: DropCategory.minion,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 1.45, // 145%
    ),
    DropInfo(
      itemId: 'olympus_laurel_wreath',
      category: DropCategory.accessory,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.09, // 9%
    ),
  ],
};