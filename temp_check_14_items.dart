import 'dart:convert';
import 'dart:io';

void main() {
  final csvPath = r'C:\Users\Yul\Downloads\제목 없는 스프레드시트 - 시트1 (1).csv';
  final jsonPath = r'C:\Users\Yul\Downloads\gohcalculator-default-rtdb-export (4).json';

  final csvToJsonName = {
    '나노 머신': '나노머신',
    '레이드 기념 모자': '레이드기념 모자',
    '백호의 팔찌': '백호 팔찌',
    '산타 모자': '산타모자',
    '이무기 머리띠': '이무기머리띠',
    '이무기 용포장갑': '이무기 용포 장갑',
    '주작의 팔찌': '주작 팔찌',
    '중2병 봉인 안대': '중2병 봉인안대',
    '진모리 수면 안대': '진모리수면안대',
    '청룡의 팔찌': '청룡 팔찌',
    '치의 곰돌이 인형': '피치의 곰돌이 인형',
    '큐니 미니 선풍기': '큐티 미니 선풍기',
    '현무의 팔찌': '현무 팔찌',
    '화이트 스노글로브': '화이트 스노글러브',
  };

  final csvFile = File(csvPath);
  final jsonFile = File(jsonPath);

  if (!csvFile.existsSync() || !jsonFile.existsSync()) {
    stderr.writeln('FILE_NOT_FOUND');
    exitCode = 1;
    return;
  }

  // Parse JSON
  dynamic root;
  try {
    root = jsonDecode(utf8.decode(jsonFile.readAsBytesSync()));
  } catch (e) {
    stderr.writeln('JSON_PARSE_FAIL');
    exitCode = 1;
    return;
  }

  if (root is! Map || root['accessories'] is! Map) {
    stderr.writeln('JSON_SHAPE_INVALID');
    exitCode = 1;
    return;
  }

  final accessories = (root['accessories'] as Map).cast<String, dynamic>();

  stdout.writeln('---14_ITEMS_STATUS---');
  for (final csvName in csvToJsonName.keys) {
    final jsonName = csvToJsonName[csvName]!;

    dynamic foundItem;
    for (final value in accessories.values) {
      if (value is Map && (value['name'] ?? '').toString() == jsonName) {
        foundItem = value;
        break;
      }
    }

    if (foundItem == null) {
      stdout.writeln('$jsonName: NOT_FOUND');
      continue;
    }

    if (foundItem is! Map) {
      stdout.writeln('$jsonName: INVALID_TYPE');
      continue;
    }

    final itemMap = foundItem.cast<String, dynamic>();
    final options = itemMap['options'];

    if (options is! List) {
      stdout.writeln('$jsonName: NO_OPTIONS');
      continue;
    }

    final optCount = options.length;
    final hasBonus = itemMap.containsKey('enhancementStageBonus') && 
                     (itemMap['enhancementStageBonus'] as dynamic).length > 0;
    
    stdout.writeln('$jsonName: OPTIONS=$optCount, HAS_BONUS=$hasBonus');

    if (optCount <= 3 && hasBonus) {
      final bonus = (itemMap['enhancementStageBonus'] as List).cast<dynamic>();
      if (bonus.isNotEmpty && bonus[0] is Map) {
        final firstBonus = (bonus[0] as Map).cast<String, dynamic>();
        final stageVals = firstBonus['stageValues'];
        if (stageVals is List && stageVals.isNotEmpty) {
          stdout.writeln(
            '  -> FIXED_OPTION: optCount=$optCount, s9=${stageVals.last}',
          );
        }
      }
    }
  }
}
