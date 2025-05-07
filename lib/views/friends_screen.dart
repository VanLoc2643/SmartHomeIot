import 'package:flutter/material.dart';
import 'package:vanlocapp/services/firestore_service.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  void _loadFriends() async {
    try {
      List<Map<String, dynamic>> friendsList =
          await _firestoreService.getFriendsList();
      setState(() {
        _friends =
            friendsList.map((friend) {
              return {
                'id': friend['id'] ?? '',
                'name': friend['name'] ?? 'Người dùng',
                'email': friend['email'] ?? 'Không có email',
                'photoUrl': friend['photoUrl'] ?? '',
              };
            }).toList();
      });
    } catch (e) {
      print("Lỗi khi tải danh sách bạn bè: $e");
    }
  }

  void _showDeleteFriendDialog(BuildContext context, String friendId) {
    if (friendId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Không thể xóa bạn bè này")));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Xóa bạn bè"),
          content: Text(
            "Bạn có chắc muốn xóa người này khỏi danh sách bạn bè không?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _firestoreService.removeFriend(friendId);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã xóa bạn bè thành công")),
                  );
                  _loadFriends(); // Cập nhật danh sách bạn bè
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi khi xóa bạn bè: $e")),
                  );
                }
              },
              child: Text("Xóa", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Danh sách bạn bè")),
      body:
          _friends.isEmpty
              ? Center(child: Text("Bạn không có bạn bè nào"))
              : ListView.builder(
                itemCount: _friends.length,
                itemBuilder: (context, index) {
                  final friend = _friends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          friend['photoUrl'] != ''
                              ? NetworkImage(friend['photoUrl'])
                              : null,
                      backgroundColor: Colors.grey[200],
                      child:
                          friend['photoUrl'] == ''
                              ? Icon(Icons.person, color: Colors.grey[600])
                              : null,
                    ),
                    title: Text(friend['name']),
                    subtitle: Text(friend['email']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteFriendDialog(context, friend['id']);
                      },
                    ),
                  );
                },
              ),
    );
  }
}
