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

  factory SetOptionEffect.fromJson(Map<String, dynamic> json) {
    final stageValuesJson = json['stageValues'] as Map<String, dynamic>? ?? {};
    final stageValues = <String, String>{};
    stageValuesJson.forEach((key, value) {
      stageValues[key] = value?.toString() ?? '';
    });

    return SetOptionEffect(
      optionName: json['optionName']?.toString() ?? '',
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

  factory AccessorySetOption.fromJson(Map<String, dynamic> json) {
    final requiredAccList = json['requiredAccessories'] as List? ?? [];
    final requiredImgList = json['requiredAccessoryImages'] as List? ?? [];
    final effectsList = json['effects'] as List? ?? [];

    return AccessorySetOption(
      setId: json['setId']?.toString() ?? '',
      setName: json['setName']?.toString() ?? '',
      requiredAccessories: requiredAccList.map((e) => e.toString()).toList(),
      requiredAccessoryImages: requiredImgList.map((e) => e.toString()).toList(),
      effects: effectsList
          .map((e) => SetOptionEffect.fromJson(Map<String, dynamic>.from(e)))
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

  const Accessory({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.part,
    required this.restrictions,
    required this.options,
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

    return Accessory(
      id: id,
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? autoImageUrl, // 전달받은 imageUrl이 있으면 우선 사용
      part: json['part']?.toString() ?? '',
      restrictions: json['restrictions']?.toString() ?? '',
      options: optionsList,
    );
  }
}
