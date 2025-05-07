import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vanlocapp/services/auth_service.dart';

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final AuthService _authService = AuthService();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lời mời kết bạn")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _authService.firestore
            .collection("friend_requests")
            .where("to", isEqualTo: user?.uid)
            .where("status", isEqualTo: "pending")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return Center(
              child: Text(
                "Không có lời mời kết bạn nào",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final fromUserId = request['from'];

              return FutureBuilder<DocumentSnapshot>(
                future: _authService.firestore.collection("users").doc(fromUserId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListTile(title: Text("Đang tải..."));
                  }

                  if (snapshot.hasError) {
                    return ListTile(title: Text("Lỗi khi tải dữ liệu"));
                  }

                  final userData = snapshot.data;
                  if (userData == null || !userData.exists) {
                    return ListTile(title: Text("Người dùng không tồn tại"));
                  }

                  final userName = userData['name'] ?? 'Người dùng';
                  final userEmail = userData['email'] ?? 'Không có email';
                  final userProfilePicture = userData['photoUrl'] ??
                      'https://www.gravatar.com/avatar/placeholder?s=200&d=mp';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(userProfilePicture),
                        ),
                        title: Text(
                          userName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          userEmail,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check_circle, color: Colors.green, size: 30),
                              onPressed: () {
                                _authService.acceptFriendRequest(user!.uid, fromUserId);
                              },
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red, size: 30),
                              onPressed: () async {
                                await _authService.deleteFriendRequest(user!.uid, fromUserId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Đã xóa lời mời kết bạn")),
                                );
                                setState(() {}); // Cập nhật UI
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
