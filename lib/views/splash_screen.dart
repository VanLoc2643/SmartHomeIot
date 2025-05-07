import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vanlocapp/assets/constants/app_images.dart';
import 'package:vanlocapp/views/login_screen.dart';
import 'package:vanlocapp/views/main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Chờ 3 giây rồi kiểm tra trạng thái đăng nhập
    Timer(Duration(seconds: 3), () {
      User? user = FirebaseAuth.instance.currentUser;

      // Nếu đã đăng nhập -> vào MainScreen
      // Nếu chưa -> về LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => user != null ? MainScreen() : LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ứng dụng
            Image.asset(AppImages.appLogo, width: 150),
            SizedBox(height: 20),

            // Hiệu ứng loading
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
