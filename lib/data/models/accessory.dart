// lib/data/models/accessory.dart

class AccessoryOption {
  final String optionName;
  final String optionValue;

  const AccessoryOption({
    required this.optionName,
    required this.optionValue,
  });

  // Firebase JSON 데이터를 객체로 변환하는 생성자
  factory AccessoryOption.fromJson(Map<String, dynamic> json) {
    return AccessoryOption(
      optionName: json['optionName'] ?? '',
      optionValue: json['optionValue']?.toString() ?? '',
    );
  }
}

class Accessory {
  final String id;
  final String name;
  final String imagePath;
  final String part;
  final String restrictions;
  final List<AccessoryOption> options;

  const Accessory({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.part,
    required this.restrictions,
    required this.options,
  });

  // Firebase JSON 데이터를 객체로 변환하는 생성자
  factory Accessory.fromJson(Map<String, dynamic> json) {
    var list = json['options'] as List? ?? [];
    List<AccessoryOption> optionsList = 
        list.map((i) => AccessoryOption.fromJson(Map<String, dynamic>.from(i))).toList();

    return Accessory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imagePath: json['imagePath'] ?? '',
      part: json['part'] ?? '',
      restrictions: json['restrictions'] ?? '',
      options: optionsList,
    );
  }
}