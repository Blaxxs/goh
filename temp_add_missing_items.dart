import 'dart:convert';
import 'dart:io';

void main() {
  final csvPath = r'C:\Users\Yul\Downloads\제목 없는 스프레드시트 - 시트1 (1).csv';
  final jsonPath = r'C:\Users\Yul\Downloads\gohcalculator-default-rtdb-export (4).json';

  final nameMap = {
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

  final csvText = utf8.decode(csvFile.readAsBytesSync());
  final rows = csvText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
  
  final dataMap = <String, Map<String, dynamic>>{};
  var currentName = '';

  for (var i = 1; i < rows.length; i++) {
    final parts = rows[i].split(',').map((p) => p.replaceAll('"', '').trim()).toList();
    if (parts.isEmpty) continue;

    final name = parts[0];
    if (name.isNotEmpty) currentName = name;
    if (currentName.isEmpty) continue;

    if (!nameMap.containsKey(currentName)) continue;

    if (!dataMap.containsKey(currentName)) {
      dataMap[currentName] = {
        'stageValues': <double?>[],
        'desc': (parts.length > 1 ? parts[1] : ''),
      };
    }

    for (var j = 2; j <= 10 && j < parts.length; j++) {
      final v = parts[j].replaceAll(',', '').replaceAll('%', '').trim();
      final num = double.tryParse(v);
      dataMap[currentName]!['stageValues'].add(num);
    }
  }

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
  var addedCount = 0;

  for (final csvName in nameMap.keys) {
    if (!dataMap.containsKey(csvName)) continue;

    final jsonName = nameMap[csvName]!;
    final data = dataMap[csvName]!;
    final sv = (data['stageValues'] as List).cast<double?>();

    if (sv.length < 9 || sv.every((v) => v == null)) continue;

    final id = jsonName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('_의_', '_')
        .replaceAll('의_', '')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');

    if (accessories.containsKey(id)) continue;

    final stageValues = <String>[];
    for (final v in sv) {
      if (v == null) {
        stageValues.add('0');
      } else if ((v - v.roundToDouble()).abs() < 1e-9) {
        stageValues.add(v.round().toString());
      } else {
        stageValues.add(v.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), ''));
      }
    }

    accessories[id] = {
      'id': id,
      'imagePath': 'assets/images/accessories/$id.png',
      'name': jsonName,
      'options': [
        {
          'optionName': '예시 옵션',
          'optionValue': stageValues[8],
        },
      ],
      'part': '손',
      'restrictions': '전 직업 착용 가능',
      'enhancementStageBonus': [
        {
          'optionName': '예시 옵션',
          'stageValues': stageValues,
        },
      ],
    };
    addedCount++;
  }

  final encoder = const JsonEncoder.withIndent('  ');
  final out = encoder.convert(root);
  jsonFile.writeAsStringSync(out, encoding: utf8);

  stdout.writeln('ADDED=$addedCount');
}
