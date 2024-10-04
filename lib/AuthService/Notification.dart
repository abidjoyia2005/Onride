import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class NotificationService {
  static Future<String> getToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "liveticketbyjoyia-244a9",
      "private_key_id": "8b7531a62ea8f011c8cb0d027f01b24a5ce21a34",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC+RibPMLPxhjsA\nacPpqfo3VX7N4W3/gj4flIReXhtwSXWLMH/UGIcWxJ6ci2M2FRgu4wPw/0Iv1cO9\n7BYyAbI8ke7nzhoE7SCgQI+texieox8jstpiJG791hSbi8gYfu3lAShwn7QnaEvY\ntZ10t6uc1fbAxHWlwRkav4elGRAJmZWKASNbosIQ0l4lq/zhjw4uPHcLEJMpFVj9\no418XRfbUvWkeZGyi+daMU48OiWlVVzVo0cHg9SYc/s4LfjDbu64U9rZkPDgF5SA\n+I2IaCVvKeYt0+m1cCrBVtIIVseeQO9wVpgYKaX3AUzeYIpuJqspSbbWQNvp9OhF\nUVPRecc3AgMBAAECggEAOgXIdewjI2bMfT7DeHDWFaOjrIKu+XitGxI+H0zRTzeH\nea+Le5ETONUyjQhQc8CRBFND82zTsSSdsT/aMNulj6Ts1pFaC+CHz3aAmeVsx4t0\nxn0W7VCw7AUpeZlxpk6mmuv0egupc07xuh7/6gTMd2IkAfqm6antzuNTKPxwkIxX\nlTPur6gBXCG2Ms/N4WWxtlMblOoiAPSGDCKunCgSroY+hLtbyp1mlFOhyzw0VxhM\nsBH6dqyCkOWTz2S28CF1+ebVbnMXCcBdgHN4qVY2Nzbk7YIosvoZYGrmpUO5L5rt\n4nFw0tcgdmKzenX7smdTasfGXML2ofnfp6kcSJwS+QKBgQDg+eq6qG9P6/vONDDj\nVhg9xhOTfTxOAJNl9BrNKBsQ1o1ELISHPMbPJTe+P4uJgDjsp82MzlMkcgI5sipY\nNXgJgohyu/lUunlI6fXmGVe6rSPk1CUGflOr4itm+GmsYfkQHuIq1ckeIXWzuM69\nrOQPLSZ5YVShksxvuwy94jTyAwKBgQDYgy6BWdhX/2ucUs7neC2k6wMdUzdQqP54\ntblxoQRjwKbVl4wZDO8BTo2M4EHwTN0pWZjFwaoBOtKWaB9k5vXhzFKbm0lF4FN1\nU3CmENAKquaU3FB9q/nXUML7DYn0SkEqqNZ31h+r82B1DBXW2AxWWbwoybfbb1LF\n3We/r0sJvQKBgQCwclIu4zuqKyLqrvRI2JVanads3aQWaU0xgSokDXhs1FknRuMK\nThh/DmmRxLTjurTqpxEHhiqfQuuL5LhhRk5G5yGtGtCKK1ZEYXqCZQ3xUyn7pocD\neMCW5mOz9tCqaoy0oAQyJEoAX624rxE2ogqb/IVYXYXK0x+T4dg0dN2hkQKBgQCj\n4N8hbyTOrnkAMLmFADTkQDHyT1tuBQvfyATeWfbdniNpRjT3fQ+m2JNRjyi5vyQj\nOTrmbEjGd4SP7a3djOeNij74otgaOMpS4t5ABDfD60luYTfXd4U7EVkT91J1AoNC\ny9rRh9QfLa7TyVr6bDsiXPeLk+tC/4cSVxxBPWg5rQKBgGsCSc71hHzNYUS1yiMh\nG8pM1+5Yv4woExGcKbDWIrca/owCBnvGEyVRuDm1fzhfK6tH82HVBvXw5GGVJ7Ps\nk3ElQipBq77D8c5pZ7c+XK5gUIWzvjaMSJIzxldVlXpi1wqwJ+V217vOh8+qCwAf\nnc1oJtOe6ji997U4WvfeEo1f\n-----END PRIVATE KEY-----\n",
      "client_email":
          "onride-abid-joyia@liveticketbyjoyia-244a9.iam.gserviceaccount.com",
      "client_id": "101611602725745283124",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/onride-abid-joyia%40liveticketbyjoyia-244a9.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging'
    ];

    auth.ServiceAccountCredentials credentials =
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson);

    auth.AccessCredentials accessCredentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      credentials,
      scopes,
      http.Client(),
    );

    return accessCredentials.accessToken.data;
  }

  static sendNotificationToSelectedDevice(
      String Title, String Des, String imageURL, int Id, String Token) async {
    print("Notification is sending");
    final String serverKey = await getToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/liveticketbyjoyia-244a9/messages:send';
    final Map<String, dynamic> message = {
      'message': {
        'token': Token,
        'notification': {
          'title': Title,
          'body': Des,
          'image': imageURL,
        },
        'data': {
          'id': "$Id", // Add custom data such as an ID
        },
      },
    };
    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );
    if (response.statusCode == 200) {
      print("Notification sent successfully");
    } else {
      print(
          "Failed to send notification: ${response.statusCode} ${response.reasonPhrase}");
      print("Response body: ${response.body}");
    }
  }
}
