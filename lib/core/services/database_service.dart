import 'package:firebase_database/firebase_database.dart';
import '../../../../data/models/accessory.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Firebase의 'accessories' 노드를 감시하여 리스트로 반환
  Stream<List<Accessory>> getAccessoriesStream() {
    return _dbRef.child('accessories').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.entries.map((entry) {
        final value = Map<String, dynamic>.from(entry.value as Map);
        return Accessory.fromJson(value);
      }).toList();
    });
  }
}