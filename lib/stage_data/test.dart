// lib/stage_data/test.dart
import '../constants/drop_item_constants.dart';

// 지옥엔젤 스테이지의 고정된 기본 데이터
const Map<String, dynamic> testData = {
  'location': '시즌5-11-3',              // 스테이지 위치 (고정)
  'baseClearRewardExp': 32500,   // 기본 클리어 보상 경험치 (고정)
  'baseClearRewardGold': 32500,        // 기본 클리어 보상 골드 (고정)
  'staminaCost': 20,                    // 루프당 소모 스테미너 (고정) - 예시값

 'drops': <DropInfo>[
    DropInfo(
      itemId: 'gold_demon_3star',
      category: DropCategory.goldDemon,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.10, // 60%
    ),
    DropInfo(
      itemId: 'dragon_4star',
      category: DropCategory.minion,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.10, // 10% 
    ),
  ],
};