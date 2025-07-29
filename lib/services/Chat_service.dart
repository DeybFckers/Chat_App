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
}
