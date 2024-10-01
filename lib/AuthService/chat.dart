import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For formatting timestamps

class GroupFromTo extends StatefulWidget {
  final String hasFromTo; // Pass Has_From_To as a parameter

  GroupFromTo({required this.hasFromTo}); // Constructor

  @override
  _GroupFromToState createState() => _GroupFromToState();
}

class _GroupFromToState extends State<GroupFromTo> {
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
          .collection('Vicahle')
          .doc(widget.hasFromTo) // Use the passed value
          .collection("message")
          .add({
        'text': _controller.text,
        'sender': userEmail!,
        'profilePicUrl': userProfilePicUrl ?? 'default_profile_pic_url',
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
      _scrollToBottom();
    }
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
                  .collection('Vicahle')
                  .doc(widget.hasFromTo)
                  .collection("message")
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
                        : 'N/A';
                    final date = timestamp != null
                        ? DateFormat('dd/MM/yyyy').format(timestamp.toDate())
                        : 'N/A'; // Format date and time

                    if (isCurrentUser) {
                      // Sent message by the current user
                      return SentMessageBubble(
                        message: messageText,
                        time: time,
                        date: date,
                        profilePicUrl:
                            userProfilePicUrl ?? 'default_profile_pic_url',
                      );
                    } else {
                      // Received message from others
                      return ReceivedMessageBubble(
                        message: messageText,
                        time: time,
                        date: date,
                        sender: message['sender'],
                        profilePicUrl: message['profilePicUrl'],
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
  final String date;
  final String profilePicUrl;

  const SentMessageBubble({
    required this.message,
    required this.time,
    required this.date,
    required this.profilePicUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.green[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            date,
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            time,
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(profilePicUrl),
          ),
        ],
      ),
    );
  }
}

class ReceivedMessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final String date;
  final String sender;
  final String profilePicUrl;

  const ReceivedMessageBubble({
    required this.message,
    required this.time,
    required this.date,
    required this.sender,
    required this.profilePicUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(profilePicUrl),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sender,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            date,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                          Text(
                            time,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
