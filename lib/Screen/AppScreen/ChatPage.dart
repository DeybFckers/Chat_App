import 'package:chat_app/Theme/Theme_provider.dart';
import 'package:chat_app/services/Chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// This page displays the chat screen between the current user and a receiver.
class ChatPage extends StatelessWidget {
  // Chat partner's information passed from previous screen
  final String receiverName;
  final String receiverImage;
  final String receiverID;
  final String receiverEmail;

  // Constructor with required parameters
  ChatPage({
    super.key,
    required this.receiverName,
    required this.receiverImage,
    required this.receiverID,
    required this.receiverEmail,
  });

  // Controller for message input field
  final _messageController = TextEditingController();

  // Instance of ChatService to handle sending and fetching messages
  final ChatService _chatService = ChatService();

  // Function to send message
  void sendMessage() async {
    // Only send if message is not empty
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        receiverID,
        receiverEmail,
        _messageController.text,
      );

      // Clear the input after sending
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar showing the chat partner's avatar and name
      appBar: AppBar(
        title: Row(
          children: [
            // Display receiver's profile image
            CircleAvatar(
              backgroundImage: NetworkImage(receiverImage),
            ),
            SizedBox(width: 12),
            // Display receiver's name
            Text(receiverName),
          ],
        ),
        backgroundColor: Colors.blue,
      ),

      // Body contains message list and input field
      body: Column(
        children: [
          // Message list fills the remaining screen
          Expanded(child: _buildMessageList()),

          // Message input field at the bottom
          _buildUserInput(),
        ],
      ),
    );
  }

  // Builds the list of messages using a StreamBuilder (real-time updates)
  Widget _buildMessageList() {
    // Get the current user ID (sender)
    String senderID = _chatService.getCurrentUser()!.uid;

    // Listen to the chat messages using a Firestore stream
    return StreamBuilder(
      stream: _chatService.getMessages(receiverID, senderID),
      builder: (context, snapshot) {
        // If there's an error in the stream
        if (snapshot.hasError) {
          return Text('Error');
        }

        // If the connection is still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading...");
        }

        // Once data is available, show the list of messages
        return ListView(
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(context, doc))
              .toList(),
        );
      },
    );
  }

  // Builds a single chat message item
  Widget _buildMessageItem(BuildContext context,DocumentSnapshot doc) {
    // Convert Firestore document to Map
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Check if the current user sent the message
    bool isCurrentUser = data ['senderID'] == _chatService.getCurrentUser()!.uid;

    // Set alignment based on sender
    var messageAlignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    CrossAxisAlignment columnAlignment = isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    MainAxisAlignment rowAlignment = isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start;

    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    //color definitions
    Color senderBgColor = isDarkMode ? Colors.blue : Colors.blue;
    Color senderTextColor = Colors.white;

    Color receiverBgColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    Color receiverTextColor = isDarkMode ? Colors.white : Colors.black;


    //last touch
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Align(
        alignment: messageAlignment,
        child: Column(
          crossAxisAlignment: columnAlignment,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: rowAlignment,
              children: isCurrentUser
              ? [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: senderBgColor,
                    ),
                    child: Text(
                      data['message'] ?? '',
                      style: TextStyle(color: senderTextColor),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(
                    data['Photo'] ?? 'https://via.placeholder.com/150',
                  ),
                ),
              ]
                : [
                  //avatar first in left side
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(data['Photo']?? 'https://via.placeholder.com/150'),
                ),
                SizedBox(width: 8),
                Flexible(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: receiverBgColor,
                      ),
                      child: Text(data['message']?? '',
                        style: TextStyle(color: receiverTextColor),
                      ),
                    ),
                )
              ]
            ),
          ],
        ),
      ),
    );
  }

  // Builds the user input row (TextField + Send Button)
  Widget _buildUserInput() {
    return Row(
      children: [
        // Message input field takes most of the space
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
            child: TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ),

        // Send button
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: IconButton(
            onPressed: sendMessage,
            icon: Icon(Icons.arrow_upward,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
