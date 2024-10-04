import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:flutter_application_1/AuthService/Notification.dart';
import 'package:intl/intl.dart'; // For formatting timestamps

class Chat_Screen_Inbox extends StatefulWidget {
  var to_profilepic;
  var to_user_name;
  var to_user_id;
  Chat_Screen_Inbox(
      {required this.to_user_id,
      required this.to_profilepic,
      required this.to_user_name});
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
    _firestore
        .collection('Inbox')
        .doc(User_Id) // Use the passed value
        .collection("Inbox")
        .doc(widget.to_user_id) // Specify the user document
        .set({
      'unreadCount': 0,
    }, SetOptions(merge: true));
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

  var To_User_FCMToken;
  Future<void> GetFCMTokenfromDataBase(String userIdForGetToken) async {
    // Fetch the document snapshot from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('User_Data')
        .doc(userIdForGetToken)
        .get();

    if (userDoc.exists) {
      // Retrieve the FCM token from the document
      String? fcmToken = userDoc.get('FCMToken');
      print("FCM Token from Firestore: $fcmToken");

      setState(() {
        To_User_FCMToken = fcmToken;
      });
      if (FCMToken != To_User_FCMToken) {
        SendNotificationto(_controller.text);
      }
      _controller.clear();
    } else {
      setState(() {
        To_User_FCMToken = null;
      });
    }

    // / Return null if the document does not exist or has no data
  }

  void _sendMessage() {
    var chat_id = generateChatId(User_Id, widget.to_user_id);
    GetFCMTokenfromDataBase(widget.to_user_id);

    if (_controller.text.isNotEmpty && userEmail != null) {
      _firestore
          .collection('chats')
          .doc(chat_id) // Use the passed value
          .collection("chats")
          .add({
        'text': _controller.text,
        'sender': userEmail!,
        'profilePicUrl': userProfilePicUrl ?? 'default_profile_pic_url',
        'timestamp': FieldValue.serverTimestamp(),
      });
      _scrollToBottom();
    }

    _firestore
        .collection('Inbox')
        .doc(User_Id) // Use the passed value
        .collection("Inbox")
        .doc(widget.to_user_id) // Specify the user document
        .set({
      'contactName': widget.to_user_name,
      'lastMessage': _controller.text,
      'unreadCount': 0,
      'time': FieldValue.serverTimestamp(),
      'User_Profile_pic': widget.to_profilepic,
      "User_Id": widget.to_user_id
    }, SetOptions(merge: true));

    _firestore
        .collection('Inbox')
        .doc(widget.to_user_id) // Use the passed value
        .collection("Inbox")
        .doc(User_Id) // Specify the user document
        .set({
      'contactName': User_Name,
      'lastMessage': _controller.text,
      'unreadCount': FieldValue.increment(1),
      'time': FieldValue.serverTimestamp(),
      'User_Profile_pic': User_Profile_Picture,
      "User_Id": User_Id
    }, SetOptions(merge: true));

    print("To User Token l:$To_User_FCMToken");
  }

  Future<void> SendNotificationto(String Mess) async {
    await NotificationService.sendNotificationToSelectedDevice(
        ' $User_Name Send a Message',
        Mess,
        User_Profile_Picture,
        1,
        To_User_FCMToken);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 3),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String generateChatId(String userId1, String userId2) {
    // Ensure that the chat ID is generated consistently regardless of the order of the user IDs
    if (userId1.compareTo(userId2) < 0) {
      return '$userId1-$userId2';
    } else {
      return '$userId2-$userId1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_rounded),
          ),
          SizedBox(
            width: 5,
          ),
          InkWell(
            onTap: () {},
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.to_profilepic),
            ),
          ),
          SizedBox(
            width: 7,
          ),
          Text(
            widget.to_user_name,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          )
        ]),
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
                  .doc(generateChatId(User_Id, widget.to_user_id))
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
                        ? DateFormat('dd/mm/yyyy      hh:mm a')
                            .format(timestamp.toDate())
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
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Message',
                      labelStyle: TextStyle(fontSize: 16),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
                // InkWell(
                //   onTap: _sendMessage,
                //   child: Container(
                //     height: 40,
                //     width: 40,
                //     child: Image.asset('Assets/Images/send.png'),
                //   ),
                // )
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
      child: Padding(
        padding: EdgeInsets.only(right: 20, left: 50),
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
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 50),
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
      ),
    );
  }
}
