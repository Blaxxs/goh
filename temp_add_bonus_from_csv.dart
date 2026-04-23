import 'dart:convert';
import 'dart:io';

double? parseNum(String? s) {
  if (s == null) return null;
  final t = s.trim().replaceAll(',', '').replaceAll('%', '');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

String numToStr(double n) {
  if ((n - n.roundToDouble()).abs() < 1e-9) {
    return n.round().toString();
  }
  return n.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

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

  // Parse CSV
  final csvText = utf8.decode(csvFile.readAsBytesSync());
  final lines = csvText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
  
  final csvDataMap = <String, List<double?>>{};
  var currentName = '';

  for (var i = 1; i < lines.length; i++) {
    final parts = <String>[];
    var current = '';
    var inQuotes = false;
    
    for (var j = 0; j < lines[i].length; j++) {
      final ch = lines[i][j];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if (ch == ',' && !inQuotes) {
        parts.add(current);
        current = '';
      } else {
        current += ch;
      }
    }
    parts.add(current);

    final name = parts[0].replaceAll('"', '').trim();
    if (name.isNotEmpty) currentName = name;
    if (currentName.isEmpty) continue;

    if (!csvToJsonName.containsKey(currentName)) continue;

    if (!csvDataMap.containsKey(currentName)) {
      csvDataMap[currentName] = [];
    }

    for (var j = 2; j <= 10 && j < parts.length; j++) {
      final v = parts[j].replaceAll('"', '').trim();
      csvDataMap[currentName]!.add(parseNum(v));
    }
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
  var updated = 0;

  // Update accessories with CSV data
  for (final csvName in csvToJsonName.keys) {
    if (!csvDataMap.containsKey(csvName)) continue;

    final jsonName = csvToJsonName[csvName]!;
    final sv = csvDataMap[csvName]!;

    // Find accessory by name
    dynamic foundItem;
    for (final value in accessories.values) {
      if (value is Map && (value['name'] ?? '').toString() == jsonName) {
        foundItem = value;
        break;
      }
    }

    if (foundItem == null) continue;
    if (foundItem is! Map) continue;

    final itemMap = foundItem.cast<String, dynamic>();
    
    // Remove empty enhancementStageBonus if exists
    if (itemMap['enhancementStageBonus'] is List) {
      final bonus = itemMap['enhancementStageBonus'] as List;
      if (bonus.isEmpty) {
        itemMap.remove('enhancementStageBonus');
      }
    }

    // Get options
    final options = itemMap['options'];
    if (options is! List) continue;

    final optList = options.cast<dynamic>();
    if (optList.isEmpty) continue;

    // Build stageValues
    final stageStr = <String>[];
    for (final v in sv) {
      if (v == null) {
        stageStr.add('0');
      } else {
        stageStr.add(numToStr(v));
      }
    }

    // Create enhancementStageBonus
    final bonusList = <Map<String, dynamic>>[];
    
    // Add bonus for each option
    if (optList.length <= 3) {
      // Fixed options: add reverse calculation
      for (var i = 0; i < optList.length && i < sv.length; i++) {
        final opt = optList[i];
        if (opt is! Map) continue;
        
        final optMap = opt.cast<String, dynamic>();
        final optName = (optMap['optionName'] ?? '').toString();
        
        bonusList.add({
          'optionName': optName,
          'stageValues': stageStr,
        });
      }
    } else {
      // Random options: add for first option only
      final opt = optList[0];
      if (opt is Map) {
        final optMap = opt.cast<String, dynamic>();
        final optName = (optMap['optionName'] ?? '').toString();
        bonusList.add({
          'optionName': optName,
          'stageValues': stageStr,
        });
      }
    }

    if (bonusList.isNotEmpty) {
      itemMap['enhancementStageBonus'] = bonusList;
      updated++;
    }
  }

  final encoder = const JsonEncoder.withIndent('  ');
  final out = encoder.convert(root);
  jsonFile.writeAsStringSync(out, encoding: utf8);

  print('UPDATED=$updated');
}
