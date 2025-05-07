import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:vanlocapp/viewmodels/home_viewmodel.dart';

class SettingsControls extends StatelessWidget {
  final HomeViewModel viewModel;

  SettingsControls({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chế độ tự động
        Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Chế độ tự động",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              FlutterSwitch(
                value: viewModel.deviceState.autoMode,
                onToggle: viewModel.toggleAutoMode,
                activeColor: Colors.deepPurple,
                inactiveColor: Colors.grey,
                toggleSize: 20,
                width: 50,
                height: 25,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Ngưỡng khói
        Text(
          "Ngưỡng khói: ${viewModel.deviceState.threshold}",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.deepPurple,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.deepPurple,
            overlayColor: Colors.deepPurple.withOpacity(0.2),
            valueIndicatorColor: Colors.deepPurple,
          ),
          child: Slider(
            value: viewModel.deviceState.threshold.toDouble(),
            min: 100,
            max: 1000,
            divisions: 18,
            label: "${viewModel.deviceState.threshold}",
            onChanged: (value) => viewModel.changeThreshold(value.toInt()),
          ),
        ),
        SizedBox(height: 10),

        // Góc Servo với Slider tròn
        Text(
          "Góc Servo",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Center(
          child: SleekCircularSlider(
            appearance: CircularSliderAppearance(
              size: 120,
              customWidths: CustomSliderWidths(
                trackWidth: 5,
                progressBarWidth: 10,
                shadowWidth: 2,
              ),
              customColors: CustomSliderColors(
                trackColor: Colors.grey[300]!,
                progressBarColor: Colors.deepPurple,
                shadowColor: Colors.deepPurple.withOpacity(0.2),
                shadowMaxOpacity: 0.2,
                dotColor: Colors.white,
              ),
            ),
            initialValue: viewModel.deviceState.servoAngle.toDouble(),
            min: 0,
            max: 180,
            onChangeEnd: (value) => viewModel.changeServo(value.toInt()),
          ),
        ),
        SizedBox(height: 30),

        // Nút mở cửa/đóng cửa
        Center(
          child: ElevatedButton(
            onPressed: () {
              int newAngle = viewModel.deviceState.servoAngle < 90 ? 180 : 0;
              viewModel.changeServo(newAngle);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
              elevation: 5,
            ),
            child: Text(
              viewModel.deviceState.servoAngle < 90 ? "Mở cửa" : "Đóng cửa",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
