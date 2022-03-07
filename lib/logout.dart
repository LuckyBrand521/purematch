import 'package:flutter/widgets.dart';
import 'package:pure_match/routes.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logout {
  static void logout() async {
    var sp = await SharedPreferences.getInstance();
    sp.remove("id");
    sp.remove("token");
    Routes.sailor.navigate("/main",
        navigationType: NavigationType.pushAndRemoveUntil,
        removeUntilPredicate: (Route<dynamic> route) => false);
  }
}
