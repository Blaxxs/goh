// lib/data/models/accessory.dart

class AccessoryOption {
  final String optionName;
  final String optionValue;

  const AccessoryOption({
    required this.optionName,
    required this.optionValue,
  });

  factory AccessoryOption.fromJson(Map<String, dynamic> json) {
    return AccessoryOption(
      optionName: json['optionName']?.toString() ?? '',
      optionValue: json['optionValue']?.toString() ?? '',
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

    if (stageValuesJson is Map) {
      stageValuesJson.forEach((key, value) {
        stageValues[key.toString()] = value?.toString() ?? '';
      });
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

    return AccessorySetOption(
      setId: jsonMap['setId']?.toString() ?? '',
      setName: jsonMap['setName']?.toString() ?? '',
      requiredAccessories: requiredAccList.map((e) => e.toString()).toList(),
      requiredAccessoryImages: requiredImgList.map((e) => e.toString()).toList(),
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
  final List<AccessorySetOption> setOptions;

  const Accessory({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.part,
    required this.restrictions,
    required this.options,
    this.setOptions = const [],
  });

  factory Accessory.fromJson(Map<String, dynamic> json) {
    final String id = json['id']?.toString() ?? '';

    // 프로젝트 ID를 기반으로 한 Storage 기본 주소 (서울 리전 기준)
    // 파일이 accessories 폴더 안에 있다면 아래와 같이 조합됩니다.
    // final String autoImageUrl = 'assets/images/accessories/$id.png';
    final String encodedId = Uri.encodeComponent(id);
    final String autoImageUrl = "https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/accessories%2F$encodedId.png?alt=media";

    var list = json['options'] as List? ?? [];
    List<AccessoryOption> optionsList = list
        .map((i) => AccessoryOption.fromJson(Map<String, dynamic>.from(i)))
        .toList();

    var setList = json['setOptions'] as List? ?? [];
    List<AccessorySetOption> setOptionsList = setList
        .map((i) => AccessorySetOption.fromJson(Map<String, dynamic>.from(i)))
        .toList();

    return Accessory(
      id: id,
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? autoImageUrl, // 전달받은 imageUrl이 있으면 우선 사용
      part: json['part']?.toString() ?? '',
      restrictions: json['restrictions']?.toString() ?? '',
      options: optionsList,
      setOptions: setOptionsList,
    );
  }
}
