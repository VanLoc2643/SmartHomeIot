class DeviceState {
  final int mq2Value;
  final bool relay1;
  final bool relay2;
  final int servoAngle;
  final int threshold;
  final bool autoMode;
  final bool fan;
  final bool pump;

  DeviceState({
    required this.mq2Value,
    required this.relay1,
    required this.relay2,
    required this.servoAngle,
    required this.threshold,
    required this.autoMode,
    required this.fan,
    required this.pump,
  });

  factory DeviceState.fromMap(Map<dynamic, dynamic> data) {
    return DeviceState(
      mq2Value: data['mq2Value'] ?? 0,
      relay1: data['relay1'] ?? false,
      relay2: data['relay2'] ?? false,
      servoAngle: data['servoAngle'] ?? 0,
      threshold: data['threshold'] ?? 500,
      autoMode: data['autoMode'] ?? false,
      fan: data['fan'] ?? false,
      pump: data['pump'] ?? false,
    );
  }

  DeviceState copyWith({
    int? mq2Value,
    bool? relay1,
    bool? relay2,
    int? servoAngle,
    int? threshold,
    bool? autoMode,
    bool? fan,
    bool? pump,
  }) {
    return DeviceState(
      mq2Value: mq2Value ?? this.mq2Value,
      relay1: relay1 ?? this.relay1,
      relay2: relay2 ?? this.relay2,
      servoAngle: servoAngle ?? this.servoAngle,
      threshold: threshold ?? this.threshold,
      autoMode: autoMode ?? this.autoMode,
      fan: fan ?? this.fan,
      pump: pump ?? this.pump,
    );
  }
}
