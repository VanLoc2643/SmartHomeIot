import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:vanlocapp/services/auth_service.dart';
import 'package:vanlocapp/views/login_screen.dart' as login;
import 'friends_screen.dart';

class AccountScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  void _signOut(BuildContext context) async {
    await _authService.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => login.LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Tài khoản", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: FutureBuilder(
          future: _getUserData(user),
          builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            final userData = snapshot.data;
            final String displayName = userData?['name'] ?? "Người dùng";
            final String profilePic =
                userData?['photoURL'] ?? "assets/default_avatar.png";

            return Column(
              children: [
                SizedBox(height: 30),
                Hero(
                  tag: "profilePic",
                  child: CircleAvatar(
                    backgroundImage: profilePic.startsWith("http")
                        ? NetworkImage(profilePic)
                        : AssetImage(profilePic) as ImageProvider,
                    radius: 50,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Xin chào, $displayName!",
                  style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 30),
                _buildOptionItem(
                  context,
                  icon: Icons.people,
                  title: "Danh sách bạn bè",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FriendsScreen())),
                ),
                _buildOptionItem(
                  context,
                  icon: Icons.logout,
                  title: "Đăng xuất",
                  onTap: () => _showLogoutDialog(context),
                  color: Colors.red,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: ListTile(
          leading: Icon(icon, color: color ?? Colors.black),
          title: Text(title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: color ?? Colors.black)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color ?? Colors.black54),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Đăng xuất", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text("Bạn có chắc chắn muốn đăng xuất?", style: GoogleFonts.montserrat()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy", style: GoogleFonts.montserrat(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Đăng xuất", style: GoogleFonts.montserrat(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _getUserData(User? user) async {
    if (user != null) {
      return {
        'name': user.displayName ?? "Người dùng",
        'photoURL': user.photoURL ?? "assets/default_avatar.png",
      };
    }

    final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      final userData = await FacebookAuth.instance.getUserData();
      return {
        'name': userData['name'],
        'photoURL': userData['picture']['data']['url'],
      };
    }

    return null;
  }
}
