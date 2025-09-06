// lib/stage_data/angel_hell.dart
import '../../../core/constants/drop_item_constants.dart';

// 지옥엔젤 스테이지의 고정된 기본 데이터
const Map<String, dynamic> angelNormalData = {
  'location': '시즌3-18-8',              // 스테이지 위치 (고정)
  'baseClearRewardExp': 42000,   // 기본 클리어 보상 경험치 (고정)
  'baseClearRewardGold': 42000,        // 기본 클리어 보상 골드 (고정)
  'staminaCost': 20,                    // 루프당 소모 스테미너 (고정) - 예시값

 // --- 새로운 드랍 정보 추가 ---
  'drops': <DropInfo>[
    DropInfo(
      itemId: 'gold_demon_3star', // monster_constants.dart의 몬스터 이름과 일치시킬 수 있습니다.
      category: DropCategory.goldDemon,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.36, // 36%
    ),
    DropInfo(
      itemId: 'angel_4star', // 직접 정의한 아이템 ID
      category: DropCategory.minion,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.18, // 18%
    ),
    DropInfo(
      itemId: 'joker_normal', // accessory_constants.dart의 Accessory.id 값
      category: DropCategory.borrowedPower,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.009, // 0.9%
    ),
    DropInfo(
      itemId: 'minigame_damage_normal',
      category: DropCategory.fragment,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.04, // 4%  
    ),
        DropInfo(
      itemId: 'minigame_damage_advanced',
      category: DropCategory.fragment,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.018, // 1.8%
    ),
        DropInfo(
      itemId: 'minigame_damage_rare',
      category: DropCategory.fragment,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.009, // 0.9%
    ),
  ],
};