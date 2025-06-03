// lib/stage_data/angel_hell.dart
import '../constants/drop_item_constants.dart';

// 지옥엔젤 스테이지의 고정된 기본 데이터
const Map<String, dynamic> yowonData = {
  'location': '지옥4-16-6',              // 스테이지 위치 (고정)
  'baseClearRewardExp': 35000,   // 기본 클리어 보상 경험치 (고정)
  'baseClearRewardGold': 35000,        // 기본 클리어 보상 골드 (고정)
  'staminaCost': 32,                    // 루프당 소모 스테미너 (고정) - 예시값

 'drops': <DropInfo>[
    DropInfo(
      itemId: 'gold_demon_2star', 
      category: DropCategory.goldDemon,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.18, // 18%
    ),
    DropInfo(
      itemId: 'agent_4star', 
      category: DropCategory.minion,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.35, // 27%
    ),
    DropInfo(
      itemId: 'skill_damage_normal',
      category: DropCategory.fragment,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.06, // 6%
    ),
        DropInfo(
      itemId: 'skill_damage_advanced',
      category: DropCategory.fragment,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.04, // 4%
    ),
        DropInfo(
      itemId: 'skill_damage_rare',
      category: DropCategory.fragment,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.02, // 2%
    ),
  ],
};