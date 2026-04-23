import 'package:flutter/foundation.dart';

class AccessoryOption {
  final String optionName;
  final String optionValue;
  final int? minNormalValue;
  final int? maxNormalValue;

  const AccessoryOption({
    required this.optionName,
    required this.optionValue,
    this.minNormalValue,
    this.maxNormalValue,
  });

  factory AccessoryOption.fromJson(Map<String, dynamic> json) {
    final parsedMin = int.tryParse(json['minNormalValue']?.toString() ?? '');
    final parsedMax = int.tryParse(json['maxNormalValue']?.toString() ?? '');
    final rawOptionValue = json['optionValue']?.toString() ?? '';

    return AccessoryOption(
      optionName: json['optionName']?.toString() ?? '',
      optionValue: rawOptionValue.isNotEmpty
          ? rawOptionValue
          : (parsedMin != null && parsedMax != null
              ? '$parsedMin~$parsedMax'
              : ''),
      minNormalValue: parsedMin,
      maxNormalValue: parsedMax,
    );
  }

  AccessoryOption copyWith({
    String? optionName,
    String? optionValue,
    int? minNormalValue,
    int? maxNormalValue,
  }) {
    return AccessoryOption(
      optionName: optionName ?? this.optionName,
      optionValue: optionValue ?? this.optionValue,
      minNormalValue: minNormalValue ?? this.minNormalValue,
      maxNormalValue: maxNormalValue ?? this.maxNormalValue,
    );
  }
}

class AccessoryEnhancementStageBonus {
  final String optionName;
  final List<String> stageValues;

  const AccessoryEnhancementStageBonus({
    required this.optionName,
    required this.stageValues,
  });

  factory AccessoryEnhancementStageBonus.fromJson(dynamic json) {
    final jsonMap = json is Map ? Map<String, dynamic>.from(json) : {};
    final rawStageValues = jsonMap['stageValues'];
    final stageValues = <String>[];

    if (rawStageValues is List) {
      for (final value in rawStageValues) {
        stageValues.add(value?.toString() ?? '');
      }
    } else if (rawStageValues is Map) {
      final indexed = <int, String>{};
      rawStageValues.forEach((key, value) {
        final index = int.tryParse(key.toString());
        if (index != null) {
          indexed[index] = value?.toString() ?? '';
        }
      });

      final sortedKeys = indexed.keys.toList()..sort();
      for (final key in sortedKeys) {
        stageValues.add(indexed[key] ?? '');
      }
    }

    return AccessoryEnhancementStageBonus(
      optionName: jsonMap['optionName']?.toString() ?? '',
      stageValues: stageValues,
    );
  }

  String valueAtLevel(int enhancementLevel) {
    if (enhancementLevel <= 0 || stageValues.isEmpty) {
      return '0';
    }

    final index = enhancementLevel - 1;
    if (index < stageValues.length) {
      return stageValues[index];
    }
    return stageValues.last;
  }
}

class AccessoryRandomOptionRange {
  final String optionName;
  final int min;
  final int max;

  const AccessoryRandomOptionRange({
    required this.optionName,
    required this.min,
    required this.max,
  });

  factory AccessoryRandomOptionRange.fromJson(dynamic json) {
    final jsonMap = json is Map ? Map<String, dynamic>.from(json) : {};
    return AccessoryRandomOptionRange(
      optionName: jsonMap['optionName']?.toString() ?? '',
      min: int.tryParse(jsonMap['min']?.toString() ?? '') ?? 0,
      max: int.tryParse(jsonMap['max']?.toString() ?? '') ?? 0,
    );
  }
}

class AccessoryRandomOptionConfig {
  final int minOptionCount;
  final int maxOptionCount;

  const AccessoryRandomOptionConfig({
    required this.minOptionCount,
    required this.maxOptionCount,
  });

  factory AccessoryRandomOptionConfig.fromJson(dynamic json) {
    final jsonMap = json is Map ? Map<String, dynamic>.from(json) : {};

    return AccessoryRandomOptionConfig(
      minOptionCount:
          int.tryParse(jsonMap['minOptionCount']?.toString() ?? '') ?? 1,
      maxOptionCount:
          int.tryParse(jsonMap['maxOptionCount']?.toString() ?? '') ?? 2,
    );
  }
}

// 세트 옵션의 개별 효과
class SetOptionEffect {
  final String optionName;
  final Map<String, String> stageValues; // 단계별 수치 (0~18)

  const SetOptionEffect({
    required this.optionName,
    required this.stageValues,
  });

  factory SetOptionEffect.fromJson(dynamic json) {
    if (json == null) {
      return SetOptionEffect(
        optionName: '',
        stageValues: {},
      );
    }

    final jsonMap = json is Map ? Map<String, dynamic>.from(json) : {};
    final stageValuesJson = jsonMap['stageValues'];
    final stageValues = <String, String>{};

    // stageValues may be provided as a Map or as a List in Firebase data.
    if (stageValuesJson is Map) {
      stageValuesJson.forEach((key, value) {
        final keyStr = key is int ? key.toString() : key.toString();
        final valueStr = value?.toString() ?? '';
        stageValues[keyStr] = valueStr;
      });
    } else if (stageValuesJson is List) {
      // Convert list entries to map with string keys '0'..'n'
      for (var i = 0; i < stageValuesJson.length; i++) {
        final val = stageValuesJson[i];
        stageValues[i.toString()] = val?.toString() ?? '';
      }
    }

    if (kDebugMode && stageValues.isEmpty && stageValuesJson != null) {
      debugPrint('[SetOptionEffect] WARNING: stageValues is empty after parsing. Raw data: $stageValuesJson');
    }

    return SetOptionEffect(
      optionName: jsonMap['optionName']?.toString() ?? '',
      stageValues: stageValues,
    );
  }
}

// 악세사리 세트 옵션
class AccessorySetOption {
  final String setId;
  final String setName;
  final List<String> requiredAccessories;
  final List<String> requiredAccessoryImages;
  final List<SetOptionEffect> effects;

  const AccessorySetOption({
    required this.setId,
    required this.setName,
    required this.requiredAccessories,
    required this.requiredAccessoryImages,
    required this.effects,
  });

  factory AccessorySetOption.fromJson(dynamic json) {
    if (json == null) {
      return AccessorySetOption(
        setId: '',
        setName: '',
        requiredAccessories: [],
        requiredAccessoryImages: [],
        effects: [],
      );
    }

    final jsonMap = json is Map ? Map<String, dynamic>.from(json) : {};

    final requiredAccList = jsonMap['requiredAccessories'] as List? ?? [];
    final requiredImgList = jsonMap['requiredAccessoryImages'] as List? ?? [];
    final effectsList = jsonMap['effects'] as List? ?? [];

    if (kDebugMode) {
      debugPrint('=== AccessorySetOption Debug ===');
      debugPrint('[SetOpt] setId: ${jsonMap['setId']}');
      debugPrint('[SetOpt] setName: ${jsonMap['setName']}');
      debugPrint('[SetOpt] requiredImgList raw data: $requiredImgList');
      debugPrint('[SetOpt] requiredImgList type: ${requiredImgList.runtimeType}');
      requiredImgList.asMap().forEach((idx, item) {
        debugPrint('[SetOpt] [$idx] type: ${item.runtimeType}, value: $item');
      });
    }

    // 악세사리 이미지 URL이 Firebase 경로인 경우 완전한 URL로 변환
    final processedImages = requiredImgList.map((e) {
      final imageId = e.toString();
      // 이미 완전한 URL이면 그대로 사용
      if (imageId.startsWith('http')) {
        if (kDebugMode) {
          debugPrint('[SetOpt] Image already URL: $imageId');
        }
        return imageId;
      }

      // 이미 확장자가 포함되어 있는 경우(예: christmas_bell.png), 중복 확장자 추가를 피합니다.
      // 확장자 판단은 간단히 마지막에 "."이 있고 1-5글자 알파벳이 따라오는 형태로 처리합니다.
      final bool hasExtension = RegExp(r"\.[a-zA-Z0-9]{1,5}(\?|$)").hasMatch(imageId);

      // Firebase Storage URL로 변환 (accessories 폴더에 있다고 가정)
      final encodedId = Uri.encodeComponent(imageId);
      final filename = hasExtension ? encodedId : '$encodedId.png';
      final generatedUrl = 'https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/accessories%2F$filename?alt=media';
      if (kDebugMode) {
        debugPrint('[SetOpt] Generated URL for "$imageId": $generatedUrl (hasExtension=$hasExtension)');
      }
      return generatedUrl;
    }).toList();

    if (kDebugMode) {
      debugPrint('[SetOpt] Final processedImages: $processedImages');
      debugPrint('================================');
    }

    return AccessorySetOption(
      setId: jsonMap['setId']?.toString() ?? '',
      setName: jsonMap['setName']?.toString() ?? '',
      requiredAccessories: requiredAccList.map((e) => e.toString()).toList(),
      requiredAccessoryImages: processedImages,
      effects: effectsList
          .map((e) => SetOptionEffect.fromJson(e))
          .toList(),
    );
  }
}

class Accessory {
  final String id;
  final String name;
  final String imageUrl; // 로컬 경로 대신 네트워크 URL 저장
  final String part;
  final String restrictions;
  final List<AccessoryOption> options;
  final List<AccessoryEnhancementStageBonus> enhancementStageBonuses;
  final List<AccessorySetOption> setOptions;
  final AccessoryRandomOptionConfig? randomOptionConfig;

  const Accessory({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.part,
    required this.restrictions,
    required this.options,
    this.enhancementStageBonuses = const [],
    this.setOptions = const [],
    this.randomOptionConfig,
  });

  factory Accessory.fromJson(Map<String, dynamic> json) {
    final String id = json['id']?.toString() ?? '';

    // 프로젝트 ID를 기반으로 한 Storage 기본 주소 (서울 리전 기준)
    // 파일이 accessories 폴더 안에 있다면 아래와 같이 조합됩니다.
    // final String autoImageUrl = 'assets/images/accessories/$id.png';
    final String encodedId = Uri.encodeComponent(id);
    final String autoImageUrl = "https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/accessories%2F$encodedId.png?alt=media";

    final rawImageUrl = json['imageUrl']?.toString() ?? '';
    final rawImagePath = json['imagePath']?.toString() ?? '';
    String resolvedImageUrl = autoImageUrl;

    if (rawImageUrl.isNotEmpty) {
      resolvedImageUrl = rawImageUrl;
    } else if (rawImagePath.isNotEmpty) {
      final imageName = rawImagePath.split('/').last;
      final hasExtension = RegExp(r"\.[a-zA-Z0-9]{1,5}$").hasMatch(imageName);
      final filename = hasExtension ? imageName : '$imageName.png';
      final encodedFilename = Uri.encodeComponent(filename);
      resolvedImageUrl = "https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/accessories%2F$encodedFilename?alt=media";
    }

    var optionsList = json['options'] as List? ?? [];
    List<AccessoryOption> options = optionsList
        .map((i) => AccessoryOption.fromJson(
            i is Map ? Map<String, dynamic>.from(i) : {}))
        .toList();

    var enhancementStageBonusList = json['enhancementStageBonus'] as List? ?? [];
    List<AccessoryEnhancementStageBonus> enhancementStageBonuses =
      enhancementStageBonusList
        .map((i) => AccessoryEnhancementStageBonus.fromJson(i))
        .toList();

    var setOptionsList = json['setOptions'] as List? ?? [];
    List<AccessorySetOption> setOptions = setOptionsList
        .map((i) => AccessorySetOption.fromJson(i))
        .toList();

    final randomOptionConfigJson = json['randomOptionConfig'];
    final randomOptionConfig = randomOptionConfigJson == null
        ? null
        : AccessoryRandomOptionConfig.fromJson(randomOptionConfigJson);

    return Accessory(
      id: id,
      name: json['name']?.toString() ?? '',
      imageUrl: resolvedImageUrl,
      part: json['part']?.toString() ?? '',
      restrictions: json['restrictions']?.toString() ?? '',
      options: options,
      enhancementStageBonuses: enhancementStageBonuses,
      setOptions: setOptions,
      randomOptionConfig: randomOptionConfig,
    );
  }

  bool get hasEnhancementStageBonuses => enhancementStageBonuses.isNotEmpty;

  List<AccessoryOption> optionsAtEnhancementLevel(int enhancementLevel) {
    if (enhancementLevel <= 0 || enhancementStageBonuses.isEmpty) {
      return options;
    }

    return options
        .map((option) => _applyEnhancementBonus(option, enhancementLevel))
        .toList(growable: false);
  }

  AccessoryOption _applyEnhancementBonus(
    AccessoryOption option,
    int enhancementLevel,
  ) {
    final normalizedOptionName = _normalizeOptionName(option.optionName);
    AccessoryEnhancementStageBonus? matchedBonus;

    for (final bonus in enhancementStageBonuses) {
      if (_normalizeOptionName(bonus.optionName) == normalizedOptionName) {
        matchedBonus = bonus;
        break;
      }
    }

    if (matchedBonus == null) {
      return option;
    }

    final bonusValue = num.tryParse(matchedBonus.valueAtLevel(enhancementLevel));
    if (bonusValue == null || bonusValue == 0) {
      return option;
    }

    if (option.minNormalValue != null && option.maxNormalValue != null) {
      final minValue = option.minNormalValue! + bonusValue.toInt();
      final maxValue = option.maxNormalValue! + bonusValue.toInt();
      return option.copyWith(
        minNormalValue: minValue,
        maxNormalValue: maxValue,
        optionValue: '${_formatNumber(minValue)}~${_formatNumber(maxValue)}',
      );
    }

    final baseValue = num.tryParse(option.optionValue);
    if (baseValue != null) {
      return option.copyWith(
        optionValue: _formatNumber(baseValue + bonusValue),
      );
    }

    return option;
  }

  String _normalizeOptionName(String value) {
    return value.replaceAll(RegExp(r'\s+'), '').trim();
  }

  String _formatNumber(num value) {
    if (value is int || value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toString();
  }
}
