import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:pure_match/models/user.dart';

import 'dart:convert' as convert;

import 'package:pure_match/pages/MyUrl.dart';
import 'package:pure_match/routes.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHttp {
  static Future<http.Response> put(String endPoint, dynamic data) async {
    var sp = await SharedPreferences.getInstance();
    String token = sp.getString("token");
    var headers = {
      "Content-type": "application/json",
      "authorization": "Bearer $token"
    };
    print(token);
    var res;
    var url = Uri.parse(MyUrl.url(endPoint));
    if (data == null) {
      res = await http.put(url, headers: headers);
    } else
      res =
          await http.put(url, body: convert.jsonEncode(data), headers: headers);
    if (res.statusCode == 401) {
      sp.remove("token");
      sp.remove("id");
      Routes.sailor.navigate("/main",
          navigationType: NavigationType.pushAndRemoveUntil,
          removeUntilPredicate: (Route<dynamic> route) => false);
      return null;
    }
    return res;
  }

  static Future<http.Response> post(String endPoint, dynamic data) async {
    var headers;
    var sp = await SharedPreferences.getInstance();
    String token = sp.getString("token");
    if (token != null && token.isNotEmpty) {
      headers = {
        "Content-type": "application/json",
        "authorization": "Bearer $token"
      };
    } else {
      headers = {"Content-type": "application/json"};
    }
    var url = Uri.parse(MyUrl.url(endPoint));
    var res =
        await http.post(url, body: convert.jsonEncode(data), headers: headers);
    print("Status code ${res.statusCode}");
    if (res.statusCode == 401) {
      sp.remove("token");
      sp.remove("id");
      Routes.sailor.navigate("/main",
          navigationType: NavigationType.pushAndRemoveUntil,
          removeUntilPredicate: (Route<dynamic> route) => false);
      return null;
    }
    return res;
  }

  static Future<http.Response> get(String endPoint) async {
    var sp = await SharedPreferences.getInstance();
    String token = sp.getString("token");
    var headers = {
      "Content-type": "application/json",
      "authorization": "Bearer $token"
    };
    print(token);
    var url = Uri.parse(MyUrl.url(endPoint));
    var res = await http.get(url, headers: headers);
    if (res.statusCode == 401) {
      sp.remove("token");
      sp.remove("id");
      Routes.sailor.navigate("/main",
          navigationType: NavigationType.pushAndRemoveUntil,
          removeUntilPredicate: (Route<dynamic> route) => false);
      return null;
    }
    return res;
  }

  static Future<http.Response> delete(String endPoint) async {
    var sp = await SharedPreferences.getInstance();
    String token = sp.getString("token");
    var headers = {
      "Content-type": "application/json",
      "authorization": "Bearer $token"
    };
    var url = Uri.parse(MyUrl.url(endPoint));
    var res = await http.delete(url, headers: headers);

    if (res.statusCode == 401) {
      sp.remove("token");
      sp.remove("id");
      Routes.sailor.navigate("/main",
          navigationType: NavigationType.pushAndRemoveUntil,
          removeUntilPredicate: (Route<dynamic> route) => false);
      return null;
    }
    return res;
  }

  static Future<User> getUserDetails({int userId}) async {
    try {
      var sp = await SharedPreferences.getInstance();
      int id = userId ?? sp.getInt("id");
      var res = await MyHttp.get("/users/user/$id");
      if (res.statusCode == 200) {
        var body = convert.json.decode(res.body);
        var user = body["user"];

        return User.fromJson(user);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
