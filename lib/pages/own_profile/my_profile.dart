import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/profile.dart';
import 'package:pure_match/pages/settings/settings_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../AppColors.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
  Timer _timer;
  int _start = 5;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            Global.ownProfileSaved = false;
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "my_profile", screenClassOverride: "my_profile");
    amplitudeAnalytics.logEvent("my_profile_page");
  }

  Future<int> _getUserId() async {
    var sp = await SharedPreferences.getInstance();
    return sp?.getInt("id");
  }

  PlatformAppBar getAppBar() {
    if (Global.ownProfileSaved) {
      startTimer();
      return PlatformAppBar(
        backgroundColor: AppColors.blueColor,
        cupertino: (_, __) =>
            CupertinoNavigationBarData(brightness: Brightness.dark),
        title: Text("Profile Changes Saved!",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 16)),
      );
    } else {
      return PlatformAppBar(
        cupertino: (_, __) =>
            CupertinoNavigationBarData(brightness: Brightness.dark),
        backgroundColor: AppColors.offWhiteColor,
        title: Text("My Profile",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 24)),
        automaticallyImplyLeading: true,
        trailingActions: <Widget>[
          PlatformButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MainSettings()));
            },
            child: Image.asset(
              "assets/images/setting_logo.png",
              width: 30,
              height: 30,
            ),
            color: AppColors.offWhiteColor,
            padding: EdgeInsets.all(0),
          ),
        ],
      );
    }
  }

  void onSaveHiehgt() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        backgroundColor: Colors.white,
        appBar: getAppBar(),
        body: SafeArea(
          child: new FutureBuilder(
              future: this._getUserId(),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.data != null) {
                  return new Profile(
                    userId: snapshot.data,
                    isEditable: true,
                    themeColor: AppColors.blueColor,
                  ).getFullProfile();
                } else {
                  return SizedBox(height: 100, child: Container());
                }
              }),
        ));
  }
}
