// import 'dart:convert';
// import 'dart:io';
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:http/http.dart' as http;

// class NotificationService {
//   static Future<String> getToken() async {
//     final serviceAccountJson = {
//       "type": "service_account",
//       "project_id": "lookranks-5545c",
//       "private_key_id": "09adedcd52746e26d2ee94b7dc9415f76feb2d7c",
//       "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCKtdCsjRSwgXtp\nrSKKSdENTomhoh7ZREkGnrvCKZVw8xxxMTnpAZU1az4tGmZ9LIPaG3S7KPFHXGUJ\nKfF4CoDmGoVTHGVhiL5zXTxLxhG45yFySE0y9RsqgJ/1agSljSh1uLIg+OljJrtV\nvxWNvFgWd7Q0WDttNOVFy1SNZKRN7Y+nr4ocws8XuZfkNsktR7BB0L3KKzyrrjUf\notjbsIhyXetb2T8Bqa3Toz8YLloSK8D1bWIBpDkPGU++MrjrmzusA2VQuPR/dYat\n9BNvBvYLv9SIJQEqgzjHc4HbADMjHKQ0/btUzkVqT+h+VxwmfEUOZZWnBw6o9Q/+\nh/2M9GtvAgMBAAECggEABpHV8FY+RJ3dWoP4vtQAMsElg6JKE8BINSgPfIK7sT3S\newn51C9fAciyiTBW6lbRZ+MlBDhMNTULFAQIi8bzk/JtniIaKyRu4Mfpsy0OadOI\nogEKpv806i5tZRJAZhbpc6nrxeQEKc4L0WPbgXsKMQY6YsBLEEERGt0mhAvgPFCS\nQyP3urvv8WLcwXM4tGKKLxmnBGhbLEkNgD92+3kzidyi2Yg0zfC7rAMtsUYSoRwz\n4tuWW6550fxwmxeUK3RaEQTPg308Z2VyMrOYYQddRGhEKmTAdhqiSYZxn1HRt4RY\ns+C4cPgSjP1i8QLcdrKvmjcNZ4h2sU5tqd1pcOd5AQKBgQC/Bh6sY0fisSTCEgFI\nNF8Z8BojMXQwUxEK8NS38mIVbmT2q2/AJf9gabSls7/9GPVQkmg02n3XuJBr77kQ\nmcMbvgNTk8ysD440dVdxj9glW2mgf1nWrVszCaXQnLZuZWXn8U8cHeTw1tB8215N\nOEOsRmSCGjQMR5LzCX0EOFWFwwKBgQC55Fnd1OOcIGlxLUMuh9Dz3+mQMyiRPd+o\nGJ9YwGJTF8B8GRE4ablYPSkuI3X1dAfXZGIbZhdpN6r8QeyFwqA/KCec7gQLWqM7\nHb4HGUQRsoUAWd9iVfklEYl5WGVk9fS859p4zp8kp0v2U1Ftz/DRx3SSWOBZ/KwY\nUIAlBAzs5QKBgAR4ojMqx734o4GfZkRIZYl340S7nZqb9yQoavI7TCxwPxC/Boia\n2xVoo//U60ODWAqgwquqCZQJD+hW3iATWUvG8ND9/qZwXsW/kWJpGYgWUayeDn5F\n5IKXUThG0sZWvUHmlhF0aa1xecPSZqysCnl31FZvQpSfAEOMD08P+oB9AoGATkb/\nJK957Quk+xiROq3ManV2d9djFM4WOUWtDAVvIghVcKxpmPTELIkMpzYdfO+QQb4u\npdT2tMLRSIpGHAlZy16QV7/Oii1voPwkQf78r+sZoI03yMPlNxvMZQG5KKt9lHKZ\nh9eSIjAkh6SMHI68nMm9p8avKpWArnhvjabH/pUCgYBFrby8z1qXe3ZJx3rJjxF4\neXAVvdHulfV7X1FUvCCRgnqFq+LHxEnqot4XQn7SljBg8bFcQW/9iawcPMRyNf6d\nzicvnKNzueWMNLB6yRbRD6Te14h6C/O3RcKbmw/ihRHsn6YUU+/WvZLv+0roN5A8\nkQ7lLh/QvA5DElfLz+A5eA==\n-----END PRIVATE KEY-----\n",
//       "client_email": "lookranks-abid@lookranks-5545c.iam.gserviceaccount.com",
//       "client_id": "107101823352981782271",
//       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//       "token_uri": "https://oauth2.googleapis.com/token",
//       "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//       "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/lookranks-abid%40lookranks-5545c.iam.gserviceaccount.com",
//       "universe_domain": "googleapis.com"
//     };

//     List<String> scopes = [
//       'https://www.googleapis.com/auth/userinfo.email',
//       'https://www.googleapis.com/auth/firebase.database',
//       'https://www.googleapis.com/auth/firebase.messaging'
//     ];

//     auth.ServiceAccountCredentials credentials = auth.ServiceAccountCredentials.fromJson(serviceAccountJson);

//     auth.AccessCredentials accessCredentials = await auth.obtainAccessCredentialsViaServiceAccount(
//       credentials,
//       scopes,
//       http.Client(),
//     );

//     return accessCredentials.accessToken.data;
//   }

//   static sendNotificationToSelectedDevice(String Title ,String Des, String Token) async {
//     print("Notification is sending");
//     final String serverKey = await getToken();
//     String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/lookranks-5545c/messages:send';
//     final Map<String, dynamic> message = {
//       'message': {
//         'token': Token,
//         'notification': {
//           'title':Title,
//           'body': Des,
//         },
//       },
//     };
//     final http.Response response = await http.post(
//       Uri.parse(endpointFirebaseCloudMessaging),
//       headers: <String, String>{
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $serverKey',
//       },
//       body: jsonEncode(message),
//     );
//     if (response.statusCode == 200) {
//       print("Notification sent successfully");
//     } else {
//       print("Failed to send notification: ${response.statusCode} ${response.reasonPhrase}");
//       print("Response body: ${response.body}");
//     }
//   }
// }
