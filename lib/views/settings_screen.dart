import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vanlocapp/viewmodels/home_viewmodel.dart';
import 'package:vanlocapp/viewmodels/theme_viewmodel.dart';
import 'package:vanlocapp/widgets/settings_controls.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Cài đặt")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text("Chế độ tối"),
              trailing: Switch(
                value: themeViewModel.isDarkMode,
                onChanged: (value) {
                  themeViewModel.toggleTheme();
                },
              ),
            ),
            SettingsControls(viewModel: homeViewModel),
            Divider(),

          ],
        ),
      ),
    );
  }
}