// lib/core/constants/accessory_constants.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/accessory.dart';

/// A singleton class to manage accessory data fetched from Firebase.
///
/// This manager fetches accessory data from the Realtime Database,
/// processes it, and makes it available throughout the app.
///
/// Usage:
/// 1. Initialize by calling `await AccessoryDataManager().loadAccessories()` at app startup (e.g., in your main() function).
/// 2. Access the loaded data via `AccessoryDataManager().allAccessories` and `AccessoryDataManager().accessoryParts`.
class AccessoryDataManager {
  // --- Singleton Setup ---
  static final AccessoryDataManager _instance =
      AccessoryDataManager._internal();
  factory AccessoryDataManager() {
    return _instance;
  }
  AccessoryDataManager._internal();

  // --- Data Storage ---
  List<Accessory> allAccessories = [];
  List<String> accessoryParts = [];

  /// Fetches accessory data from Firebase Realtime Database and populates the data lists.
  ///
  /// It reads from the '/accessories' path, parses each entry into an [Accessory] object,
  /// and automatically generates the corresponding Firebase Storage URL for the image.
  Future<void> loadAccessories() async {
    try {
      final DatabaseReference ref =
          FirebaseDatabase.instance.ref('accessories');
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(snapshot.value as Map);
        final List<Accessory> loadedAccessories = [];
        final Set<String> parts = <String>{};

        data.forEach((key, value) {
          final accessoryData = Map<String, dynamic>.from(value as Map);

          // Use the Firebase key as the ID. This ensures the ID is always present
          // and matches the image name in Firebase Storage.
          accessoryData['id'] = key;

          // [FIX] 이미지 URL을 올바른 버킷 주소와 대소문자를 유지한 키값으로 직접 생성하여 주입합니다.
          // 로그상의 버킷(goh-calculator.appspot.com)과 실제 파일이 있는 버킷(gohcalculator.firebasestorage.app)이 다르며,
          // Firebase Storage는 대소문자를 구분하므로 key를 소문자로 변환하지 않고 그대로 사용해야 합니다.
          final String encodedId = Uri.encodeComponent(key);
          final String imageUrl = 'https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/accessories%2F$encodedId.png?alt=media';
          accessoryData['imageUrl'] = imageUrl;
          
          if (kDebugMode) {
            print('Generated Image URL for $key: $imageUrl');
          }

          final accessory = Accessory.fromJson(accessoryData);
          loadedAccessories.add(accessory);
          if (accessory.part.isNotEmpty) {
            parts.add(accessory.part);
          }
        });

        allAccessories = loadedAccessories;
        accessoryParts = parts.toList();

        // Sort data alphabetically for consistent display
        allAccessories.sort((a, b) => a.name.compareTo(b.name));
        accessoryParts.sort();

        if (kDebugMode) {
          print(
              'Successfully loaded ${allAccessories.length} accessories and ${accessoryParts.length} parts.');
        }
      } else {
        if (kDebugMode) {
          print('No accessory data found at /accessories in Firebase.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading accessory data: $e');
      }
      // In case of error, ensure lists are empty
      allAccessories = [];
      accessoryParts = [];
    }
  }
}

// 옵션 이름을 상수로 관리하는 클래스
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
  static const String critChanceFlat = '크리티컬 증가';
  static const String critDamageFlat = '크리티컬데미지 증가';
  static const String critResistFlat = '크리티컬 저항 증가';
  static const String hpFlat = '체력 증가';
  static const String defenseFlat = '방어력 증가';
  static const String hpRegenPerTurn = '매턴 체력 회복';
  static const String summonAtkFlat = '소환수공격 증가';
  static const String rabbitMaxHpChancePercent = '토끼 최대체력 +1 확률 %증가';
  static const String spaceTravelReturnChancePercent = '우주여행 돌아올 확률 %증가';

  static final Set<String> _allOptionNames = {
    atkPercent,
    hpPercent,
    activeSkillDmgPercent,
    basicAtkDmgPercent,
    miniGameSkillDmgPercent,
    dotDmgPercent,
    penetrationChancePercent,
    penetrationResistPercent,
    counterAttackChancePercent,
    skillCooldownIncreaseResistPercent,
    allBadEffectResistPercent,
    recoveryEffectPercent,
    allDmgTakenReducePercent,
    activeSkillDmgTakenReducePercent,
    basicAtkDmgTakenReducePercent,
    dotDmgTakenReducePercent,
    attackPowerFlat,
    accuracyFlat,
    evasionFlat,
    critChanceFlat,
    critDamageFlat,
    critResistFlat,
    hpFlat,
    defenseFlat,
    hpRegenPerTurn,
    summonAtkFlat,
    rabbitMaxHpChancePercent,
    spaceTravelReturnChancePercent,
  };

  static String getConstantName(String koreanName) {
    if (kDebugMode && !_allOptionNames.contains(koreanName)) {
      // print("Warning: Unknown option name '$koreanName'. Consider adding to AccessoryOptionNames.");
    }
    return koreanName;
  }
}
