import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:intl/intl.dart'; // For formatting timestamps

class Chat_Screen_Inbox extends StatefulWidget {
  var to_user_id;
  Chat_Screen_Inbox({this.to_user_id});
  @override
  _Chat_Screen_InboxState createState() => _Chat_Screen_InboxState();
}

class _Chat_Screen_InboxState extends State<Chat_Screen_Inbox> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  User? currentUser;
  String? userEmail;
  String? userProfilePicUrl;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _scrollToBottom();
  }

  Future<void> _getUserInfo() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userEmail = currentUser!.email; // Get user email
        userProfilePicUrl = currentUser!.photoURL ??
            'https://www.example.com/default_profile_pic.png'; // Get profile picture, provide a default if null
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && userEmail != null) {
      _firestore
          .collection('chats')
          .doc("$User_Id ${widget.to_user_id}") // Use the passed value
          .collection("chats")
          .add({
        'text': _controller.text,
        'sender': userEmail!,
        'profilePicUrl': userProfilePicUrl ?? 'default_profile_pic_url',
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
      _scrollToBottom();
    }

    _firestore
        .collection('Inbox')
        .doc(User_Id) // Use the passed value
        .collection("Inbox")
        .doc(User_Id) // Specify the user document
        .set({
      'contactName': _controller.text,
      'lastMessage': userEmail!,
      'unreadCount': userProfilePicUrl ?? 'default_profile_pic_url',
      'time': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _controller.clear();

    _firestore
        .collection('Inbox')
        .doc(widget.to_user_id) // Use the passed value
        .collection("Inbox")
        .doc(User_Id) // Specify the user document
        .set({
      'contactName': _controller.text,
      'lastMessage': userEmail!,
      'unreadCount': userProfilePicUrl ?? 'default_profile_pic_url',
      'time': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _controller.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Additional options can be added here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc("$User_Id ${widget.to_user_id}")
                  .collection("chats")
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message['sender'] == userEmail;
                    final messageText = message['text'];
                    final timestamp = message['timestamp'] as Timestamp?;
                    final time = timestamp != null
                        ? DateFormat('hh:mm a').format(timestamp.toDate())
                        : 'N/A'; // Format the timestamp to a readable time string

                    if (isCurrentUser) {
                      // Sent message by the current user
                      return SentMessageBubble(
                        message: messageText,
                        time: time,
                      );
                    } else {
                      // Received message from others
                      return ReceivedMessageBubble(
                        message: messageText,
                        time: time,
                      );
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Send a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SentMessageBubble extends StatelessWidget {
  final String message;
  final String time;

  const SentMessageBubble({
    required this.message,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.green[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceivedMessageBubble extends StatelessWidget {
  final String message;
  final String time;

  const ReceivedMessageBubble({
    required this.message,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
