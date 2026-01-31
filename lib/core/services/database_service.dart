// lib/core/services/database_service.dart

import 'package:firebase_database/firebase_database.dart';
import '../../data/models/accessory.dart';

class DatabaseService {
  // Firebase Realtime Database 참조 생성
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // 'accessories' 노드의 데이터를 실시간 스트림으로 가져오기
  Stream<List<Accessory>> getAccessoriesStream() {
    return _dbRef.child('accessories').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      
      if (data == null) return [];

      // Map 형태의 데이터를 Accessory 객체 리스트로 변환
      return data.entries.map((entry) {
        final value = Map<String, dynamic>.from(entry.value as Map);
        return Accessory.fromJson(value);
      }).toList();
    });
  }
}