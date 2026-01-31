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

class Accessory {
  final String id;
  final String name;
  final String imageUrl; // 로컬 애셋 경로 또는 네트워크 URL 저장
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

    // 데이터베이스에 저장된 imagePath를 직접 사용
    final String imageUrl = json['imagePath']?.toString() ?? '';

    var list = json['options'] as List? ?? [];
    List<AccessoryOption> optionsList = list
        .map((i) => AccessoryOption.fromJson(Map<String, dynamic>.from(i)))
        .toList();

    return Accessory(
      id: id,
      name: json['name']?.toString() ?? '',
      imageUrl: imageUrl, // DB의 imagePath 값을 사용
      part: json['part']?.toString() ?? '',
      restrictions: json['restrictions']?.toString() ?? '',
      options: optionsList,
    );
  }
}
