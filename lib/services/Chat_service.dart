import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// This class handles user authentication and user data retrieval from Firestore.
class ChatService {
  // Firebase Authentication instance to access current user
  final firebaseAuth = FirebaseAuth.instance;

  // Firebase Firestore instance to access user data
  final _firestore = FirebaseFirestore.instance;

  // Returns the currently logged-in Firebase user
  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }

  // This stream continuously listens to all documents in the "users" collection
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      // For each document (user), extract data and add 'uid' (doc.id)
      return snapshot.docs.map((doc) {
        final user = doc.data();
        user['uid'] = doc.id; // Attach the UID from Firestore document ID
        return user;
      }).toList(); // Convert the Iterable to a List
    });
  }

  //send message
  Future<void> sendMessage(String receiverID, String receiverEmail, message) async{
    //get current user info
    final String currentUserID = firebaseAuth.currentUser!.uid;
    final String currentUserEmail = firebaseAuth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverEmail: receiverEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
    );

    //construct chat roomID for the two users sorted to ensure uniqueness
    List<String> ids = [currentUserID, receiverID];
    ids.sort();// sort the ids (this ensure the chatroomID is the same for any people)
    String chatRoomID = ids.join('_');

    //add new message to data
    _firestore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .add(newMessage.toMap());

  }
  //get messages
  Stream<QuerySnapshot>getMessages(String userID, otherUserID){
    //construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
