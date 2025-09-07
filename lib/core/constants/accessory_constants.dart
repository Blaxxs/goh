// lib/ants/accessory_ants.dart
import 'package:flutter/foundation.dart'; // 디버깅용
import '../../data/models/accessory.dart'; // Accessory, AccessoryOption 모델 import

// 옵션 이름을 상수로 관리하는 클래스 (알려주신 목록 기반 업데이트)
class AccessoryOptionNames {
  // --- % 증가 옵션 ---
  static const String atkPercent = '공격력 %증가';
  static const String hpPercent = '체력 %증가';
  static const String activeSkillDmgPercent = '공격스킬피해 %증가';
  static const String basicAtkDmgPercent = '일반공격피해 %증가';
  static const String miniGameSkillDmgPercent = '미니게임스킬피해 %증가';
  static const String dotDmgPercent = '지속피해 %증가';
  static const String penetrationChancePercent = '관통확률 %증가';
  static const String penetrationResistPercent = '관통확률 저항 %증가';
  static const String counterAttackChancePercent = '반격확률 %증가';
  static const String skillCooldownIncreaseResistPercent = '스킬쿨타임증가 저항 %증가';
  static const String allBadEffectResistPercent = '모든나쁜효과 저항 %증가';
  static const String recoveryEffectPercent = '회복효과 %증가';

  // --- % 감소 옵션 ---
  static const String allDmgTakenReducePercent = '모든피해 %감소';
  static const String activeSkillDmgTakenReducePercent = '받는공격스킬피해 %감소';
  static const String basicAtkDmgTakenReducePercent = '받는일반공격피해 %감소';
  static const String dotDmgTakenReducePercent = '받는지속피해 %감소';

  // --- 기타 옵션 (고정 수치 증가 등) ---
  static const String attackPowerFlat = '공격력 증가';
  static const String accuracyFlat = '명중 증가';
  static const String evasionFlat = '회피 증가';
  static const String critChanceFlat = '크리티컬 증가'; // 고정 수치 크리티컬 확률로 가정
  static const String critDamageFlat = '크리티컬데미지 증가'; // 고정 수치 크리티컬 데미지로 가정
  static const String critResistFlat = '크리티컬 저항 증가'; // 고정 수치 크리티컬 저항
  static const String hpFlat = '체력 증가'; // 추가
  static const String defenseFlat = '방어력 증가'; // 추가
  static const String hpRegenPerTurn = '매턴 체력 회복';
  static const String summonAtkFlat = '소환수공격 증가'; // 추가
  static const String rabbitMaxHpChancePercent = '토끼 최대체력 +1 확률 %증가'; // 추가
  static const String spaceTravelReturnChancePercent = '우주여행 돌아올 확률 %증가'; // 추가

  // 옵션 이름을 상수로 변환하는 헬퍼 함수 (내부 사용)
  static String? getConstantName(String koreanName) {
    switch (koreanName) {
      // % 증가
      case '공격력 %증가': return atkPercent;
      case '체력 %증가': return hpPercent;
      case '공격스킬피해 %증가': return activeSkillDmgPercent;
      case '일반공격피해 %증가': return basicAtkDmgPercent;
      case '미니게임스킬피해 %증가': return miniGameSkillDmgPercent;
      case '지속피해 %증가': return dotDmgPercent;
      case '관통확률 %증가': return penetrationChancePercent;
      case '관통확률 저항 %증가': return penetrationResistPercent;
      case '반격확률 %증가': return counterAttackChancePercent;
      case '스킬쿨타임증가 저항 %증가': return skillCooldownIncreaseResistPercent;
      case '모든나쁜효과 저항 %증가': return allBadEffectResistPercent;
      case '회복효과 %증가': return recoveryEffectPercent;
      // % 감소
      case '모든피해 %감소': return allDmgTakenReducePercent;
      case '받는공격스킬피해 %감소': return activeSkillDmgTakenReducePercent;
      case '받는일반공격피해 %감소': return basicAtkDmgTakenReducePercent;
      case '받는지속피해 %감소': return dotDmgTakenReducePercent;
      // 기타
      case '공격력 증가': return attackPowerFlat;
      case '명중 증가': return accuracyFlat;
      case '회피 증가': return evasionFlat;
      case '크리티컬 증가': return critChanceFlat;
      case '크리티컬데미지 증가': return critDamageFlat;
      case '크리티컬 저항 증가': return critResistFlat;
      case '체력 증가': return hpFlat; // 추가
      case '방어력 증가': return defenseFlat; // 추가
      case '매턴 체력 회복': return hpRegenPerTurn;
      case '소환수공격 증가': return summonAtkFlat; // 추가
      case '토끼 최대체력 +1 확률 %증가': return rabbitMaxHpChancePercent; // 추가
      case '우주여행 돌아올 확률 %증가': return spaceTravelReturnChancePercent; // 추가
      default:
        if (kDebugMode) {
          print("경고: 알 수 없는 옵션 이름 '$koreanName' 발견. AccessoryOptionNames에 추가 필요.");
        }
        return koreanName; // 매핑 실패 시 원본 이름 반환 (또는 null 반환)
    }
  }
}

// 악세사리 부위 목록 (데이터에서 추출된 모든 부위 포함)
const List<String> accessoryParts = [
  '머리',
  '손', // 데이터에서 추출된 부위들
];

// 악세사리 데이터 목록
const List<Accessory> allAccessories = [
  // 제공해주신 데이터 기반으로 생성된 목록
   Accessory(
    id: 'alexs_hat',
    name: '알렉스의 모자',
    imagePath: 'assets/images/accessories/alexs_hat.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.counterAttackChancePercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'ayam_of_the_west_witch',
    name: '서쪽 마녀의 아얌',
    imagePath: 'assets/images/accessories/ayam_of_the_west_witch.png',
    part: '머리',
    restrictions: '여자 캐릭터 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.activeSkillDmgTakenReducePercent, optionValue: '55'),
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '65'),
    ],
  ),
   Accessory(
    id: 'backpack_full_of_snacks',
    name: '간식가득 책가방',
    imagePath: 'assets/images/accessories/backpack_full_of_snacks.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'baek_seung-cheols_hat',
    name: '백승철의 복두',
    imagePath: 'assets/images/accessories/baek_seung-cheols_hat.png',
    part: '머리',
    restrictions: '남자 캐릭터 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.basicAtkDmgTakenReducePercent, optionValue: '55'),
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '65'),
    ],
  ),
   Accessory(
    id: 'beep_beep_hat',
    name: '삐약삐약 모자',
    imagePath: 'assets/images/accessories/beep_beep_hat.png',
    part: '머리',
    restrictions: '병아리 롯 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '45'),
      AccessoryOption(optionName: AccessoryOptionNames.dotDmgTakenReducePercent, optionValue: '32'),
    ],
  ),
   Accessory(
    id: 'black_cross_earrings',
    name: '검은 십자가 귀걸이',
    imagePath: 'assets/images/accessories/black_cross_earrings.png',
    part: '머리', // 부위 데이터가 '머리'로 되어 있어 그대로 사용. '귀걸이'가 맞다면 수정 필요.
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '100'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationChancePercent, optionValue: '45'),
    ],
  ),
   Accessory(
    id: 'black_ring',
    name: '검은 반지',
    imagePath: 'assets/images/accessories/black_ring.png',
    part: '손', // 부위 데이터가 '손'으로 되어 있어 그대로 사용. '반지'가 맞다면 수정 필요.
    restrictions: '환생 LV.9 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '90'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '90'),
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '45'),
    ],
  ),
   Accessory(
    id: 'blue_dragons_lantern',
    name: '청룡의 등채',
    imagePath: 'assets/images/accessories/blue_dragons_lantern.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.basicAtkDmgPercent, optionValue: '90'),
      AccessoryOption(optionName: AccessoryOptionNames.miniGameSkillDmgPercent, optionValue: '120'),
    ],
  ),
   Accessory(
    id: 'candy_blade',
    name: '캔디 블레이드',
    imagePath: 'assets/images/accessories/candy_blade.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '90'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationChancePercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'ceos_luxury_necklace',
    name: '대표님의 명품목걸이',
    imagePath: 'assets/images/accessories/ceos_luxury_necklace.png',
    part: '머리', // 부위 데이터가 '머리'로 되어 있어 그대로 사용. '목걸이'가 맞다면 수정 필요.
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '75'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '30'),
    ],
  ),
   Accessory(
    id: 'cherry_blossom_mask',
    name: '벚꽃 마스크',
    imagePath: 'assets/images/accessories/cherry_blossom_mask.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '35'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationChancePercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'cherry_blossom_snowglobe',
    name: '벚꽃 스노글로브',
    imagePath: 'assets/images/accessories/cherry_blossom_snowglobe.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.basicAtkDmgPercent, optionValue: '75'),
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '45'),
    ],
  ),
   Accessory(
    id: 'chess_choco_macaron_hat',
    name: '체스초코 마카롱 모자',
    imagePath: 'assets/images/accessories/chess_choco_macaron_hat.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '35'),
      AccessoryOption(optionName: AccessoryOptionNames.miniGameSkillDmgPercent, optionValue: '150'),
    ],
  ),
   Accessory(
    id: 'chicken_tail_fishing_rod',
    name: '닭꼬리 낚싯대',
    imagePath: 'assets/images/accessories/chicken_tail_fishing_rod.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.counterAttackChancePercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'choker_of_life',
    name: '생명의 초커',
    imagePath: 'assets/images/accessories/choker_of_life.png',
    part: '머리', // 부위 데이터가 '머리'로 되어 있어 그대로 사용. '목걸이'가 맞다면 수정 필요.
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.recoveryEffectPercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '65'),
    ],
  ),
   Accessory(
    id: 'chungmugongs_helmet',
    name: '충무공의 투구',
    imagePath: 'assets/images/accessories/chungmugongs_helmet.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.allDmgTakenReducePercent, optionValue: '37'),
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'costume_nurse_cap',
    name: '코스튬 너스캡',
    imagePath: 'assets/images/accessories/costume_nurse_cap.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '50'),
    ],
  ),
   Accessory(
    id: 'cutie_mini_fan',
    name: '큐티 미니 선풍기',
    imagePath: 'assets/images/accessories/cutie_mini_fan.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'daepodong_burger',
    name: '대포동 버거',
    imagePath: 'assets/images/accessories/daepodong_burger.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.basicAtkDmgPercent, optionValue: '85'),
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'earrings_of_fighting_god',
    name: '투신의 귀걸이',
    imagePath: 'assets/images/accessories/earrings_of_fighting_god.png',
    part: '머리', // 부위 데이터가 '머리'로 되어 있어 그대로 사용. '귀걸이'가 맞다면 수정 필요.
    restrictions: '환생 LV.3 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.basicAtkDmgPercent, optionValue: '90'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '75'),
    ],
  ),
   Accessory(
    id: 'essence_of_the_demon_king',
    name: '마왕의 정수',
    imagePath: 'assets/images/accessories/essence_of_the_demon_king.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.penetrationChancePercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.counterAttackChancePercent, optionValue: '40'),
    ],
  ),
   Accessory(
    id: 'fan_of_cheering',
    name: '응원의 부채',
    imagePath: 'assets/images/accessories/fan_of_cheering.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.hpRegenPerTurn, optionValue: '10000'),
      AccessoryOption(optionName: AccessoryOptionNames.recoveryEffectPercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'fox_ears_of_fascination',
    name: '매혹의 여우귀',
    imagePath: 'assets/images/accessories/fox_ears_of_fascination.png',
    part: '머리',
    restrictions: '암흑계약 박일아 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.dotDmgTakenReducePercent, optionValue: '32'),
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '65'),
    ],
  ),
   Accessory(
    id: 'grand_mages_hat',
    name: '대마도사의 모자',
    imagePath: 'assets/images/accessories/grand_mages_hat.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '30'),
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'guardians_blessing_[chuk]',
    name: '수호신의 축복[축]',
    imagePath: 'assets/images/accessories/guardians_blessing_[chuk].png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '30'),
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'guardians_blessing_[jin]',
    name: '수호신의 축복[진]',
    imagePath: 'assets/images/accessories/guardians_blessing_[jin].png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '30'),
    ],
  ),
   Accessory(
    id: 'guardians_blessing_[sin]',
    name: '수호신의 축복[신]',
    imagePath: 'assets/images/accessories/guardians_blessing_[sin].png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '65'),
      AccessoryOption(optionName: AccessoryOptionNames.basicAtkDmgPercent, optionValue: '90'),
      AccessoryOption(optionName: AccessoryOptionNames.dotDmgPercent, optionValue: '100'),
    ],
  ),
   Accessory(
    id: 'guardians_blessing_[sul]',
    name: '수호신의 축복[술]',
    imagePath: 'assets/images/accessories/guardians_blessing_[sul].png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.miniGameSkillDmgPercent, optionValue: '100'),
      AccessoryOption(optionName: AccessoryOptionNames.basicAtkDmgPercent, optionValue: '90'),
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'guardians_blessing_[in]',
    name: '수호신의 축복[인]',
    imagePath: 'assets/images/accessories/guardians_blessing_[in].png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.basicAtkDmgPercent, optionValue: '90'),
    ],
  ),
   Accessory(
    id: 'guardians_blessing_[ja]',
    name: '수호신의 축복[자]',
    imagePath: 'assets/images/accessories/guardians_blessing_[ja].png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '65'),
      AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '35'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'guardians_blessing_[mi]',
    name: '수호신의 축복[미]',
    imagePath: 'assets/images/accessories/guardians_blessing_[mi].png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.counterAttackChancePercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '90'),
    ],
  ),
   Accessory(
    id: 'guardians_blessing_[oh]',
    name: '수호신의 축복[오]',
    imagePath: 'assets/images/accessories/guardians_blessing_[oh].png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '35'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'guardians_blessing_[sa]',
    name: '수호신의 축복[사]',
    imagePath: 'assets/images/accessories/guardians_blessing_[sa].png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.dotDmgPercent, optionValue: '100'),
      AccessoryOption(optionName: AccessoryOptionNames.activeSkillDmgPercent, optionValue: '90'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'guardians_blessing_[yu]',
    name: '수호신의 축복[유]',
    imagePath: 'assets/images/accessories/guardians_blessing_[yu].png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.miniGameSkillDmgPercent, optionValue: '100'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationChancePercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '85'),
    ],
  ),
   Accessory(
    id: 'halloween_candy_basket',
    name: '할로윈 사탕 바구니',
    imagePath: 'assets/images/accessories/halloween_candy_basket.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.activeSkillDmgPercent, optionValue: '75'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '50'),
    ],
  ),
   Accessory(
    id: 'halloween_skull_gourd',
    name: '할로윈 해골 바가지',
    imagePath: 'assets/images/accessories/halloween_skull_gourd.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '24'),
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'happy_happy_mini_tree',
    name: '해피해피 미니트리',
    imagePath: 'assets/images/accessories/happy_happy_mini_tree.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '25'),
      AccessoryOption(optionName: AccessoryOptionNames.recoveryEffectPercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'happy_snowman',
    name: '해피 눈사람',
    imagePath: 'assets/images/accessories/happy_snowman.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '70'),
      AccessoryOption(optionName: AccessoryOptionNames.allDmgTakenReducePercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'headband_of_jealousy',
    name: '질투의 머리띠',
    imagePath: 'assets/images/accessories/headband_of_jealousy.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '90'),
    ],
  ),
   Accessory(
    id: 'heart_gift_box',
    name: '하트 선물상자',
    imagePath: 'assets/images/accessories/heart_gift_box.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '75'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '85'),
    ],
  ),
   Accessory(
    id: 'hourglass_of_sin',
    name: '죄업의 모래시계',
    imagePath: 'assets/images/accessories/hourglass_of_sin.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '90'),
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '65'),
    ],
  ),
   Accessory(
    id: 'hwanwoongs_hat',
    name: '환웅의 갓',
    imagePath: 'assets/images/accessories/hwanwoongs_hat.png',
    part: '머리',
    restrictions: '남자 캐릭터 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.skillCooldownIncreaseResistPercent, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '65'),
    ],
  ),
   Accessory(
    id: 'jet_black_fox_ears',
    name: '칠흑의 여우귀',
    imagePath: 'assets/images/accessories/jet_black_fox_ears.png',
    part: '머리',
    restrictions: '암흑계약 박일아 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '32'), // '명중 증가'로 처리
      AccessoryOption(optionName: AccessoryOptionNames.dotDmgTakenReducePercent, optionValue: '32'),
    ],
  ),
   Accessory(
    id: 'kings_seal',
    name: '국왕의 옥새',
    imagePath: 'assets/images/accessories/kings_seal.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '50'),
    ],
  ),
   Accessory(
    id: 'little_witch_park_il-ahs_magic_broom',
    name: '꼬마마녀 박일아의 마법빗자루',
    imagePath: 'assets/images/accessories/little_witch_park_il-ahs_magic_broom.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationChancePercent, optionValue: '30'),
    ],
  ),
   Accessory(
    id: 'lords_robe',
    name: '로드의 로브',
    imagePath: 'assets/images/accessories/lords_robe.png',
    part: '머리', // 부위 데이터가 '머리'로 되어 있어 그대로 사용.
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.activeSkillDmgPercent, optionValue: '90'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '85'),
    ],
  ),
   Accessory(
    id: 'lucky_four_leaf_clover',
    name: '행운의 네잎클로버',
    imagePath: 'assets/images/accessories/lucky_four_leaf_clover.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'lucky_jin_mori_roulette',
    name: '복불복 진모리 룰렛',
    imagePath: 'assets/images/accessories/lucky_jin_mori_roulette.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.counterAttackChancePercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '55'),
    ],
  ),
   Accessory(
    id: 'mark_of_the_black_cat',
    name: '흑묘의 징표',
    imagePath: 'assets/images/accessories/mark_of_the_black_cat.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.counterAttackChancePercent, optionValue: '40'),
    ],
  ),
   Accessory(
    id: 'medal_of_patriotic_hero',
    name: '호국영웅의 훈장',
    imagePath: 'assets/images/accessories/medal_of_patriotic_hero.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '65'),
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '70'),
    ],
  ),
   Accessory(
    id: 'meow_ribbon_headband',
    name: '야옹리본 머리띠',
    imagePath: 'assets/images/accessories/meow_ribbon_headband.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [ // 옵션이 하나인 경우
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '30'),
    ],
  ),
   Accessory(
    id: 'mittens_of_first_snow',
    name: '첫눈의 벙어리장갑',
    imagePath: 'assets/images/accessories/mittens_of_first_snow.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'orb_of_magical_power',
    name: '마력의 보주',
    imagePath: 'assets/images/accessories/orb_of_magical_power.png',
    part: '머리', // 부위 데이터가 '머리'로 되어 있어 그대로 사용.
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.miniGameSkillDmgPercent, optionValue: '100'),
    ],
  ),
   Accessory(
    id: 'pandora_veil',
    name: '판도라 면사포',
    imagePath: 'assets/images/accessories/pandora_veil.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.activeSkillDmgPercent, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '30'),
    ],
  ),
   Accessory(
    id: 'park_il-ahs_pumpkin_witch_hat',
    name: '박일아의 펌킨 마녀모자',
    imagePath: 'assets/images/accessories/park_il-ahs_pumpkin_witch_hat.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '67'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '70'),
    ],
  ),
   Accessory(
    id: 'peach_chocolate',
    name: '피치 쇼콜라',
    imagePath: 'assets/images/accessories/peach_chocolate.png',
    part: '손',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '45'),
      AccessoryOption(optionName: AccessoryOptionNames.attackPowerFlat, optionValue: '3000'), // '공격력 증가'로 처리
    ],
  ),
   Accessory(
    id: 'petit_rudolph',
    name: '쁘띠 루돌프',
    imagePath: 'assets/images/accessories/petit_rudolph.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '90'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'primordial_energy',
    name: '태초의 에너지',
    imagePath: 'assets/images/accessories/primordial_energy.png',
    part: '머리', // 부위 데이터가 '머리'로 되어 있어 그대로 사용.
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '47'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'prosecutors_soul',
    name: '검사의 혼',
    imagePath: 'assets/images/accessories/prosecutors_soul.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.basicAtkDmgPercent, optionValue: '100'),
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'rainbow_candy_magic_wand',
    name: '레인보우 캔디 요술봉',
    imagePath: 'assets/images/accessories/rainbow_candy_magic_wand.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.activeSkillDmgPercent, optionValue: '100'),
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'red_gloves',
    name: '붉은 장갑',
    imagePath: 'assets/images/accessories/red_gloves.png',
    part: '손',
    restrictions: '여자 캐릭터 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.counterAttackChancePercent, optionValue: '42'),
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '90'),
    ],
  ),
   Accessory(
    id: 'ring_of_undead',
    name: '링 오브 언데드',
    imagePath: 'assets/images/accessories/ring_of_undead.png',
    part: '손', // 부위 데이터가 '손'으로 되어 있어 그대로 사용. '반지'가 맞다면 수정 필요.
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.allDmgTakenReducePercent, optionValue: '34'),
    ],
  ),
   Accessory(
    id: 'shamans_jewel',
    name: '무녀의 보옥',
    imagePath: 'assets/images/accessories/shamans_jewel.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.activeSkillDmgPercent, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '90'),
    ],
  ),
   Accessory(
    id: 'shield_kite_of_origin',
    name: '기원의 방패연',
    imagePath: 'assets/images/accessories/shield_kite_of_origin.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'silver_cross_earrings',
    name: '은빛 십자가 귀걸이',
    imagePath: 'assets/images/accessories/silver_cross_earrings.png',
    part: '머리', // 부위 데이터가 '머리'로 되어 있어 그대로 사용. '귀걸이'가 맞다면 수정 필요.
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '45'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'silver_sword_for_self-defense',
    name: '호신용 은장도',
    imagePath: 'assets/images/accessories/silver_sword_for_self-defense.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '70'),
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '70'),
    ],
  ),
   Accessory(
    id: 'snow_flower_headband',
    name: '눈의 꽃 머리띠',
    imagePath: 'assets/images/accessories/snow_flower_headband.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '30'),
    ],
  ),
   Accessory(
    id: 'spicy_ramen',
    name: '퉁퉁 불어 터진 라면',
    imagePath: 'assets/images/accessories/spicy_ramen.png',
    part: '손',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.counterAttackChancePercent, optionValue: '47'),
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '75'),
    ],
  ),
   Accessory(
    id: 'stinging_cat_jelly',
    name: '찌릿한 냥젤리',
    imagePath: 'assets/images/accessories/stinging_cat_jelly.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.activeSkillDmgPercent, optionValue: '90'),
    ],
  ),
   Accessory(
    id: 'sweet_confession_basket',
    name: '달콤한 고백 바구니',
    imagePath: 'assets/images/accessories/sweet_confession_basket.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.allDmgTakenReducePercent, optionValue: '37'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '24'),
    ],
  ),
   Accessory(
    id: 'taekwon_youngjaes_monkey_mini_bag',
    name: '태권영재의 몽키 미니백',
    imagePath: 'assets/images/accessories/taekwon_youngjaes_monkey_mini_bag.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '30'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'the_energy_of_the_black_tiger',
    name: '흑호의 기운',
    imagePath: 'assets/images/accessories/the_energy_of_the_black_tiger.png',
    part: '손',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.counterAttackChancePercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'the_hat_of_king_uma',
    name: '우마왕의 전모',
    imagePath: 'assets/images/accessories/the_hat_of_king_uma.png',
    part: '머리',
    restrictions: '여자 캐릭터 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '52'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'three_flavors_of_churro',
    name: '세가지 맛 츄르',
    imagePath: 'assets/images/accessories/three_flavors_of_churro.png',
    part: '머리', // 부위 데이터가 '머리'로 되어 있어 그대로 사용.
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '30'),
    ],
  ),
   Accessory(
    id: 'transparent_waterproof_beach_bag',
    name: '투명 방수 비치백',
    imagePath: 'assets/images/accessories/transparent_waterproof_beach_bag.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.recoveryEffectPercent, optionValue: '45'),
      AccessoryOption(optionName: AccessoryOptionNames.counterAttackChancePercent, optionValue: '42'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'ungnyeos_headband',
    name: '웅녀의 배씨머리띠',
    imagePath: 'assets/images/accessories/ungnyeos_headband.png',
    part: '머리',
    restrictions: '여자 캐릭터 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.skillCooldownIncreaseResistPercent, optionValue: '60'),
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '52'),
    ],
  ),
   Accessory(
    id: 'vacation_beach_hat',
    name: '바캉스 비치모자',
    imagePath: 'assets/images/accessories/vacation_beach_hat.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.counterAttackChancePercent, optionValue: '42'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'war_hat_of_hojosa',
    name: '호조사의 전립',
    imagePath: 'assets/images/accessories/war_hat_of_hojosa.png',
    part: '머리',
    restrictions: '남자 캐릭터 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '52'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '60'),
    ],
  ),
   Accessory(
    id: 'warm_cherry_blossom_brooch',
    name: '따뜻한 벚꽃 브로치',
    imagePath: 'assets/images/accessories/warm_cherry_blossom_brooch.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '75'),
    ],
  ),
   Accessory(
    id: 'white_snowgloves',
    name: '화이트 스노글러브',
    imagePath: 'assets/images/accessories/white_snowgloves.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.activeSkillDmgPercent, optionValue: '90'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '70'),
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'white_tea_cup',
    name: '화이트 티컵',
    imagePath: 'assets/images/accessories/white_tea_cup.png',
    part: '손',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '35'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationChancePercent, optionValue: '45'),
    ],
  ),
   Accessory(
    id: 'wizard_ilpyos_cursed_doll',
    name: '마법사 일표의 저주인형',
    imagePath: 'assets/images/accessories/wizard_ilpyos_cursed_doll.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '35'),
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '95'),
    ],
  ),
   Accessory(
    id: 'yosak_park',
    name: '박요삭',
    imagePath: 'assets/images/accessories/yosak_park.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '95'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '40'),
    ],
  ),
   Accessory(
    id: 'confessing_bear',
    name: '고백하는 곰돌이',
    imagePath: 'assets/images/accessories/confessing_bear.png',
    part: '손',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '??'),
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '??'),
    ],
  ),
   Accessory(
    id: 'the_power_of_ocheon',
    name: '오천의 힘',
    imagePath: 'assets/images/accessories/the_power_of_ocheon.png',
    part: '머리',
    restrictions: 'SVIP1 참가자 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.penetrationChancePercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '50'),
    ],
  ),
   Accessory(
    id: 'skitzophrenic',
    name: 'SkitZoPhrenic',
    imagePath: 'assets/images/accessories/skitzophrenic.png',
    part: '머리',
    restrictions: 'SVIP1 참가자 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '??'),
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '??'),
    ],
  ),
   Accessory(
    id: 'guitar_of_haru',
    name: '하루의 기타',
    imagePath: 'assets/images/accessories/guitar_of_haru.png',
    part: '머리',
    restrictions: 'SVIP1 참가자 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '50'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '40'),
    ],
  ),
   Accessory(
    id: 'palancs',
    name: 'PalanCs',
    imagePath: 'assets/images/accessories/palancs.png',
    part: '머리',
    restrictions: 'SVIP1 참가자 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '??'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '??'),
    ],
  ),
   Accessory(
    id: '貪',
    name: '貪',
    imagePath: 'assets/images/accessories/貪.png',
    part: '머리',
    restrictions: 'SVIP1 참가자 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '50'),
    ],
  ),
   Accessory(
    id: 'plc_white_whale',
    name: '팔크 하얀 고래',
    imagePath: 'assets/images/accessories/plc_white_whale.png',
    part: '머리',
    restrictions: 'SVIP1 참가자 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '70'),
      AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '80'),
    ],
  ),
   Accessory(
    id: 'devil_genes',
    name: '악마 유전자',
    imagePath: 'assets/images/accessories/devil_genes.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.miniGameSkillDmgPercent, optionValue: '100'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationChancePercent, optionValue: '40'),
    ],
  ),
   Accessory(
    id: 'titanium_implants',
    name: '티타늄 임플란트',
    imagePath: 'assets/images/accessories/titanium_implants.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.dotDmgPercent, optionValue: '120'),
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'rose_of_sharon_hairpin',
    name: '무궁화 헤어핀',
    imagePath: 'assets/images/accessories/rose_of_sharon_hairpin.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.allDmgTakenReducePercent, optionValue: '32'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'pirate_hat_of_greed',
    name: '탐욕의 해적모자',
    imagePath: 'assets/images/accessories/pirate_hat_of_greed.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '80'),
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'noxs_legacy',
    name: '녹스의 유산',
    imagePath: 'assets/images/accessories/noxs_legacy.png',
    part: '머리',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.dotDmgPercent, optionValue: '120'),
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'trophy_of_honor_1',
    name: '명예의 트로피 1',
    imagePath: 'assets/images/accessories/trophy_of_honor_1.png',
    part: '손',
    restrictions: 'SVIP1 참가자 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '75'),
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'trophy_of_honor_2',
    name: '명예의 트로피 2',
    imagePath: 'assets/images/accessories/trophy_of_honor_2.png',
    part: '손',
    restrictions: 'SVIP1 참가자 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.allDmgTakenReducePercent, optionValue: '32'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '50'),
    ],
  ),
   Accessory(
    id: 'freshly_boiled_soybean_paste_soup',
    name: '갓 끓인 된장국',
    imagePath: 'assets/images/accessories/freshly_boiled_soybean_paste_soup.png',
    part: '손',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '70'),
      AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '90'),
    ],
  ),
   Accessory(
    id: 'hanayama_badge',
    name: '하나야마 뱃지',
    imagePath: 'assets/images/accessories/hanayama_badge.png',
    part: '손',
    restrictions: '전 직업 착용 가능',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '55'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '35'),
    ],
  ),
   Accessory(
    id: 'trophy_of_honor_3',
    name: '명예의 트로피 3',
    imagePath: 'assets/images/accessories/trophy_of_honor_3.png',
    part: '손',
    restrictions: 'SVIP1 참가자 전용',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '50'),
    ],
  ),
   Accessory(
    id: 'compass_of_greed',
    name: '탐욕의 나침반',
    imagePath: 'assets/images/accessories/compass_of_greed.png',
    part: '손',
    restrictions: '환생 LV.1 이상',
    options: [
      AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '40'),
      AccessoryOption(optionName: AccessoryOptionNames.penetrationChancePercent, optionValue: '40'),
    ],
  ),
];
  // static const String atkPercent = '공격력 %증가';
  // static const String hpPercent = '체력 %증가';
  // static const String activeSkillDmgPercent = '공격스킬피해 %증가';
  // static const String basicAtkDmgPercent = '일반공격피해 %증가';
  // static const String miniGameSkillDmgPercent = '미니게임스킬피해 %증가';
  // static const String dotDmgPercent = '지속피해 %증가';
  // static const String penetrationChancePercent = '관통확률 %증가';
  // static const String penetrationResistPercent = '관통확률 저항 %증가';
  // static const String counterAttackChancePercent = '반격확률 %증가';
  // static const String skillCooldownIncreaseResistPercent = '스킬쿨타임증가 저항 %증가';
  // static const String allBadEffectResistPercent = '모든나쁜효과 저항 %증가';
  // static const String recoveryEffectPercent = '회복효과 %증가';
  // static const String allDmgTakenReducePercent = '모든피해 %감소';
  // static const String activeSkillDmgTakenReducePercent = '받는공격스킬피해 %감소';
  // static const String basicAtkDmgTakenReducePercent = '받는일반공격피해 %감소';
  // static const String dotDmgTakenReducePercent = '받는지속피해 %감소';
  // static const String attackPowerFlat = '공격력 증가';
  // static const String accuracyFlat = '명중 증가';
  // static const String evasionFlat = '회피 증가';
  // static const String critChanceFlat = '크리티컬 증가'; // 고정 수치 크리티컬 확률로 가정
  // static const String critDamageFlat = '크리티컬데미지 증가'; // 고정 수치 크리티컬 데미지로 가정
  // static const String critResistFlat = '크리티컬 저항 증가'; // 고정 수치 크리티컬 저항
  // static const String hpFlat = '체력 증가'; // 추가
  // static const String defenseFlat = '방어력 증가'; // 추가
  // static const String hpRegenPerTurn = '매턴 체력 회복';
  // static const String summonAtkFlat = '소환수공격 증가'; // 추가
  // static const String rabbitMaxHpChancePercent = '토끼 최대체력 +1 확률 %증가';
  // static const String spaceTravelReturnChancePercent = '우주여행 돌아올 확률 %증가';
