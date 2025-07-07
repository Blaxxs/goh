// lib/stage_data/angel_hell.dart
import '../../../core/constants/drop_item_constants.dart';

// 지옥엔젤 스테이지의 고정된 기본 데이터
const Map<String, dynamic> gangrimData = {
  'location': '강림-황소-초급',              // 스테이지 위치 (고정)
  'baseClearRewardExp': 6600,   // 기본 클리어 보상 경험치 (고정)
  'baseClearRewardGold': 0,        // 기본 클리어 보상 골드 (고정)
  'staminaCost': 10,                    // 루프당 소모 스테미너 (고정) - 예시값


 // --- 새로운 드랍 정보 추가 ---
  'drops': <DropInfo>[
    DropInfo(
      itemId: 'tauros_3star', // 직접 정의한 아이템 ID
      category: DropCategory.minion,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.127, // 12.7%
    ),
    DropInfo(
      itemId: 'tauros_3star_piece', // accessory_constants.dart의 Accessory.id 값
      category: DropCategory.minionPiece,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.05, // 5%
    ),
    DropInfo(
      itemId: 'tauros_4star_piece', // accessory_constants.dart의 Accessory.id 값
      category: DropCategory.minionPiece,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.05, // 5%
    ),
    DropInfo(
      itemId: 'tauros_5star_piece', // accessory_constants.dart의 Accessory.id 값
      category: DropCategory.minionPiece,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.05, // 5%
    ),
    DropInfo(
      itemId: 'tauros_6star_piece', // accessory_constants.dart의 Accessory.id 값
      category: DropCategory.minionPiece,
      minQuantity: 1,
      maxQuantity: 1,
      probability: 0.05, // 5%
    ),
  ],
};