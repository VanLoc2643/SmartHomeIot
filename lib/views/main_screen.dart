import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vanlocapp/services/auth_service.dart';

import 'account_screen.dart';
import 'chat_list_screen.dart';
import 'friend_requests_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  final User? user = FirebaseAuth.instance.currentUser;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      SearchScreen(),
      ChatListScreen(),
      FriendRequestsScreen(),
      SettingsScreen(),
      AccountScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: StreamBuilder<int>(
        stream: _authService.getUnreadMessagesCount(user?.uid ?? ''),
        builder: (context, snapshot) {
          int unreadMessagesCount = snapshot.data ?? 0;

          return StreamBuilder<int>(
            stream: _authService.getPendingFriendRequestsCount(user?.uid ?? ''),
            builder: (context, snapshot) {
              int pendingRequestsCount = snapshot.data ?? 0;

              return BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Trang chủ",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: "Tìm kiếm",
                  ),
                  BottomNavigationBarItem(
                    icon: Stack(
                      children: [
                        Icon(Icons.chat),
                        if (unreadMessagesCount > 0)
                          Positioned(
                            right: 0,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.red,
                              child: Text(
                                unreadMessagesCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: "Nhắn tin",
                  ),
                  BottomNavigationBarItem(
                    icon: Stack(
                      children: [
                        Icon(Icons.person_add),
                        if (pendingRequestsCount > 0)
                          Positioned(
                            right: 0,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.red,
                              child: Text(
                                pendingRequestsCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: "Lời mời kết bạn",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: "Cài đặt",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "Tài khoản",
                  ),
                ],
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
              );
            },
          );
        },
      ),
    );
  }
}
