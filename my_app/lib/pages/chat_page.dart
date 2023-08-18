import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Twitter/chat/chat_service.dart';

import '../components/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
    const ChatPage({Key? key,
      required this.receiverUserEmail,
      required this.receiverUserID}) 
      : super(key: key);


  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  String? receiverUsername;

  @override
  void initState() {
    super.initState();
    _fetchReceiverUsername();
  }

  Future<void> _fetchReceiverUsername() async {
    final receiverUserDoc =
        await FirebaseFirestore.instance.collection('users').doc(widget.receiverUserID).get();
    setState(() {
      receiverUsername = receiverUserDoc['username'];
    });
  }

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverUserID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(
        receiverUsername ?? 'Loading...',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.black,
    ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),

          const SizedBox(height: 25,),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.receiverUserID, _firebaseAuth.currentUser!.uid
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

    
        return ListView(
          children: snapshot.data!.docs
          .map((document) => _buildMessageItem(document))
          .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return Container(
      alignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
          ? Alignment.centerLeft
          : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.start,
          mainAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['senderId'])
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data != null) {
                    var senderUsername = snapshot.data!['username'];
                    return Text(senderUsername);
                  }
                }
                return const Text('Loading...'); // Return loading text while fetching username
              },
            ),
            const SizedBox(height: 5,),
            ChatBubble(
              message: data['message'],
              backgroundColor: data['senderId'] == _firebaseAuth.currentUser!.uid
                  ? Colors.black
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildMessageItem(DocumentSnapshot document) {
  //   Map<String, dynamic> data = document.data() as Map<String, dynamic>;

  //   var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
  //     ?Alignment.centerLeft
  //     :Alignment.centerLeft;

  //     return Container(
  //       alignment: alignment,
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           crossAxisAlignment: 
  //             (data['senderId'] == _firebaseAuth.currentUser!.uid)
  //             ? CrossAxisAlignment.start
  //             : CrossAxisAlignment.start,
  //           mainAxisAlignment: 
  //             (data['senderId'] == _firebaseAuth.currentUser!.uid)
  //             ? MainAxisAlignment.start
  //             : MainAxisAlignment.start,
  //           children: [
  //             Text(data['senderEmail']),
  //             const SizedBox(height: 5,),
  //             ChatBubble(
  //               message: data['message'],
  //               backgroundColor: data['senderId'] == _firebaseAuth.currentUser!.uid
  //                 ? Colors.black
  //                 : Colors.blue
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  // }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter message',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                fillColor: Colors.grey[300],
                filled: true,
                // hintStyle: const TextStyle(color: Colors.white),
              ),
            ),
          ),
    
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.arrow_upward,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}