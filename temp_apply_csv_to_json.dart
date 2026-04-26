import 'dart:convert';
import 'dart:io';

class CsvRow {
  CsvRow(this.cells);
  final List<String> cells;
}

List<CsvRow> parseCsv(String input) {
  final rows = <CsvRow>[];
  var row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < input.length; i++) {
    final ch = input[i];

    if (inQuotes) {
      if (ch == '"') {
        final nextIsQuote = i + 1 < input.length && input[i + 1] == '"';
        if (nextIsQuote) {
          cell.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cell.write(ch);
      }
      continue;
    }

    if (ch == '"') {
      inQuotes = true;
    } else if (ch == ',') {
      row.add(cell.toString());
      cell.clear();
    } else if (ch == '\n') {
      row.add(cell.toString().replaceAll('\r', ''));
      cell.clear();
      rows.add(CsvRow(row));
      row = <String>[];
    } else {
      cell.write(ch);
    }
  }

  if (cell.isNotEmpty || row.isNotEmpty) {
    row.add(cell.toString().replaceAll('\r', ''));
    rows.add(CsvRow(row));
  }

  return rows;
}

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

  final csvFile = File(csvPath);
  final jsonFile = File(jsonPath);
  if (!csvFile.existsSync()) {
    stderr.writeln('CSV_NOT_FOUND=$csvPath');
    exitCode = 1;
    return;
  }
  if (!jsonFile.existsSync()) {
    stderr.writeln('JSON_NOT_FOUND=$jsonPath');
    exitCode = 1;
    return;
  }

  dynamic root;
  try {
    root = jsonDecode(utf8.decode(jsonFile.readAsBytesSync()));
  } catch (e) {
    stderr.writeln('JSON_PARSE_FAIL=$e');
    exitCode = 1;
    return;
  }

  if (root is! Map || root['accessories'] is! Map) {
    stderr.writeln('JSON_SHAPE_INVALID');
    exitCode = 1;
    return;
  }

  final rootMap = root.cast<String, dynamic>();
  final accessories = (rootMap['accessories'] as Map).cast<String, dynamic>();

  final movedKeys = <String>[];
  final topKeys = rootMap.keys.toList(growable: false);
  for (final k in topKeys) {
    if (k == 'accessories') continue;
    final v = rootMap[k];
    if (v is Map && v.containsKey('id') && v.containsKey('options')) {
      accessories[k] = v;
      movedKeys.add(k);
    }
  }
  for (final k in movedKeys) {
    rootMap.remove(k);
  }

  final jsonNameSet = <String>{};
  accessories.forEach((_, value) {
    if (value is Map) {
      final n = (value['name'] ?? '').toString();
      if (n.isNotEmpty) jsonNameSet.add(n);
    }
  });

  final csvBytes = csvFile.readAsBytesSync();
  final candidateEncodings = <Encoding>[utf8, systemEncoding];
  List<CsvRow>? rows;
  var bestInter = -1;
  var bestCsvUnique = 0;
  List<String> bestCsvSample = const [];

  for (final enc in candidateEncodings) {
    final text = enc.decode(csvBytes);
    final parsed = parseCsv(text);
    if (parsed.length < 2) continue;
    final header = parsed.first.cells;
    if (header.length < 11) continue;

    var current = '';
    final csvNames = <String>{};
    for (var i = 1; i < parsed.length; i++) {
      final r = parsed[i].cells;
      final n = (r.isNotEmpty ? r[0] : '').trim();
      if (n.isNotEmpty) current = n;
      if (current.isNotEmpty) csvNames.add(current);
    }

    var inter = 0;
    for (final n in csvNames) {
      if (jsonNameSet.contains(n)) inter++;
    }

    if (inter > bestInter) {
      bestInter = inter;
      rows = parsed;
      bestCsvUnique = csvNames.length;
      bestCsvSample = csvNames.take(10).toList(growable: false);
    }
  }

  if (rows == null) {
    stderr.writeln('CSV_PARSE_FAIL');
    exitCode = 1;
    return;
  }

  final groups = <String, List<List<double?>>>{};
  final blockCount = <String, int>{};
  var currentName = '';
  var prevHeaderName = '';

  for (var i = 1; i < rows.length; i++) {
    final r = rows[i].cells;
    final name = (r.isNotEmpty ? r[0] : '').trim();
    if (name.isNotEmpty) {
      currentName = name;
      if (name != prevHeaderName) {
        blockCount[name] = (blockCount[name] ?? 0) + 1;
        prevHeaderName = name;
      }
    }
    if (currentName.isEmpty) continue;

    final stageValues = <double?>[];
    for (var c = 2; c <= 10; c++) {
      final cell = c < r.length ? r[c] : '';
      stageValues.add(parseNum(cell));
    }
    groups.putIfAbsent(currentName, () => <List<double?>>[]).add(stageValues);
  }

  final nameToKeys = <String, List<String>>{};
  accessories.forEach((key, value) {
    if (value is Map) {
      final n = (value['name'] ?? '').toString();
      if (n.isNotEmpty) {
        nameToKeys.putIfAbsent(n, () => <String>[]).add(key);
      }
    }
  });

  final excludeSet = <String>{};
  for (final name in groups.keys) {
    final keys = nameToKeys[name];
    if (keys == null || keys.isEmpty) {
      excludeSet.add(name);
      continue;
    }
    if ((blockCount[name] ?? 0) > 1) {
      excludeSet.add(name);
      continue;
    }
  }

  var updated = 0;
  var skipExcluded = 0;
  var skipNoRows = 0;
  var skipNoOptions = 0;

  for (final name in groups.keys) {
    if (excludeSet.contains(name)) {
      skipExcluded++;
      continue;
    }

    final key = nameToKeys[name]!.first;
    final item = accessories[key];
    if (item is! Map) continue;
    final itemMap = item.cast<String, dynamic>();

    final optionsDynamic = itemMap['options'];
    if (optionsDynamic is! List || optionsDynamic.isEmpty) {
      skipNoOptions++;
      continue;
    }

    final options = optionsDynamic.cast<dynamic>();
    final rowsForName = groups[name]!
        .where((sv) => sv.any((v) => v != null))
        .toList(growable: false);
    if (rowsForName.isEmpty) {
      skipNoRows++;
      continue;
    }

    final pairCount = options.length < rowsForName.length ? options.length : rowsForName.length;
    final bonusList = <Map<String, dynamic>>[];

    for (var i = 0; i < pairCount; i++) {
      final opt = options[i];
      if (opt is! Map) continue;
      final optMap = opt.cast<String, dynamic>();

      final sv = rowsForName[i];
      final stageStr = <String>[];
      for (final v in sv) {
        stageStr.add(v == null ? '0' : numToStr(v));
      }

      if (options.length <= 3 && optMap['optionValue'] != null) {
        final cur = parseNum(optMap['optionValue'].toString());
        final s9 = sv.length >= 9 ? sv[8] : null;
        if (cur != null && s9 != null) {
          optMap['optionValue'] = numToStr(cur - s9);
        }
      }

      bonusList.add({
        'optionName': (optMap['optionName'] ?? '').toString(),
        'stageValues': stageStr,
      });
    }

    if (bonusList.isNotEmpty) {
      itemMap['enhancementStageBonus'] = bonusList;
      updated++;
    }
  }

  final ts = DateTime.now()
      .toIso8601String()
      .replaceAll(':', '')
      .replaceAll('-', '')
      .replaceAll('.', '')
      .replaceAll('T', '_')
      .split('Z')
      .first;
  final backupPath = '$jsonPath.bak_$ts';
  jsonFile.copySync(backupPath);

  final encoder = const JsonEncoder.withIndent('  ');
  final out = encoder.convert(root);
  jsonFile.writeAsStringSync(out, encoding: utf8);

  stdout.writeln('UPDATED=$updated');
  stdout.writeln('SKIP_EXCLUDED=$skipExcluded');
  stdout.writeln('SKIP_NOROWS=$skipNoRows');
  stdout.writeln('SKIP_NOOPTIONS=$skipNoOptions');
  stdout.writeln('JSON_NAME_COUNT=${jsonNameSet.length}');
  stdout.writeln('CSV_UNIQUE_COUNT=$bestCsvUnique');
  stdout.writeln('CSV_JSON_NAME_INTERSECTION=$bestInter');
  stdout.writeln('CSV_NAME_SAMPLE=${bestCsvSample.join(' | ')}');
  stdout.writeln('JSON_NAME_SAMPLE=${jsonNameSet.take(10).join(' | ')}');
  stdout.writeln('MOVED_ROOT_KEYS=${movedKeys.length}');
  stdout.writeln('BACKUP=$backupPath');
}
