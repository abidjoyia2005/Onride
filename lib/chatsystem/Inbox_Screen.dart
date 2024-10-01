import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';

class Inbox_Screen extends StatefulWidget {
  String?
      Reciver_Inbox; // Use a specific type (String) for clarity and null safety

  Inbox_Screen({super.key, this.Reciver_Inbox});

  @override
  State<Inbox_Screen> createState() => _Inbox_ScreenState();
}

class _Inbox_ScreenState extends State<Inbox_Screen> {
  late Stream<QuerySnapshot> _inboxStream;

  @override
  void initState() {
    super.initState();
    // Initialize the inbox stream here since you have access to widget.Reciver_Inbox
    _inboxStream = FirebaseFirestore.instance
        .collection('Inbox')
        .doc(User_Id)
        .collection("Inbox")
        .snapshots();

    print("inbox stream :$_inboxStream");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Chat'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _inboxStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!'));
          }

          // Get the list of documents from the snapshot
          final messages = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                for (var message in messages)
                  GestureDetector(
                    onTap: () {
                      // Handle the tap event, e.g., navigate to the detailed chat screen
                    },
                    child: Inbox_Screen_Card(
                      contactName: message['contactName'] ?? 'Unknown',
                      lastMessagePreview:
                          message['lastMessage'] ?? 'No message',
                      time: 'Just now',
                      unreadCount: message['unreadCount'] ?? 0,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Inbox_Screen_Card extends StatelessWidget {
  final String contactName;
  final String lastMessagePreview;
  final String time;
  final int unreadCount;

  const Inbox_Screen_Card({
    Key? key,
    required this.contactName,
    required this.lastMessagePreview,
    required this.time,
    required this.unreadCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      height: 90,
      child: Row(
        children: [
          SizedBox(width: 8),
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  contactName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  lastMessagePreview,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              if (unreadCount > 0)
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount', // Number of unread messages
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}
