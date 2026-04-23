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

  final fixedOptItems = {
    '이무기 용포장갑': '이무기 용포 장갑',
    '큐니 미니 선풍기': '큐티 미니 선풍기',
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
  
  final csvDataMap = <String, List<List<double?>>>{};
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

    if (!fixedOptItems.containsKey(currentName)) continue;

    if (!csvDataMap.containsKey(currentName)) {
      csvDataMap[currentName] = [];
    }

    final sv = <double?>[];
    for (var j = 2; j <= 10 && j < parts.length; j++) {
      final v = parts[j].replaceAll('"', '').trim();
      sv.add(parseNum(v));
    }
    if (sv.any((v) => v != null)) {
      csvDataMap[currentName]!.add(sv);
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

  // Update fixed option items
  for (final csvName in fixedOptItems.keys) {
    if (!csvDataMap.containsKey(csvName)) continue;

    final jsonName = fixedOptItems[csvName]!;
    final csvRows = csvDataMap[csvName]!;

    dynamic foundItem;
    for (final value in accessories.values) {
      if (value is Map && (value['name'] ?? '').toString() == jsonName) {
        foundItem = value;
        break;
      }
    }

    if (foundItem == null || foundItem is! Map) continue;

    final itemMap = foundItem.cast<String, dynamic>();
    final options = itemMap['options'];
    if (options is! List || (options as List).isEmpty) continue;

    final optList = (options as List).cast<dynamic>();

    // Adjust optionValue for each option
    for (var oi = 0; oi < optList.length && oi < csvRows.length; oi++) {
      final opt = optList[oi];
      if (opt is! Map) continue;

      final optMap = opt.cast<String, dynamic>();
      final sv = csvRows[oi];
      if (sv.isEmpty) continue;

      final s9 = sv[8];
      if (s9 == null || s9 == 0) continue;

      if (optMap['optionValue'] != null) {
        final cur = parseNum(optMap['optionValue'].toString());
        if (cur != null) {
          final base = cur - s9;
          optMap['optionValue'] = numToStr(base);
          print('$jsonName[${optMap['optionName']}]: $cur - $s9 = ${numToStr(base)}');
        }
      }
    }

    updated++;
  }

  final encoder = const JsonEncoder.withIndent('  ');
  final out = encoder.convert(root);
  jsonFile.writeAsStringSync(out, encoding: utf8);

  print('UPDATED_ITEMS=$updated');
}
