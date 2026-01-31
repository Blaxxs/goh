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

  factory Accessory.fromJson(Map<String, dynamic> json) {
    // options가 리스트가 아닌 경우에도 대응
    var list = json['options'] as List? ?? [];
    List<AccessoryOption> optionsList = list
        .map((i) => AccessoryOption.fromJson(Map<String, dynamic>.from(i)))
        .toList();

    return Accessory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      imagePath: json['imagePath']?.toString() ?? '',
      part: json['part']?.toString() ?? '',
      restrictions: json['restrictions']?.toString() ?? '',
      options: optionsList,
    );
  }
}