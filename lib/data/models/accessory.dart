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
    var list = json['options'] as List? ?? [];
    List<AccessoryOption> optionsList = 
        list.map((i) => AccessoryOption.fromJson(Map<String, dynamic>.from(i))).toList();

    return Accessory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '이름 없음',
      // Firebase DB에 저장된 'imageUrl' 필드를 읽어옴
      imageUrl: json['imageUrl'] ?? '', 
      part: json['part'] ?? '',
      restrictions: json['restrictions'] ?? '',
      options: optionsList,
    );
  }
}