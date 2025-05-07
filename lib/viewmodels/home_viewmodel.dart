import 'package:flutter/material.dart';
import 'package:vanlocapp/models/device_state.dart';
import 'package:vanlocapp/services/firebase_service.dart';
import 'package:vanlocapp/services/notification_service.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();

  DeviceState _deviceState = DeviceState(
    mq2Value: 0,
    relay1: false,
    relay2: false,
    servoAngle: 0,
    threshold: 500,
    autoMode: false,
    fan: false,
    pump: false,
  );

  DeviceState get deviceState => _deviceState;

  String _userName = "Người dùng";
  String get userName => _userName;

  List<double> mq2History = [];

  HomeViewModel() {
    _firebaseService.getDeviceStateStream().listen((state) {
      _deviceState = state;
      notifyListeners();
    });

    _firebaseService.getMQ2ValueStream().listen((mq2Value) {
      _deviceState = _deviceState.copyWith(mq2Value: mq2Value);

      mq2History.add(mq2Value.toDouble());
      if (mq2History.length > 20) {
        mq2History.removeAt(0);
      }

      notifyListeners();

      if (mq2Value > _deviceState.threshold) {
        _notificationService.showNotification(
          "Cảnh báo cháy!",
          "Giá trị MQ2 vượt ngưỡng ($mq2Value/${_deviceState.threshold}). Kiểm tra ngay!",
        );
      }
    });

    _firebaseService.getUserName().then((name) {
      _userName = name;
      notifyListeners();
    });
  }

  void toggleRelay1(bool value) {
    _firebaseService.setDeviceState("relay1", value);
  }

  void toggleRelay2(bool value) {
    _firebaseService.setDeviceState("relay2", value);
  }

  void toggleFan() {
    _firebaseService.setDeviceState("fan", !_deviceState.fan);
  }

  void togglePump() {
    _firebaseService.setDeviceState("pump", !_deviceState.pump);
  }

  void toggleAutoMode(bool value) {
    _firebaseService.setDeviceState("autoMode", value);
  }
  void changeServo(int angle) {
    _deviceState = _deviceState.copyWith(servoAngle: angle);
    notifyListeners(); // 🔥 Cập nhật UI
    _firebaseService.setDeviceState("servo", angle);
  }
  void changeThreshold(int value) {
    _deviceState = _deviceState.copyWith(threshold: value);
    notifyListeners(); // 🔥 Cập nhật UI
    _firebaseService.setDeviceState("threshold", value);
  }

}
