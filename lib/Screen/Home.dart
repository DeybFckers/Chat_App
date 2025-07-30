import 'package:chat_app/Screen/ChatPage.dart';
import 'package:chat_app/services/Chat_service.dart';
import 'package:chat_app/widgets/MyDrawer.dart';
import 'package:chat_app/widgets/UserTile.dart';
import 'package:flutter/material.dart';

// The Home screen shows a list of all users except the currently logged-in user.
class Home extends StatelessWidget {
  // These values are passed from the SignIn page
  final String uid;       // current user's UID
  final String name;      // current user's name
  final String email;     // current user's email
  final String photoUrl;  // current user's avatar URL

  // Constructor to receive the above values
  Home({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  // Instance of ChatService to access Firestore and auth logic
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Home',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      // Side drawer showing user info
      drawer: myDrawer(Image: photoUrl, name: name, email: email),

      // Main content: list of users
      body: _buildUserList(),
    );
  }

  // Builds a live-updating list of users from Firestore
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStream(), // listens to "users" collection
      builder: (context, snapshot) {
        // If there's an error with the stream
        if (snapshot.hasError) {
          return Text("Error");
        }

        // While the stream is loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        // Once data is ready, build a list of user tiles
        return ListView(
          children: snapshot.data!
          // Remove current user from the list
              .where((userData) => userData['uid'] != uid)
          // Create a user tile for each remaining user
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // Builds a single user's tile (except the current user)
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
      return UserTile(
        text: userData["Name"],
        Image: userData["Photo"],// display name
        onTap: () {
          // Navigate to ChatPage when user is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverName: userData["Name"],
                receiverImage: userData["Photo"],
                receiverID: userData["uid"],
                receiverEmail: userData["Email"],// pass receiver info
              ),
            ),
          );
        },
      );
  }
}
