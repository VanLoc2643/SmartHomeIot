import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vanlocapp/viewmodels/home_viewmodel.dart';
import 'package:vanlocapp/widgets/device_controls.dart';
import 'package:vanlocapp/widgets/sensor_display.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Smart Home IoT")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SensorDisplay(deviceState: viewModel.deviceState),
            SizedBox(height: 20),
            DeviceControls(viewModel: viewModel),
          ],
        ),
      ),
    );
  }
}
