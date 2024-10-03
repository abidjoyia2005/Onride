import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:flutter_application_1/chatsystem/GroupChat.dart';
import 'package:flutter_application_1/chatsystem/Chat_Screen.dart';
import 'package:intl/intl.dart';

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

          // Get the list of documents from the snapshot
          final messages = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                if (Has_From_To)
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupFromTo(
                              hasFromTo: "$From $To",
                            ),
                          ));
                    },
                    child: Row(
                      children: [
                        // SizedBox(
                        //   width: 15,
                        // ),

                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                                Radius.circular(25)), // Border radius
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(
                                    0.5), // Shadow color with opacity
                                spreadRadius:
                                    2, // How much the shadow should spread
                                blurRadius: 5, // Softness of the shadow
                                offset: Offset(0,
                                    3), // Horizontal and Vertical position of the shadow
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 15,
                              ),
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
                                    color: Colors
                                        .black, // Set your desired border color
                                    width: 2.0, // Set the border width
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.2), // Shadow color
                                      spreadRadius:
                                          2, // Spread radius of the shadow
                                      blurRadius:
                                          5, // Blur radius of the shadow
                                      offset: Offset(
                                          0, 3), // Offset of the shadow (x, y)
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  border: Border.all(
                                    color: Colors
                                        .black, // Set your desired border color
                                    width: 2.0, // Set the border width
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.2), // Shadow color
                                      spreadRadius:
                                          2, // Spread radius of the shadow
                                      blurRadius:
                                          5, // Blur radius of the shadow
                                      offset: Offset(
                                          0, 3), // Offset of the shadow (x, y)
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
                                width: 10,
                              ),
                              InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                for (var message in messages)
                  GestureDetector(
                    onTap: () {
                      // Handle the tap event, e.g., navigate to the detailed chat screen
                    },
                    child: Inbox_Screen_Card(
                      contactName: message['contactName'] ?? 'Unknown',
                      lastMessagePreview:
                          message['lastMessage'] ?? 'No message',
                      time: (message['time']).toDate(),
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

DateTime convertTimestampToDateTime(var timestamp) {
  if (timestamp is Timestamp) {
    // Firebase Timestamp to DateTime
    return timestamp.toDate();
  } else if (timestamp is int) {
    // If the timestamp is in seconds or milliseconds since epoch
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  } else if (timestamp is String) {
    // Parse string to DateTime if it's in a valid format
    return DateTime.parse(timestamp);
  } else {
    // If it's already a DateTime or some unsupported type
    throw Exception('Invalid timestamp type');
  }
}

class Inbox_Screen_Card extends StatelessWidget {
  final String contactName;
  final String lastMessagePreview;
  final DateTime time; // Change to DateTime instead of String
  final int unreadCount;
  final to_user_id;
  final to_profile_pic;

  const Inbox_Screen_Card(
      {Key? key,
      required this.contactName,
      required this.to_profile_pic,
      required this.lastMessagePreview,
      required this.time, // DateTime
      required this.unreadCount,
      required this.to_user_id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formatting the DateTime into a readable string
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
            ));
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
                  formattedTime, // Display formatted time
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
      ),
    );
  }
}
