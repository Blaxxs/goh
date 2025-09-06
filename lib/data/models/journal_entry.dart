// lib/models/journal_entry.dart

class JournalEntry {
  final DateTime date;
  final String stage;
  final int consumedSoulStones;
  final int earnedSoulStones;
  final int earnedGold; // 획득 골드 필드 추가
  final int earnedGoldDemons; // 획득 돈악마 개수 필드 추가

  JournalEntry({
    required this.date,
    required this.stage,
    required this.consumedSoulStones,
    required this.earnedSoulStones,
    this.earnedGold = 0, // 기본값 0
    this.earnedGoldDemons = 0, // 기본값 0
  });

  // 순수 영혼석 계산
  int get netSoulStones => earnedSoulStones - consumedSoulStones;

  // JournalEntry 객체를 JSON 형태로 변환
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(), // DateTime을 ISO 8601 문자열로 저장
      'stage': stage,
      'consumedSoulStones': consumedSoulStones,
      'earnedSoulStones': earnedSoulStones,
      'earnedGold': earnedGold,
      'earnedGoldDemons': earnedGoldDemons,
    };
  }

  // JSON 형태로부터 JournalEntry 객체 생성
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      date: DateTime.parse(json['date'] as String), // ISO 8601 문자열을 DateTime으로 파싱
      stage: json['stage'] as String,
      consumedSoulStones: json['consumedSoulStones'] as int,
      earnedSoulStones: json['earnedSoulStones'] as int,
      earnedGold: json['earnedGold'] as int? ?? 0, // null일 경우 0으로 초기화
      earnedGoldDemons: json['earnedGoldDemons'] as int? ?? 0, // null일 경우 0으로 초기화
    );
  }
}