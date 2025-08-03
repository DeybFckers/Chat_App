import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/services/NotificationApi.dart';

// This class handles user authentication and chat logic
class ChatService {
  // Firebase instances for auth and database
  final firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _firebaseApi = FirebaseApi();

  // Get the currently logged-in Firebase user
  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }

  // Stream<List<Map<String, dynamic>>> means:
  // - This returns a live-updating list of user data.
  // - Each user is represented as a Map (key-value).
  // - The Stream constantly listens to Firestore's "users" collection.
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      // snapshot = live data from Firestore (QuerySnapshot)
      // snapshot.docs = all user documents in the collection

      return snapshot.docs.map((doc) {
        final user = doc.data(); // convert document to Map<String, dynamic>
        user['uid'] = doc.id;    // attach UID from document ID
        return user;             // each user is a Map<String, dynamic>
      }).toList();               // convert to a List
    });
  }

  Future<void>updateUserFCMToken() async{
    try {
      final user = firebaseAuth.currentUser;
      final token = await _firebaseApi.getFCMToken(); // fetch from FirebaseApi

      if (user != null && token != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'lastSeen': Timestamp.now(),
        });
        print('✅ Token updated in Firestore');
      }
    } catch (e) {
      print('❌ Error updating FCM token: $e');
    }
  }

  // Send a message to Firestore under the correct chat_room
  Future<void> sendMessage(String receiverID, String receiverEmail, message) async {
    final String currentUserID = firebaseAuth.currentUser!.uid;
    final String currentUserEmail = firebaseAuth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // Wrap all message data in a Message model
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverEmail: receiverEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // Generate a unique chatRoomID by sorting user IDs
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // ensures uniqueness and consistency
    String chatRoomID = ids.join('_'); // e.g., uid1_uid2

    // Save the message under the correct chat room in Firestore
    _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // Stream<QuerySnapshot>:
  // - Listens to new/updated/deleted messages in a chat room
  // - QuerySnapshot contains multiple DocumentSnapshots (messages)
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots(); // returns a Stream<QuerySnapshot>
  }
}
