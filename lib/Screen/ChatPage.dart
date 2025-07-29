import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String receiverName;

  const ChatPage({super.key, required this.receiverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverName),
      ),
    );
  }
}
