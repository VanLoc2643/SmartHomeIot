import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vanlocapp/assets/constants/app_images.dart';
import 'package:vanlocapp/services/auth_service.dart';
import 'package:vanlocapp/views/main_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  void _handleSignIn(BuildContext context, String method) async {
    User? user;
    if (method == "google") {
      user = await _authService.signInWithGoogle();
    } else if (method == "facebook") {
      user = await _authService.signInWithFacebook();
    } else if (method == "github") {
      user = await _authService.signInWithGitHub();
    }

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập thất bại! Vui lòng thử lại.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ảnh nền
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay mờ giúp dễ nhìn hơn
          Container(color: Colors.black.withOpacity(0.2)),

          // Nội dung chính
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo ứng dụng
                CircleAvatar(
                  backgroundImage: AssetImage(AppImages.appLogo),
                  radius: 80,
                ),
                SizedBox(height: 20),

                // Tiêu đề
                Text(
                  "Đăng nhập để tiếp tục",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),

                // Các nút đăng nhập
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nút đăng nhập Google
                    ElevatedButton.icon(
                      onPressed: () => _handleSignIn(context, "google"),
                      icon: Image.asset(AppImages.googleLogo, height: 24),
                      label: Text("Google"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 30,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                    // Nút đăng nhập Facebook
                    ElevatedButton.icon(
                      onPressed: () => _handleSignIn(context, "facebook"),
                      icon: Image.asset(AppImages.facebookLogo, height: 24),
                      label: Text("Facebook"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                    // Nút đăng nhập GitHub
                    ElevatedButton.icon(
                      onPressed: () => _handleSignIn(context, "github"),
                      icon: Image.asset(AppImages.githubLogo, height: 24),
                      label: Text("GitHub"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
