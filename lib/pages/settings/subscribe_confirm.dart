import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amplitude_flutter/amplitude.dart';

class SubscribeConfirm extends StatelessWidget {
  //Analytics tracking code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  _launchURL() async {
    const url = 'https://www.google.com/';
    launch(url);
    // Analytics tracking code
    analytics.setCurrentScreen(
        screenName: "subscribe_confirmation",
        screenClassOverride: "subscribe_confirmation");
    amplitudeAnalytics.init(apiKey);
    amplitudeAnalytics.logEvent("subscribe_confirmation_page");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.blueColor,
        body: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Container(
            padding: EdgeInsetsDirectional.only(start: 30.0, end: 30.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 50),
                Text(
                  "Welcome to\n Pure Match Premium",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal),
                ),
                SizedBox(height: 30),
                Text(
                  "Welcome to the Pure Match family!\n Your premium membership grants you access to our future learning and growth module, as well as other premium features.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal),
                ),
                SizedBox(height: 20),
                InkWell(
                  child: Text(
                      "Tap here to take a brief tour of new membership benefits",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.underline)),
                  onTap: () => _launchURL,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(left: 50, right: 50, bottom: 30),
                      child: SizedBox(
                        height: 70,
                        child: FlatButton(
                          color: Colors.white,
                          disabledColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Browse Matches",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Roboto",
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
