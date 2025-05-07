import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // ✅ THÊM DÒNG NÀY
  /// Lấy UID của người dùng hiện tại
  String getCurrentUserId() {
    return _auth.currentUser!.uid;
  }

  /// 🔍 Tìm kiếm người dùng theo tên hoặc email
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final usersRef = _firestore.collection('users');

    // Tìm kiếm theo tên hoặc email
    QuerySnapshot nameSearch =
        await usersRef.where('name', isGreaterThanOrEqualTo: query).get();
    QuerySnapshot emailSearch =
        await usersRef.where('email', isEqualTo: query).get();

    // Kết hợp kết quả tìm kiếm
    List<Map<String, dynamic>> results = [];
    for (var doc in nameSearch.docs) {
      results.add(doc.data() as Map<String, dynamic>);
    }
    for (var doc in emailSearch.docs) {
      if (!results.any((user) => user['uid'] == doc['uid'])) {
        results.add(doc.data() as Map<String, dynamic>);
      }
    }

    return results;
  }

  /// ✉️ Gửi lời mời kết bạn
  Future<void> sendFriendRequest(String receiverId) async {
    String currentUserId = _auth.currentUser!.uid;

    DocumentReference requestRef = _firestore
        .collection('friend_requests')
        .doc("${currentUserId}_$receiverId");

    await requestRef.set({
      "from": currentUserId,
      "to": receiverId,
      "status": "pending",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  // ✅ Chấp nhận lời mời kết bạn
  Future<void> acceptFriendRequest(String requestId, String senderId) async {
    String currentUserId = _auth.currentUser!.uid;

    // Cập nhật trạng thái lời mời kết bạn
    await _firestore.collection('friend_requests').doc(requestId).update({
      "status": "accepted",
    });

    // Cập nhật danh sách bạn bè
    await _firestore.collection('users').doc(currentUserId).update({
      "friends": FieldValue.arrayUnion([senderId]),
    });

    await _firestore.collection('users').doc(senderId).update({
      "friends": FieldValue.arrayUnion([currentUserId]),
    });
  }

  /// ❌ Từ chối lời mời kết bạn
  Future<void> rejectFriendRequest(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).delete();
  }

  // /// 👫 Lấy danh sách bạn bè của user hiện tại
  // Future<List<Map<String, dynamic>>> getFriendsList() async {
  //   String currentUserId = _auth.currentUser!.uid;
  //   DocumentSnapshot userDoc =
  //       await _firestore.collection('users').doc(currentUserId).get();

  //   List<dynamic> friendsIds =
  //       (userDoc.data() as Map<String, dynamic>)["friends"] ?? [];

  //   List<Map<String, dynamic>> friendsList = [];
  //   for (String friendId in friendsIds) {
  //     DocumentSnapshot friendDoc =
  //         await _firestore.collection('users').doc(friendId).get();
  //     friendsList.add(friendDoc.data() as Map<String, dynamic>);
  //   }

  //   return friendsList;
  // }
  Future<List<Map<String, dynamic>>> getFriendsList() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final userDoc =
        await _firestore.collection("users").doc(currentUser.uid).get();
    final friends = userDoc.data()?['friends'] ?? [];

    List<Map<String, dynamic>> friendsList = [];
    for (String friendId in friends) {
      final friendDoc =
          await _firestore.collection("users").doc(friendId).get();
      if (friendDoc.exists) {
        friendsList.add({
          'id': friendId,
          'name': friendDoc.data()?['name'] ?? 'Người dùng',
          'email': friendDoc.data()?['email'] ?? 'Không có email',
          'photoUrl': friendDoc.data()?['photoUrl'] ?? '',
        });
      }
    }
    return friendsList;
  }

  /// ✉️ Gửi tin nhắn
  Future<void> sendMessage(String receiverId, String content) async {
    String senderId = _auth.currentUser!.uid;

    await _firestore.collection('messages').add({
      "senderId": senderId,
      "receiverId": receiverId,
      "content": content,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  /// 📨 Lấy danh sách tin nhắn giữa 2 người dùng (sắp xếp theo timestamp)
  Stream<QuerySnapshot> getMessages(String friendId) {
    String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [currentUserId, friendId])
        .where('receiverId', whereIn: [currentUserId, friendId])
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// 👫 Lấy danh sách cuộc trò chuyện (người dùng đã nhắn tin)
  Stream<List<Map<String, dynamic>>> getChatList() {
    String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('messages')
        .where('senderId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          Set<String> uniqueFriendIds = {};

          for (var doc in snapshot.docs) {
            uniqueFriendIds.add(doc['receiverId']);
          }

          List<Map<String, dynamic>> friends = [];
          for (String friendId in uniqueFriendIds) {
            DocumentSnapshot userDoc =
                await _firestore.collection('users').doc(friendId).get();
            friends.add(userDoc.data() as Map<String, dynamic>);
          }
          return friends;
        });
  }

  Future<void> removeFriend(String friendId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserDoc = _firestore.collection("users").doc(currentUser.uid);
    final friendDoc = _firestore.collection("users").doc(friendId);

    await currentUserDoc.update({
      "friends": FieldValue.arrayRemove([friendId]),
    });

    await friendDoc.update({
      "friends": FieldValue.arrayRemove([currentUser.uid]),
    });

    print("✅ Đã xóa bạn bè thành công!");
  }
}
