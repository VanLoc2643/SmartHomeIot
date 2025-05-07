import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanlocapp/viewmodels/home_viewmodel.dart';

class DeviceControls extends StatelessWidget {
  final HomeViewModel viewModel;

  DeviceControls({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMQ2Chart(),
        SizedBox(height: 20),
        _buildControlCard(
          title: "Relay 1",
          value: viewModel.deviceState.relay1,
          onChanged: viewModel.toggleRelay1,
        ),
        _buildControlCard(
          title: "Relay 2",
          value: viewModel.deviceState.relay2,
          onChanged: viewModel.toggleRelay2,
        ),
        SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildActionButton(
                title: viewModel.deviceState.fan ? "Tắt quạt" : "Bật quạt",
                onPressed: viewModel.toggleFan,
                color:
                    viewModel.deviceState.fan
                        ? Colors.redAccent
                        : Colors.deepPurple,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                title:
                    viewModel.deviceState.pump ? "Tắt máy bơm" : "Bật máy bơm",
                onPressed: viewModel.togglePump,
                color:
                    viewModel.deviceState.pump
                        ? Colors.redAccent
                        : Colors.deepPurple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMQ2Chart() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Giá trị cảm biến MQ2",
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(

                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        viewModel.mq2History.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.toDouble(),
                          ); // 🔥 Fix lỗi
                        }).toList(),
                    isCurved: true,
                    color: Colors.deepPurple,
                    barWidth: 5,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.deepPurple.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          FlutterSwitch(
            value: value,
            onToggle: onChanged,
            activeColor: Colors.deepPurple,
            inactiveColor: Colors.grey.shade400,
            toggleSize: 22,
            width: 55,
            height: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 6,
          shadowColor: Colors.black45,
        ),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
