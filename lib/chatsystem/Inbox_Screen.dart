import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:flutter_application_1/chatsystem/GroupChat.dart';
import 'package:flutter_application_1/chatsystem/Chat_Screen.dart';
import 'package:intl/intl.dart';

class Inbox_Screen extends StatefulWidget {
  String? Reciver_Inbox;

  Inbox_Screen({super.key, this.Reciver_Inbox});

  @override
  State<Inbox_Screen> createState() => _Inbox_ScreenState();
}

class _Inbox_ScreenState extends State<Inbox_Screen> {
  late Stream<QuerySnapshot> _inboxStream;

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
    // Initialize the inbox stream with ordered messages by 'time' in descending order
    notificationPremision();
    _inboxStream = FirebaseFirestore.instance
        .collection('Inbox')
        .doc(User_Id)
        .collection("Inbox")
        .orderBy('time', descending: true)
        .snapshots();

    print("inbox stream :$_inboxStream");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Inbox'),
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

          final messages = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                // Example of a custom widget with From and To, adjust as needed
                if (Has_From_To)
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupFromTo(
                            hasFromTo: "$From $To",
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 15),
                              CircleAvatar(
                                radius: 28,
                                backgroundImage:
                                    AssetImage('Assets/gifs/inbox.gif'),
                              ),
                              Spacer(),
                              Container(
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
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
                              SizedBox(width: 10),
                              Text(
                                "To",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
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
                              SizedBox(width: 10),
                              InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                  )),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                for (var message in messages)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat_Screen_Inbox(
                            to_profilepic: message['User_Profile_pic'],
                            to_user_name: message['contactName'],
                            to_user_id: message['User_Id'],
                          ),
                        ),
                      );
                    },
                    child: Inbox_Screen_Card(
                      contactName: message['contactName'] ?? 'Unknown',
                      lastMessagePreview:
                          message['lastMessage'] ?? 'No message',
                      time: message['time'] != null
                          ? message['time'].toDate()
                          : DateTime.now(),
                      unreadCount: message['unreadCount'] ?? 0,
                      to_user_id: message['User_Id'],
                      to_profile_pic: message['User_Profile_pic'],
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

// DateTime conversion utility function
DateTime convertTimestampToDateTime(var timestamp) {
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  } else if (timestamp is int) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  } else if (timestamp is String) {
    return DateTime.parse(timestamp);
  } else {
    throw Exception('Invalid timestamp type');
  }
}

// The custom card widget for displaying inbox messages
class Inbox_Screen_Card extends StatelessWidget {
  final String contactName;
  final String lastMessagePreview;
  final DateTime time;
  final int unreadCount;
  final to_user_id;
  final to_profile_pic;

  const Inbox_Screen_Card({
    Key? key,
    required this.contactName,
    required this.to_profile_pic,
    required this.lastMessagePreview,
    required this.time,
    required this.unreadCount,
    required this.to_user_id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('hh:mm a').format(time);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat_Screen_Inbox(
              to_profilepic: to_profile_pic,
              to_user_name: contactName,
              to_user_id: to_user_id,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        height: 80,
        child: Row(
          children: [
            SizedBox(width: 8),
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(to_profile_pic),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    contactName,
                    style: TextStyle(
                      fontSize: 14,
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
                  formattedTime,
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
                      '$unreadCount',
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
      ),
    );
  }
}
