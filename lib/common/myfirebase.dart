import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyFirebase {
  static Future<Response> sendFCMToken(String endpoint) async {
    FirebaseMessaging fm = FirebaseMessaging.instance;
    String fcmToken = await fm.getToken();
    if (fcmToken != null) {
      print("FCM Token=$fcmToken");
      var sp = await SharedPreferences.getInstance();
      String id = sp.getInt("id").toString();
      var data = {
        "fcm_token": fcmToken,
        "user_id": id,
      };
      var tokenRes = await MyHttp.put(endpoint, data);
      // var body = json.decode(tokenRes.body);

      return tokenRes;
    } else {
      print("FCM Token is null");
      return null;
    }
  }
}
