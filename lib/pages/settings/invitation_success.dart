import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/AppColors.dart';

class InvitationSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.blueColor,
        body: WillPopScope(
          onWillPop: () async {
            // Analytics tracking code
            final Amplitude amplitudeAnalytics =
                Amplitude.getInstance(instanceName: "PURE MATCH");
            String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
            amplitudeAnalytics.init(apiKey);
            FirebaseAnalytics analytics = FirebaseAnalytics();

            analytics.setCurrentScreen(
                screenName: "invitation_success",
                screenClassOverride: "invitation_success");
            analytics.logEvent(
                name: "sent_an_invite",
                parameters: <String, dynamic>{"user_id": "", "invited": ""});

            amplitudeAnalytics.logEvent('invitation_success_page',
                eventProperties: {"user_id": "", "invited": ""});

            return false;
          },
          child: Container(
            padding: EdgeInsetsDirectional.only(start: 50.0, end: 50.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 100),
                Text(
                  "Success",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 60,
                      color: Colors.white,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal),
                ),
                SizedBox(height: 40),
                Text(
                  "Your invitation has been sent!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal),
                ),
                SizedBox(height: 40),
                SizedBox(
                  height: 70,
                  child: FlatButton(
                    color: Colors.white,
                    disabledColor: Colors.white,
                    child: Text(
                      "Back to Pure Match",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: "Roboto",
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
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
