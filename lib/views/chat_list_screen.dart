import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanlocapp/services/auth_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách tin nhắn",
            style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _authService.firestore.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _buildShimmerEffect();
          }

          final userData = snapshot.data!;
          final data = userData.data() as Map<String, dynamic>?;

          if (data == null || !data.containsKey('friends') || data['friends'].isEmpty) {
            return Center(
              child: Text("Không có bạn bè nào.",
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700])),
            );
          }

          final friends = data['friends'] as List<dynamic>;

          return ListView.separated(
            itemCount: friends.length,
            separatorBuilder: (context, index) => Divider(height: 0.5, color: Colors.grey[300]),
            itemBuilder: (context, index) {
              final friendId = friends[index];

              return FutureBuilder<DocumentSnapshot>(
                future: _authService.firestore.collection('users').doc(friendId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildShimmerEffect();
                  }

                  final friendData = snapshot.data!;
                  return StreamBuilder<QuerySnapshot>(
                    stream: _authService.firestore
                        .collection('messages')
                        .where('senderId', whereIn: [user?.uid, friendId])
                        .where('receiverId', whereIn: [user?.uid, friendId])
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return _buildShimmerEffect();

                      final messages = snapshot.data!.docs;
                      final latestMessage = messages.isNotEmpty ? messages.first : null;
                      final latestMessageContent = latestMessage != null ? latestMessage['content'] : "Chưa có tin nhắn";
                      final isRead = latestMessage != null ? latestMessage['isRead'] : true;

                      Timestamp? timestamp = latestMessage?['timestamp'];
                      String time = timestamp != null
                          ? DateFormat('HH:mm').format(timestamp.toDate())
                          : '';

                      return Slidable(
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                _authService.deleteChat(friendId);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đoạn chat đã bị xóa')));
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Xóa',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                _authService.markChatAsUnread(friendId);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text('Đã đánh dấu là chưa đọc')));
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.mark_chat_unread,
                              label: 'Chưa đọc',
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: friendData['photoUrl'] != null
                                ? NetworkImage(friendData['photoUrl'])
                                : null,
                            backgroundColor: Colors.grey[200],
                            child: friendData['photoUrl'] == null
                                ? Icon(Icons.person, color: Colors.grey[600])
                                : null,
                          ),
                          title: Text(
                            friendData['name'] ?? "Người dùng",
                            style: GoogleFonts.montserrat(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  latestMessageContent,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                time,
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                          onTap: () {
                            _authService.markMessagesAsRead(user!.uid, friendId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChatScreen(receiverId: friendId)),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: CircleAvatar(radius: 28, backgroundColor: Colors.white),
            title: Container(height: 15, width: 100, color: Colors.white),
            subtitle: Container(height: 10, width: 150, color: Colors.white),
          ),
        );
      },
    );
  }
}
