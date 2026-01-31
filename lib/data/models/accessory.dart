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
  
  // 1. 본인의 Firebase 프로젝트 ID로 변경하세요.
  const String projectId = "YOUR_PROJECT_ID"; 
  // 2. Storage 폴더 구조에 맞게 베이스 URL 설정
  // %2F는 폴더 구분자(/)를 의미합니다.
  final String autoImageUrl = "https://firebasestorage.googleapis.com/v0/b/$projectId.appspot.com/o/accessories%2F$id.png?alt=media";

  return Accessory(
    id: id,
    name: json['name'] ?? '',
    imageUrl: autoImageUrl, // 이제 DB에 URL이 없어도 ID만 있으면 자동 생성됨!
    part: json['part'] ?? '',
    restrictions: json['restrictions'] ?? '',
    options: (json['options'] as List? ?? [])
        .map((i) => AccessoryOption.fromJson(Map<String, dynamic>.from(i)))
        .toList(),
  );
}
}