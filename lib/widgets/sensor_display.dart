import 'package:flutter/material.dart';
import 'package:vanlocapp/models/device_state.dart';


class SensorDisplay extends StatelessWidget {
  final DeviceState deviceState;

  SensorDisplay({required this.deviceState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Cảm biến MQ2: ${deviceState.mq2Value}",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "Ngưỡng cháy: ${deviceState.threshold}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
