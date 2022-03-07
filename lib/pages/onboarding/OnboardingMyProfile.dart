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

class OnboardingMyProfile extends StatefulWidget {
  @override
  _OnboardingMyProfileState createState() => _OnboardingMyProfileState();
}

class _OnboardingMyProfileState extends State<OnboardingMyProfile> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

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

  void _reloadScreen() {
    setState(() {});
  }

  PlatformAppBar getAppBar() {
    return PlatformAppBar(
      cupertino: (_, __) =>
          CupertinoNavigationBarData(brightness: Brightness.dark),
      backgroundColor: AppColors.offWhiteColor,
      title: Text("My Profile",
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.white, fontSize: 24)),
      automaticallyImplyLeading: true,
    );
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
                    isOnboarding: true,
                    themeColor: AppColors.blueColor,
                    onUpdateProfile: _reloadScreen,
                  ).getFullProfileOnboarding();
                } else {
                  return SizedBox(height: 100, child: Container());
                }
              }),
        ));
  }
}
