// lib/core/services/database_service.dart

import 'package:firebase_database/firebase_database.dart';
import '../../data/models/accessory.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Stream<List<Accessory>> getAccessoriesStream() {
    return _dbRef.child('accessories').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return [];

      // Firebase는 데이터를 Map이나 List로 줄 수 있으므로 통합 처리
      final dynamic rawData = snapshot.value;
      List<Accessory> accessories = [];

      if (rawData is Map) {
        rawData.forEach((key, value) {
          accessories.add(Accessory.fromJson(Map<String, dynamic>.from(value)));
        });
      } else if (rawData is List) {
        for (var item in rawData) {
          if (item != null) {
            accessories.add(Accessory.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
      return accessories;
    });
  }
}