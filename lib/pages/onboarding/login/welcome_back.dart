import 'package:flutter/material.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/basic_info/location_tutorial.dart';
import 'package:pure_match/routes.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'dart:convert';

class WelcomeBack extends StatefulWidget {
  final bool isFromLogin;
  const WelcomeBack({Key key, this.isFromLogin}) : super(key: key);
  @override
  _WelcomeBackState createState() => _WelcomeBackState();
}

class _WelcomeBackState extends State<WelcomeBack> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  var response;
  String firstName = "";
  String profileImg = "";
  String message = "";
  bool verificationDisabled = true;
  String code = "";

  var fcmToken = "";

  Future<void> _goNextScreen() async {
    int seconds = 3;
    (profileImg != null) ? seconds = 5 : seconds = 3;
    var sp = await SharedPreferences.getInstance();
    bool isAlreadyLogin = sp.containsKey("loggedIn");
    bool isAlreadysignup = sp.containsKey("signup");
    if (widget.isFromLogin != null &&
        widget.isFromLogin == true &&
        isAlreadyLogin == false &&
        isAlreadysignup == false) {
      Future.delayed(Duration(seconds: seconds), () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LocationTutorial(
                  isFromWelcome: true,
                )));
      });
    } else {
      Future.delayed(Duration(seconds: seconds), () {
        Routes.sailor.navigate("/homes",
            params: {'tabIndex': 0},
            navigationType: NavigationType.pushAndRemoveUntil,
            removeUntilPredicate: (Route<dynamic> route) => false);

        //Analytics tracking code
        analytics.setCurrentScreen(
            screenName: "my_feed", screenClassOverride: "my_feed");
        amplitudeAnalytics.logEvent("my_feed_page");
      });
    }
  }

  void _getData() async {
    print("Get data");
    // getting the token
    var sp = await SharedPreferences.getInstance();
    int id = sp.getInt("id");
    var res = await MyHttp.get("users/user/$id");
    if (res.statusCode == 200) {
      print("Data: ${res.body}");
      setState(() {
        this.response = json.decode(res.body);
        var userResponse = this.response["user"];
        Global.gender = userResponse["gender"];
        firstName = userResponse["first_name"];
        profileImg = userResponse["ProfilePictureId"];
        if (profileImg == null) {
          Global.hasProfileImg = false;
        }
        setState(() {
          this.message =
              "Welcome Back${firstName.isNotEmpty ? ',\n ${firstName.trim()}!' : '!'}";
        });
        _goNextScreen();
        print(message);
      });
    } else {
      setState(() {
        message = "Error: ${res.statusCode}";
      });
    }
  }

  @override
  void initState() {
    this._getData();
    super.initState();

    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "welcome_back", screenClassOverride: "welcome_back");
    amplitudeAnalytics.logEvent("welcome_back_page");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Column(
                    children: [
                      (profileImg != null && profileImg != "")
                          ? Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(profileImg),
                                ),
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        message,
                        style: TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
