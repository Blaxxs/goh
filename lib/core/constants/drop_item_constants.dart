// lib/constants/drop_item_constants.dart

// 1. 드랍 아이템 대분류 (카테고리)
enum DropCategory {
  minion,        // 쫄
  goldDemon,     // 돈악마 (아이템으로 드랍되며, 이 아이템을 판매 시 고정된 골드 획득)
  accessory,     // 악세사리
  borrowedPower, // 차력
  fragment,      // 파편
  minionPiece,   // 쫄 조각
  energyStone,   // 에너지스톤
}

// 드랍 카테고리 이름을 한글로 반환하는 헬퍼 함수
String getDropCategoryDisplayName(DropCategory category) {
  switch (category) {
    case DropCategory.minion:
      return '쫄';
    case DropCategory.goldDemon:
      return '돈악마'; // 돈악마 '아이템'을 의미
    case DropCategory.accessory:
      return '악세사리';
    case DropCategory.borrowedPower:
      return '차력 아이템';
    case DropCategory.fragment:
      return '파편';
    case DropCategory.minionPiece:
      return '쫄 조각';
    case DropCategory.energyStone:
      return '에너지스톤';
  }
}

// 2. 개별 드랍 아이템의 상세 정보를 위한 클래스
class DropInfo {
  final String itemId;          // 드랍되는 특정 아이템의 고유 식별자.
  final DropCategory category;  // 위에서 정의한 DropCategory 중 하나.
  final int minQuantity;        // 해당 아이템이 드랍될 때의 최소 수량 (기본값 1).
                                // DropCategory.goldDemon의 경우, 드랍되는 '돈악마 아이템'의 수량.
  final int maxQuantity;        // 해당 아이템이 드랍될 때의 최대 수량 (기본값 1).
  final double probability;     // 이 아이템이 드랍될 확률 (0.0 ~ 1.0).

  const DropInfo({
    required this.itemId,
    required this.category,
    this.minQuantity = 1,
    this.maxQuantity = 1,
    required this.probability,
  });
}

// 3. 특정 아이템 ID 상수

// --- 쫄 (Minion) Item IDs (이전과 동일) ---
const String minionMulyong2Star = 'mulyong_2star';  // '물용'의 영문명 기반 ID  
const String minionMulyong3Star = 'mulyong_3star';    // '물용'의 영문명 기반 ID
const String minionRaven3Star = 'raven_3star'; // '까마귀'의 영문명 기반 ID
const String minionTauros3Star = 'tauros_3star';    // '타우로스'의 영문명 기반 ID  
const String minionTauros4Star = 'tauros_4star';      // '타우로스'의 영문명 기반 ID
const String minionAngel4Star = 'angel_4star';      // '엔젤'의 영문명 기반 ID
const String minionAgent4Star = 'agent_4star';   // '요원'의 영문명 기반 ID
const String miniondragon4Star = 'dragon_4star';   // '드래곤'의 영문명 기반 ID


// --- 돈악마 (Gold Demon) Item IDs ---
// 사용자의 요청에 따라, 등급별 '돈악마 아이템'을 식별하는 상수를 유지합니다.
// 이 아이템들은 드랍된 후, 판매 시 고정된 골드를 제공합니다.
// 그 '판매 가격' 자체는 이 파일이나 DropInfo에서 직접 정의하지 않고, 나중에 별도로 관리될 것입니다.
const String goldDemon2Star = 'gold_demon_2star'; // 2성 돈악마 (아이템)
const String goldDemon3Star = 'gold_demon_3star'; // 3성 돈악마 (아이템)
// 필요하다면 더 많은 돈악마 아이템 타입을 정의할 수 있습니다.
const Map<String, int> goldDemonSellPrices = {
  goldDemon2Star: 100000, // 2성 돈악마 판매 시 100,000 골드
  goldDemon3Star: 20000,  // 3성 돈악마 판매 시 20,000 골드
};

const String miniontauros3starPiece = 'tauros_3star_piece'; // '타우로스 3성 조각'의 영문명 기반 ID
const String miniontauros4starPiece = 'tauros_4star_piece'; // '타우로스 4성 조각'의 영문명 기반 ID 
const String miniontauros5starPiece = 'tauros_5star_piece'; // '타우로스 5성 조각'의 영문명 기반 ID
const String miniontauros6starPiece = 'tauros_6star_piece'; // '타우로스 6성 조각'의 영문명 기반 ID    

const String accessoryOlympusLaurelWreath = 'olympus_laurel_wreath'; // '올림포스 월계관'의 영문명 기반 ID

const String borrowedPowerjokernormal = 'joker_normal'; //차력 조커 노말

const String fragmentminigamedamagenormal = 'minigame_damage_normal'; // 미니게임 파편 노말
const String fragmentminigamedamageadvanced = 'minigame_damage_advanced'; // 미니게임 파편 고급
const String fragmentminigamedamagerare = 'minigame_damage_rare'; // 미니게임 파편 희귀
const String fragmentskilldamagenormal = 'skill_damage_normal'; //  스킬 파편 노말
const String fragmentskilldamageadvanced = 'skill_damage_advanced'; // 스킬 파편 고급
const String fragmentskilldamagerare = 'skill_damage_rare'; // 스킬 파편 희귀

const String energyStone = 'energy_stone'; // 에너지스톤의 영문명 기반 ID

/*
  참고: 각 스테이지 데이터 파일 (예: lib/stage_data/some_stage.dart)에서 DropInfo 사용 예시

  import '../constants/drop_item_constants.dart';

  const Map<String, dynamic> someStageData = {
    // ... (기존 스테이지 정보) ...
    'drops': <DropInfo>[
      const DropInfo(
        itemId: minionMulyong2Star, // 정의된 쫄 상수 사용
        category: DropCategory.minion,
        probability: 0.1,
      ),
      // 2성 돈악마 '아이템'이 1개 드랍
      // 이 'gold_demon_2star' 아이템의 판매가는 여기서 정의하지 않음 (추후 별도 관리)
      const DropInfo(
        itemId: goldDemon2Star, // 정의된 돈악마 아이템 상수 사용
        category: DropCategory.goldDemon,
        minQuantity: 1, // '2성 돈악마 아이템' 1개 드랍
        maxQuantity: 1,
        probability: 0.05,
      ),
      // ...
    ],
  };
*/