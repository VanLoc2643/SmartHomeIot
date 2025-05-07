import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vanlocapp/services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;

  ChatScreen({required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<DocumentSnapshot> _receiverFuture;

  @override
  void initState() {
    super.initState();
    _receiverFuture =
        _authService.firestore.collection('users').doc(widget.receiverId).get();
    _markMessagesAsRead();
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _authService.sendMessage(widget.receiverId, message);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _markMessagesAsRead() {
    final String senderId = _authService.currentUser!.uid;
    _authService.markMessagesAsRead(widget.receiverId, senderId);
  }

  @override
  Widget build(BuildContext context) {
    final String senderId = _authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: FutureBuilder<DocumentSnapshot>(
          future: _receiverFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text("Loading...", style: TextStyle(color: Colors.black));
            if (snapshot.hasError) return Text("Error", style: TextStyle(color: Colors.black));

            final userData = snapshot.data;
            if (userData == null || !userData.exists) return Text("User not found", style: TextStyle(color: Colors.black));

            final userName = userData['name'] ?? 'Người dùng';
            final userProfilePicture = userData['photoUrl'] ?? '';

            return Row(
              children: [
                CircleAvatar(
                  backgroundImage: userProfilePicture.isNotEmpty ? NetworkImage(userProfilePicture) : null,
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(width: 10),
                Text(userName, style: TextStyle(color: Colors.black)),
              ],
            );
          },
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _authService.getMessages(senderId, widget.receiverId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == senderId;
                    Timestamp? timestamp = message['timestamp'] as Timestamp?;
                    DateTime dateTime = timestamp != null ? timestamp.toDate() : DateTime.now();
                    String time = DateFormat('HH:mm').format(dateTime);

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isMe) // Avatar người nhận
                            FutureBuilder<DocumentSnapshot>(
                              future: _receiverFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return SizedBox();
                                final userData = snapshot.data;
                                final userProfilePicture = userData?['photoUrl'] ?? '';

                                return Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: CircleAvatar(
                                    backgroundImage: userProfilePicture.isNotEmpty
                                        ? NetworkImage(userProfilePicture)
                                        : null,
                                    backgroundColor: Colors.grey[300],
                                    radius: 18,
                                  ),
                                );
                              },
                            ),
                          Container(
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.symmetric(vertical: 4),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blueAccent : Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                                bottomLeft: isMe ? Radius.circular(12) : Radius.zero,
                                bottomRight: isMe ? Radius.zero : Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  message['content'],
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  time,
                                  style: TextStyle(fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.image, color: Colors.blue),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: "Nhập tin nhắn...",
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 24,
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
