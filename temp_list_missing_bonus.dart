import 'dart:convert';
import 'dart:io';

void main() {
  final jsonPath = r'C:\Users\Yul\Downloads\gohcalculator-default-rtdb-export (4).json';
  final jsonFile = File(jsonPath);

  if (!jsonFile.existsSync()) {
    stderr.writeln('FILE_NOT_FOUND');
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

  final accessories = (root['accessories'] as Map).cast<String, dynamic>();
  final noBonus = <String>[];
  final hasBonus = <String>[];

  accessories.forEach((key, value) {
    if (value is Map) {
      final name = (value['name'] ?? '').toString();
      if (name.isNotEmpty) {
        if (value.containsKey('enhancementStageBonus') && 
            value['enhancementStageBonus'] != null &&
            (value['enhancementStageBonus'] as dynamic).length > 0) {
          hasBonus.add(name);
        } else {
          noBonus.add(name);
          if (!value.containsKey('enhancementStageBonus')) {
            value['enhancementStageBonus'] = [];
          }
        }
      }
    }
  });

  final encoder = const JsonEncoder.withIndent('  ');
  final out = encoder.convert(root);
  jsonFile.writeAsStringSync(out, encoding: utf8);

  stdout.writeln('NO_BONUS_COUNT=${noBonus.length}');
  stdout.writeln('HAS_BONUS_COUNT=${hasBonus.length}');
  stdout.writeln('---NO_BONUS_ITEMS---');
  for (final n in noBonus) {
    stdout.writeln(n);
  }
}
