// lib/stage_data/angel_hell.dart
import '../../../core/constants/drop_item_constants.dart';

// 지옥엔젤 스테이지의 고정된 기본 데이터
const Map<String, dynamic> mujinData = {
  'location': '시즌4-16-히든',              // 스테이지 위치 (고정)
  'baseClearRewardExp': 35000,   // 기본 클리어 보상 경험치 (고정)
  'baseClearRewardGold': 32500,        // 기본 클리어 보상 골드 (고정)
  'staminaCost': 20,     

'drops': <DropInfo>[
    DropInfo(
      itemId: 'gold_demon_2star', // 직접 정의한 아이템 ID
      category: DropCategory.goldDemon,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.55, // 55%
    ),
  ]
};