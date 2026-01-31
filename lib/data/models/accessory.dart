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
  final String id = json['id']?.toString() ?? '';
  
  // 프로젝트 ID를 기반으로 한 Storage 기본 주소 (서울 리전 기준)
  // 파일이 accessories 폴더 안에 있다면 아래와 같이 조합됩니다.
  final String autoImageUrl = "https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/accessories%2F$id.png?alt=media";

  var list = json['options'] as List? ?? [];
  List<AccessoryOption> optionsList = list
      .map((i) => AccessoryOption.fromJson(Map<String, dynamic>.from(i)))
      .toList();

  return Accessory(
    id: id,
    name: json['name']?.toString() ?? '',
    imageUrl: autoImageUrl, // 이제 DB에 imageUrl 필드가 없어도 자동으로 생성됩니다!
    part: json['part']?.toString() ?? '',
    restrictions: json['restrictions']?.toString() ?? '',
    options: optionsList,
  );
}
}