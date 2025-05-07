import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanlocapp/services/auth_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  bool _isLoading = false;

  void _searchUsers() async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      setState(() => _isLoading = true);
      final results = await _authService.searchUsers(query);
      setState(() {
        _searchResults = results.docs;
        _isLoading = false;
      });
    }
  }

  Future<bool> _isFriendRequestSent(String friendId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    final request = await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc("${currentUser.uid}_$friendId")
        .get();

    return request.exists;
  }

  void _toggleFriendRequest(String friendId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final isSent = await _isFriendRequestSent(friendId);

    if (isSent) {
      // Hủy yêu cầu kết bạn
      await _authService.deleteFriendRequest(currentUser.uid, friendId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Đã hủy yêu cầu kết bạn!"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Gửi yêu cầu kết bạn
      await _authService.sendFriendRequest(currentUser.uid, friendId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Đã gửi yêu cầu kết bạn!"),
          backgroundColor: Colors.green,
        ),
      );
    }

    setState(() {}); // Cập nhật giao diện
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "🔍 Tìm kiếm bạn bè",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.montserrat(),
                decoration: InputDecoration(
                  hintText: "🔍 Nhập tên người dùng...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.blueAccent),
                    onPressed: _searchUsers,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildShimmerLoading()
                : _searchResults.isEmpty
                ? Center(
              child: Text(
                "Không tìm thấy kết quả!",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return _buildUserTile(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(DocumentSnapshot user) {
    return FutureBuilder<bool>(
      future: _isFriendRequestSent(user['uid']),
      builder: (context, snapshot) {
        final isSent = snapshot.data ?? false;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                user['photoUrl'] ?? "https://via.placeholder.com/150",
              ),
              radius: 25,
            ),
            title: Text(
              user['name'],
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              user['email'],
              style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSent ? Colors.grey : Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _toggleFriendRequest(user['uid']),
              child: Text(
                isSent ? "Đã gửi yêu cầu" : "Kết bạn",
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25,
                ),
                title: Container(height: 10, color: Colors.white),
                subtitle: Container(height: 10, color: Colors.white),
                trailing: Container(width: 60, height: 20, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}