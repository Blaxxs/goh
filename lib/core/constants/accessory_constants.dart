// lib/core/constants/accessory_constants.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/accessory.dart';

/// A singleton class to manage accessory data fetched from Firebase.
///
/// This manager fetches accessory data from the Realtime Database,
/// processes it, and makes it available throughout the app.
/// It also caches data locally for faster subsequent loads.
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
  
  // --- Cache Keys ---
  static const String _cacheKeyAccessories = 'cached_accessories';
  static const String _cacheKeyParts = 'cached_accessory_parts';
  static const String _cacheKeyRecentAccessoryIds = 'recent_accessory_ids';
  static const int _maxRecentAccessoryIds = 40;

  /// Loads accessories from local cache first, then updates from Firebase in the background.
  /// 
  /// This method:
  /// 1. Loads cached data from SharedPreferences (instant, from previous session)
  /// 2. Starts async Firebase fetch to check for updates (happens in background)
  /// 3. If fresh data is found, updates cache and in-memory lists
  ///
  /// This ensures the app loads instantly with cached data while keeping it up-to-date.
  /// Loads accessories from local cache first. If [waitForRemote] is true,
  /// this method will also wait for the remote Firebase fetch to complete
  /// before returning. Otherwise the Firebase fetch runs in background.
  Future<void> loadAccessories({bool waitForRemote = false}) async {
    // Step 1: Try to load from local cache first (instant)
    await _loadFromCache();

    // Step 2: Either fetch remote data synchronously (await) or start background fetch
    if (waitForRemote) {
      await _fetchFromFirebase();
    } else {
      _updateFromFirebaseInBackground();
    }
  }
  
  /// Loads cached accessories from SharedPreferences.
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedAccessoriesJson = prefs.getString(_cacheKeyAccessories);
      final cachedPartsJson = prefs.getString(_cacheKeyParts);
      
      if (cachedAccessoriesJson != null && cachedPartsJson != null) {
        final List<dynamic> accessoriesJson = jsonDecode(cachedAccessoriesJson);
        allAccessories = accessoriesJson
            .map((json) => Accessory.fromJson(json as Map<String, dynamic>))
            .toList();
        
        final List<dynamic> partsJson = jsonDecode(cachedPartsJson);
        accessoryParts = List<String>.from(partsJson);
        
        if (kDebugMode) {
          print(
              '[AccessoryDataManager] Loaded ${allAccessories.length} accessories from cache');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AccessoryDataManager] Error loading cache: $e');
      }
    }
  }
  
  /// Fetches fresh data from Firebase and updates cache if new data is found.
  /// This runs in the background and does not block the UI.
  void _updateFromFirebaseInBackground() {
    _fetchFromFirebase().then((_) {
      // Firebase fetch completed; cache has been updated if necessary
    }).catchError((e) {
      if (kDebugMode) {
        print('[AccessoryDataManager] Background Firebase update failed: $e');
      }
    });
  }
  
  /// Fetches accessory data from Firebase Realtime Database and updates the cache.
  ///
  /// It reads from the '/accessories' path, parses each entry into an [Accessory] object,
  /// and automatically generates the corresponding Firebase Storage URL for the image.
  Future<void> _fetchFromFirebase() async {
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
        
        // Save to cache for next session
        await _saveToCache();

        if (kDebugMode) {
          print(
              '[AccessoryDataManager] Successfully loaded ${allAccessories.length} accessories from Firebase');
        }
      } else {
        if (kDebugMode) {
          print('[AccessoryDataManager] No accessory data found at /accessories in Firebase.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AccessoryDataManager] Error fetching from Firebase: $e');
      }
    }
  }
  
  /// Saves current accessory data to local cache (SharedPreferences).
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final accessoriesJson = jsonEncode(
        allAccessories.map((a) => {
          'id': a.id,
          'name': a.name,
          'imageUrl': a.imageUrl,
          'part': a.part,
          'restrictions': a.restrictions,
          'options': a.options.map((o) => {
            'optionName': o.optionName,
            'optionValue': o.optionValue,
            if (o.minNormalValue != null)
              'minNormalValue': o.minNormalValue.toString(),
            if (o.maxNormalValue != null)
              'maxNormalValue': o.maxNormalValue.toString(),
          }).toList(),
          'enhancementStageBonus': a.enhancementStageBonuses.map((bonus) => {
            'optionName': bonus.optionName,
            'stageValues': bonus.stageValues,
          }).toList(),
          'randomOptionConfig': a.randomOptionConfig == null ? null : {
            'minOptionCount': a.randomOptionConfig!.minOptionCount,
            'maxOptionCount': a.randomOptionConfig!.maxOptionCount,
          },
          'setOptions': a.setOptions.map((s) => {
            'setId': s.setId,
            'setName': s.setName,
            'requiredAccessories': s.requiredAccessories,
            'requiredAccessoryImages': s.requiredAccessoryImages,
            'effects': s.effects.map((e) => {
              'optionName': e.optionName,
              'stageValues': e.stageValues,
            }).toList(),
          }).toList(),
        }).toList()
      );
      
      final partsJson = jsonEncode(accessoryParts);
      
      await prefs.setString(_cacheKeyAccessories, accessoriesJson);
      await prefs.setString(_cacheKeyParts, partsJson);
      
      if (kDebugMode) {
        print('[AccessoryDataManager] Cached ${allAccessories.length} accessories');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AccessoryDataManager] Error saving cache: $e');
      }
    }
  }

  /// 최근 열람/선택한 악세사리 ID를 LRU 방식으로 저장한다.
  Future<void> markAccessoryAsRecentlyUsed(String accessoryId) async {
    if (accessoryId.trim().isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getStringList(_cacheKeyRecentAccessoryIds) ?? [];

      final normalized = accessoryId.trim();
      final next = <String>[normalized, ...current.where((id) => id != normalized)];
      if (next.length > _maxRecentAccessoryIds) {
        next.removeRange(_maxRecentAccessoryIds, next.length);
      }
      await prefs.setStringList(_cacheKeyRecentAccessoryIds, next);
    } catch (e) {
      if (kDebugMode) {
        print('[AccessoryDataManager] Error updating recent accessory ids: $e');
      }
    }
  }

  /// 최근 사용 악세를 우선으로 하여 이미지 URL 목록을 반환한다.
  Future<List<String>> getPrioritizedAccessoryImageUrls({
    required int limit,
  }) async {
    if (limit <= 0 || allAccessories.isEmpty) return const [];

    try {
      final prefs = await SharedPreferences.getInstance();
      final recentIds = prefs.getStringList(_cacheKeyRecentAccessoryIds) ?? const [];

      final byId = <String, Accessory>{for (final a in allAccessories) a.id: a};
      final used = <String>{};
      final urls = <String>[];

      for (final id in recentIds) {
        final acc = byId[id];
        if (acc == null) continue;
        if (used.add(acc.imageUrl)) {
          urls.add(acc.imageUrl);
          if (urls.length >= limit) return urls;
        }
      }

      for (final acc in allAccessories) {
        if (used.add(acc.imageUrl)) {
          urls.add(acc.imageUrl);
          if (urls.length >= limit) break;
        }
      }

      return urls;
    } catch (e) {
      if (kDebugMode) {
        print('[AccessoryDataManager] Error building prioritized image URLs: $e');
      }
      return allAccessories.take(limit).map((a) => a.imageUrl).toSet().toList();
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
  static const String summonAtkFlat = '소환수공격력 증가';
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
