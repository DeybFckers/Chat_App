import 'package:chat_app/Screen/AppScreen/ChatPage.dart';
import 'package:chat_app/services/Chat_service.dart';
import 'package:chat_app/widgets/MyDrawer.dart';
import 'package:chat_app/widgets/UserTile.dart';
import 'package:flutter/material.dart';

// Home screen: displays a list of all users except the currently logged-in user.
class Home extends StatefulWidget {
  // These values are passed from the SignIn page
  final String uid;       // Current user's UID
  final String name;      // Current user's name
  final String email;     // Current user's email
  final String photoUrl;  // Current user's avatar URL

  // Constructor
  Home({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Instance of ChatService: gives access to Firebase methods
  final ChatService _chatService = ChatService();

  @override
  void initState(){
    super.initState();
    _chatService.updateUserFCMToken();
  }

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

      // Custom Drawer widget to show user info (name, email, photo)
      drawer: myDrawer(uid:widget.uid, Image: widget.photoUrl, name: widget.name, email: widget.email),

      // The body shows the list of users in real time
      body: _buildUserList(),
    );
  }

  // Builds a real-time list of users using StreamBuilder
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStream(), // Stream<List<Map<String, dynamic>>>
      builder: (context, snapshot) {
        // 🔴 If there's an error while reading from the stream
        if (snapshot.hasError) {
          return Text("Error");
        }

        // 🟡 While the connection is still loading data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        // ✅ When data is received, display it as a list
        return ListView(
          children: snapshot.data!
          // Filter out the current user
              .where((userData) => userData['uid'] != widget.uid)

          // For each remaining user, build a tile
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // This builds a single user tile
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    return UserTile(
      text: userData["Name"],         // Display user's name
      Image: userData["Photo"],       // Display user's profile picture
      onTap: () {
        // 🔁 Navigate to the ChatPage, passing the selected user's info
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverName: userData["Name"],
              receiverImage: userData["Photo"],
              receiverID: userData["uid"],
              receiverEmail: userData["Email"],
            ),
          ),
        );
      },
    );
  }
}
