import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/profile/edit_match_settings.dart';
import 'package:pure_match/pages/own_profile/my_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'dart:io' show Platform;
import 'ios_profile_body.dart';

class MyProfileBase extends StatefulWidget {
  @override
  _MyProfileBaseState createState() => _MyProfileBaseState();
}

class _MyProfileBaseState extends State<MyProfileBase> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String firstName = "";
  String height = "";
  String kidsHave = "";
  String position = "";
  String employer = "";
  String positionEmployer = "";
  String church = "";

  String location = "";

  String aboutMe = "";

  String favVerse = "";

  List<dynamic> interests = [];

  void _getUserData() async {
    var sp = await SharedPreferences.getInstance();
    int id = sp.getInt("id");
    var res = await MyHttp.get("users/user/$id");
    var res2 = await MyHttp.get("users/uploads");
    if (res.statusCode == 200 && res2.statusCode == 200) {
      print(res2.body);
      var data = res.body;
      var user = json.decode(data);
      user = user["user"];
      setState(() {
        firstName = user["first_name"];
        height = user["height"];
        kidsHave = user["kids_have"];
        position = user["position"];
        employer = user["employer"];
        positionEmployer = "${user["position"]} at ${user["employer"]}";
        church = user["church"];
        location = user["location"];
        aboutMe = user["about_me"];
        favVerse = user["favorite_verse"];
        interests = user["interests"];
      });
    }
    print(res.statusCode);
    print(res.body);
  }

  @override
  void initState() {
    super.initState();
    this._getUserData();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "my_profile", screenClassOverride: "my_profile");
    amplitudeAnalytics.logEvent("my_profile_page");
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ["My Profile", "Match Settings"];
    if (Platform.isAndroid) {
      return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            bottom: TabBar(
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(2), color: Colors.white),
              tabs: tabs.map((String t) {
                return Tab(
                  child: Text(
                    t,
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
            ),
            elevation: 0,
            centerTitle: true,
            textTheme: TextTheme(subtitle1: TextStyle(fontSize: 24)),
            actions: <Widget>[Icon(Icons.settings)],
            backgroundColor: AppColors.offWhiteColor,
            title: Text(this.firstName,
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 24)),
          ),
          body: SafeArea(
            child: TabBarView(
              children: <Widget>[
                MyProfile(),
                Container(
                  child: EditMatchSettings(),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (Platform.isIOS) {
      return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            trailing:
                Icon(CupertinoIcons.settings, color: Colors.black, size: 35.0),
            padding: EdgeInsetsDirectional.only(end: 20.0),
            automaticallyImplyLeading: false,
            middle: Text(this.firstName,
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 24)),
            backgroundColor: AppColors.offWhiteColor,
          ),
          child: iOSProfileBody());
    }
  }

  Container _getInfoLine(
      String text, Widget icon, Widget widget, Function handleValue) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.greyColor))),
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: icon,
            onPressed: () {},
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(text),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                      context, MaterialPageRoute(builder: (context) => widget))
                  .then((value) {
                handleValue(value);
              });
            },
          )
        ],
      ),
    );
  }
}
