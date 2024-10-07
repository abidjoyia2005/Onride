import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:flutter_application_1/AuthService/Notification.dart';
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
  late List<String> tokens;
// Function to fetch the tokens array from Firebase
  Future<List<String>> fetchTokensFromFirebase() async {
    // Create a Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the collection and document
    DocumentReference harnoliDocument =
        firestore.collection('Vicahle').doc('$From $To');

    try {
      // Get the document snapshot
      DocumentSnapshot docSnapshot = await harnoliDocument.get();

      if (docSnapshot.exists) {
        // If the document exists, retrieve the 'tokens' array
        tokens = List<String>.from(docSnapshot['tokens']);
        print('Fetched Tokens: $tokens');
        return tokens;
      } else {
        print('Document does not exist. No tokens to fetch.');
        return [];
      }
    } catch (e) {
      print('Error fetching tokens: $e');
      return [];
    }
  }

  void notificationPremision() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings seting = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (seting.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notifiaction permisiton allowed');
    } else if (seting.authorizationStatus == AuthorizationStatus.provisional) {
      print('Notifiaction permisiton provisional');
    } else {
      print('Notifiaction permisiton is denied');
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _scrollToBottom();
    fetchTokensFromFirebase();
    notificationPremision();
  }

  Future<void> _getUserInfo() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userEmail = User_Name; // Get user email
        userProfilePicUrl =
            User_Profile_Picture; // Get profile picture, provide a default if null
      });
    }
  }

  void SendNoficationtoAllmember(String mes) async {
    _controller.clear();
    for (int i = 0; i < tokens.length; i++) {
      if (FCMToken != tokens[i]) {
        await NotificationService.sendNotificationToSelectedDevice(
            ' $User_Name Send Message in $From To $To (Group)',
            mes,
            User_Profile_Picture,
            2,
            tokens[i]);
      }
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

      _scrollToBottom();

      SendNoficationtoAllmember(_controller.text);
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
        automaticallyImplyLeading: false,
        title: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.all(Radius.circular(25)), // Border radius
            boxShadow: [
              BoxShadow(
                color:
                    Colors.grey.withOpacity(0.5), // Shadow color with opacity
                spreadRadius: 2, // How much the shadow should spread
                blurRadius: 5, // Softness of the shadow
                offset: Offset(
                    0, 3), // Horizontal and Vertical position of the shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 15,
              ),
              InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_rounded,
                  )),
              Spacer(),
              Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                    color: Colors.black, // Set your desired border color
                    width: 2.0, // Set the border width
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      spreadRadius: 2, // Spread radius of the shadow
                      blurRadius: 5, // Blur radius of the shadow
                      offset: Offset(0, 3), // Offset of the shadow (x, y)
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    From,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppinssb",
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "To",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                    color: Colors.black, // Set your desired border color
                    width: 2.0, // Set the border width
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      spreadRadius: 2, // Spread radius of the shadow
                      blurRadius: 5, // Blur radius of the shadow
                      offset: Offset(0, 3), // Offset of the shadow (x, y)
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    To,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppinssb",
                    ),
                  ),
                ),
              ),
              Spacer(),
              SizedBox(
                width: 20,
              )
            ],
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.more_vert),
        //     onPressed: () {
        //       // Additional options can be added here
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Vicahle')
                  .doc(widget.hasFromTo)
                  .collection("message")
                  .orderBy('timestamp',
                      descending:
                          false) // Order by timestamp in descending order to get the latest messages first
                  .limit(150) // Limit to the last 150 messages
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    print("Messages list : ${messages.length}");
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
      child: Padding(
        padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
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
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              time,
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
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
      child: Padding(
        padding: EdgeInsets.only(right: 50),
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
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 12),
                            ),
                            Text(
                              time,
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 12),
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
      ),
    );
  }
}
