// lib/models/accessory.dart (또는 Accessory 클래스가 정의된 파일)

class AccessoryOption {
  final String optionName; // 예: "공격력 증가", "치명타 확률", "화염 속성 강화"
  final String optionValue;  // 예: "+100", "+5%", "+10%" (문자열로 저장하여 "+", "%" 등 다양한 형식 표현)
                           // 또는 double/int 타입으로 저장하고, 표시는 별도로 처리할 수도 있습니다.
                           // 여기서는 표시 그대로 문자열로 저장하는 것으로 가정합니다.

  const AccessoryOption({
    required this.optionName,
    required this.optionValue,
  });
}

class Accessory {
  final String id;
  final String name;
  final String imagePath;
  final String part; 
  final String restrictions;
  final List<AccessoryOption> options; // 옵션 목록을 리스트로 관리

  const Accessory({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.part,
    required this.restrictions,
    required this.options, // 옵션 목록을 필수로 받도록 변경
  });
}