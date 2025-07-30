import 'package:chat_app/services/Chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String receiverName;
  final String receiverImage;
  final String receiverID;
  final String receiverEmail;

  ChatPage({super.key, required this.receiverName, required this.receiverImage, required this.receiverID, required this.receiverEmail});

  final _messageController = TextEditingController();

  //chat & auth services
  final ChatService _chatService = ChatService();

  void sendMessage() async{
    //if there is something inside the textfield
    if(_messageController.text.isNotEmpty){
      //send the message
      await _chatService.sendMessage(receiverID, receiverEmail, _messageController.text);

      //clear text controller
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            //Image
            CircleAvatar(
              backgroundImage: NetworkImage(receiverImage),
            ),

            SizedBox(width: 12,),

            //Name
            Text(receiverName),

          ],
        )
      ),
      body: Column(
        children: [
          // display all messages
          Expanded(
              child: _buildMessageList(),
          ),

          //user input
          _buildUserInput(),
        ],
      ),
    );
  }

  // build message list
  Widget _buildMessageList(){
    String senderID = _chatService.getCurrentUser()!.uid;
    return StreamBuilder(
        stream: _chatService.getMessages(receiverID, senderID),
        builder: (context, snapshot){
          //error
          if(snapshot.hasError){
            return Text('Error');
          }
          //loading
          if(snapshot.connectionState == ConnectionState.waiting){
            return Text("Loading...");
          }
          //display the data
          return ListView(
            children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
          );
        }
    );
  }

  //build message Item
  Widget _buildMessageItem(DocumentSnapshot doc){
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Text(data["message"]);
  }

  //build message input
  Widget _buildUserInput(){
    return Row(
      children: [
        //textfield should take up most of the space
        Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
              child: TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    )
                ),
              ),
            )
        ),
        IconButton(onPressed: sendMessage, icon: Icon(Icons.arrow_upward))
      ],
    );
  }
}
