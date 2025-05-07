import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;
  FirebaseFirestore get firestore => _firestore;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        throw FirebaseAuthException(
          code: "ERROR_MISSING_GOOGLE_AUTH_TOKEN",
          message: "Không lấy được Google ID Token.",
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("🔥 Lỗi đăng nhập Google: $e");
      return null;
    }
  }

  Future<void> _createUserInFirestore(User? user) async {
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'friends': [],
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  /// 🚀 Đăng nhập Facebook
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );

        // 🔄 Chờ cập nhật FirebaseAuth
        await Future.delayed(Duration(seconds: 2));
        // Tạo người dùng trong Firestore nếu chưa tồn tại
        await _createUserInFirestore(userCredential.user);
        return userCredential.user;
      } else {
        print("❌ Người dùng đã hủy đăng nhập Facebook.");
      }
    } catch (e) {
      print("🔥 Lỗi đăng nhập Facebook: $e");
    }
    return null;
  }

  /// 🚀 Đăng nhập GitHub
  Future<User?> signInWithGitHub() async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();
      UserCredential userCredential = await _auth.signInWithProvider(
        githubProvider,
      );

      // 🔄 Chờ cập nhật FirebaseAuth
      await Future.delayed(Duration(seconds: 2));
      // Tạo người dùng trong Firestore nếu chưa tồn tại
      await _createUserInFirestore(userCredential.user);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Lỗi đăng nhập GitHub: ${e.message}");

      if (e.code == "web-context-canceled") {
        print("Người dùng đã đóng cửa sổ đăng nhập.");
      } else if (e.code == "redirect_uri_mismatch") {
        print("Lỗi Redirect URI: Kiểm tra GitHub Developer Settings.");
      }
      return null;
    }
  }

  /// 🚪 Đăng xuất tài khoản
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await FacebookAuth.instance.logOut();

      print("✅ Đã đăng xuất thành công!");
    } catch (e) {
      print("🔥 Lỗi khi đăng xuất: $e");
    }
  }

  /// 🔍 Tìm kiếm người dùng
  Future<QuerySnapshot> searchUsers(String query) async {
    return _firestore
        .collection("users")
        .where("name", isGreaterThanOrEqualTo: query)
        .get();
  }

  /// 📩 Gửi lời mời kết bạn
  Future<void> sendFriendRequest(String currentUserId, String friendId) async {
    await _firestore
        .collection("friend_requests")
        .doc("$currentUserId\_$friendId")
        .set({
          "from": currentUserId,
          "to": friendId,
          "status": "pending",
          "timestamp": FieldValue.serverTimestamp(),
        });
  }

  Future<void> acceptFriendRequest(
    String currentUserId,
    String friendId,
  ) async {
    final currentUserDoc = _firestore.collection("users").doc(currentUserId);
    final friendDoc = _firestore.collection("users").doc(friendId);

    final currentUserSnapshot = await currentUserDoc.get();
    final friendSnapshot = await friendDoc.get();

    if (!currentUserSnapshot.exists || !friendSnapshot.exists) {
      print("Một trong hai tài liệu người dùng không tồn tại.");
      return;
    }

    await currentUserDoc.update({
      "friends": FieldValue.arrayUnion([friendId]),
    });

    await friendDoc.update({
      "friends": FieldValue.arrayUnion([currentUserId]),
    });

    await _firestore
        .collection("friend_requests")
        .doc("$friendId\_$currentUserId")
        .delete();
  }

  // Future<void> deleteFriendRequest(
  //   String currentUserId,
  //   String friendId,
  // ) async {
  //   try {
  //     await _firestore
  //         .collection("friend_requests")
  //         .doc("$friendId\_$currentUserId")
  //         .delete();
  //     print("✅ Đã xóa lời mời kết bạn thành công!");
  //   } catch (e) {
  //     print("🔥 Lỗi khi xóa lời mời kết bạn: $e");
  //   }
  // }
  Future<void> deleteFriendRequest(
    String currentUserId,
    String friendId,
  ) async {
    try {
      await _firestore
          .collection("friend_requests")
          .doc("$currentUserId\_$friendId")
          .delete();
      print("✅ Đã hủy yêu cầu kết bạn!");
    } catch (e) {
      print("🔥 Lỗi khi hủy yêu cầu kết bạn: $e");
    }
  }

  /// 💬 Lấy danh sách tin nhắn giữa người dùng hiện tại và các người dùng khác
  Stream<QuerySnapshot> getMessages(String senderId, String receiverId) {
    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [senderId, receiverId])
        .where('receiverId', whereIn: [senderId, receiverId])
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// 📜 Lấy danh sách bạn bè
  Stream<DocumentSnapshot> getFriendsList(String userId) {
    return _firestore.collection("users").doc(userId).snapshots();
  }

  Future<void> sendMessage(String receiverId, String content) async {
    final senderId = currentUser?.uid;
    if (senderId == null) return;

    await _firestore.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false, // Thêm trường isRead
    });
  }

  Future<void> markMessagesAsRead(String senderId, String receiverId) async {
    final querySnapshot =
        await _firestore
            .collection('messages')
            .where('senderId', isEqualTo: senderId)
            .where('receiverId', isEqualTo: receiverId)
            .where('isRead', isEqualTo: false)
            .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Stream<int> getUnreadMessagesCount(String userId) {
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getPendingFriendRequestsCount(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('to', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }

  Future<void> markMessageAsUnread(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'isRead': false,
    });
  }

  Future<void> deleteChat(String friendId) async {
    final userId = currentUser?.uid;
    if (userId == null) return;

    final querySnapshot =
        await _firestore
            .collection('messages')
            .where('senderId', whereIn: [userId, friendId])
            .where('receiverId', whereIn: [userId, friendId])
            .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> markChatAsUnread(String friendId) async {
    final userId = currentUser?.uid;
    if (userId == null) return;

    final querySnapshot =
        await _firestore
            .collection('messages')
            .where('senderId', whereIn: [userId, friendId])
            .where('receiverId', whereIn: [userId, friendId])
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isRead': false});
    }
  }

  Future<DocumentSnapshot?> getLatestMessage(
    String userId,
    String friendId,
  ) async {
    final querySnapshot =
        await _firestore
            .collection('messages')
            .where('senderId', whereIn: [userId, friendId])
            .where('receiverId', whereIn: [userId, friendId])
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }
    return null;
  }

  Future<void> removeFriend(String currentUserId, String friendId) async {
    try {
      final currentUserDoc = _firestore.collection("users").doc(currentUserId);
      final friendDoc = _firestore.collection("users").doc(friendId);

      await currentUserDoc.update({
        "friends": FieldValue.arrayRemove([friendId]),
      });

      await friendDoc.update({
        "friends": FieldValue.arrayRemove([currentUserId]),
      });

      print("✅ Đã xóa bạn bè thành công!");
    } catch (e) {
      print("🔥 Lỗi khi xóa bạn bè: $e");
    }
  }
}
