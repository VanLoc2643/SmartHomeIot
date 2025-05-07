import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/device_state.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    "iot/device",
  );
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref().child(
    "iot/sensor",
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<DeviceState> getDeviceStateStream() {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return DeviceState.fromMap(data);
    });
  }

  Stream<int> getMQ2ValueStream() {
    return _sensorRef.child('mq2').onValue.map((event) {
      final value = event.snapshot.value as int? ?? 0;
      return value;
    });
  }

  void setDeviceState(String key, dynamic value) {
    _dbRef.child(key).set(value);
  }

  Future<String> getUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['name'] ?? 'Người dùng';
    }
    return 'Người dùng';
  }
}
