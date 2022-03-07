import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/myfirebase.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/onboarding/ProfileConfirm.dart';
import 'package:pure_match/pages/onboarding/profile_info/awsome_done.dart';
import 'package:pure_match/routes.dart';
import 'package:sailor/sailor.dart';

import 'DisabledNotification.dart';

class EnableNotification extends StatefulWidget {
  final bool isFromWelcome;
  const EnableNotification({Key key, this.isFromWelcome}) : super(key: key);
  @override
  _EnableNotificationState createState() => _EnableNotificationState();
}

class _EnableNotificationState extends State<EnableNotification> {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");

  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
  Future<void> _checkPN() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _goFeedScreen();
    } else {
      _goNextScreen();
    }
  }

  Future<void> _goFeedScreen() async {
    var tokenRes = await MyFirebase.sendFCMToken("users/fcm-token");
    print("tokenRes=${tokenRes}");
    if (widget.isFromWelcome != null && widget.isFromWelcome) {
      // Go feed
      Global.removeOnboardingId();
      Routes.sailor.navigate("/homes",
          params: {'tabIndex': 0},
          navigationType: NavigationType.pushAndRemoveUntil,
          removeUntilPredicate: (Route<dynamic> route) => false);
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ProfileConfirm()));
    }
  }

  void _goNextScreen() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DisabledNotification(
              isFromWelcome: widget.isFromWelcome,
            )));
  }

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    if (widget.isFromWelcome != null && widget.isFromWelcome) {
    } else {
      Global.setOnboardingId(30);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        appBar: PlatformAppBar(
          material: (_, __) => MaterialAppBarData(
            backgroundColor: AppColors.blueColor,
            elevation: 0.0,
            leading: (widget.isFromWelcome != null && widget.isFromWelcome)
                ? null
                : IconButton(
                    padding: EdgeInsetsDirectional.only(start: 10.0),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 25,
                    ),
                    iconSize: 30,
                    onPressed: () {
                      Navigator.pop(context);
                      //Analytics tracking code
                      analytics.setCurrentScreen(
                          screenName: "onboarding_match_preference",
                          screenClassOverride: "onboarding_match_preference");
                      amplitudeAnalytics
                          .logEvent("onboarding_match_preference_page");
                    },
                  ),
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
              brightness: Brightness.dark,
              automaticallyImplyLeading: false,
              automaticallyImplyMiddle: false,
              backgroundColor: AppColors.blueColor,
              border: Border(bottom: BorderSide.none),
              padding: EdgeInsetsDirectional.only(start: 10.0),
              leading: (widget.isFromWelcome != null && widget.isFromWelcome)
                  ? null
                  : CupertinoNavigationBarBackButton(
                      color: Colors.white,
                      previousPageTitle: null,
                      onPressed: () {
                        Navigator.pop(context);
                        //Analytics tracking code
                        analytics.setCurrentScreen(
                            screenName: "onboarding_match_preference",
                            screenClassOverride:
                                "onboarding_dating_preference");
                        amplitudeAnalytics
                            .logEvent("onboarding_match_preference_page");
                      })),
        ),
        body: Scaffold(
          backgroundColor: AppColors.blueColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        "assets/images/pn_mailbox.png",
                        width: 200 / 896 * AppConfig.fullHeight(context),
                        height: 200 / 896 * AppConfig.fullHeight(context),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 30, 25)),
                      Text(
                        "One last\nthing…",
                        style: TextStyle(
                            fontSize: AppConfig.heightWithDForSmallDevice(
                                context, 48, 20),
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 30, 20),
                      ),
                      Text(
                        "Enable Push Notifications\nto never miss when:\n💛 Someone likes you 💛\n🙋‍♀️ Someone messages you 🙋‍♂️\n🎉 Special events happen! 🎉",
                        style: TextStyle(
                            fontSize: AppConfig.heightWithDForSmallDevice(
                                context, 26, 10),
                            color: Colors.white,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.only(top: 30, bottom: 20),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: PlatformButton(
                              onPressed: () {
                                _checkPN();
                              },
                              color: Colors.white,
                              materialFlat: (_, __) => MaterialFlatButtonData(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                              cupertino: (_, __) => CupertinoButtonData(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                              child: Text(
                                "Enable Notifications",
                                style: TextStyle(
                                    fontSize: AppConfig.fontsizeForSmallDevice(
                                        context, 20),
                                    color: AppColors.blueColor,
                                    fontWeight: FontWeight.w700),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
