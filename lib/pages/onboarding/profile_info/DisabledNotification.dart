import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/routes.dart';
import 'package:sailor/sailor.dart';

import '../ProfileConfirm.dart';
import 'awsome_done.dart';

class DisabledNotification extends StatefulWidget {
  final bool isFromWelcome;
  const DisabledNotification({Key key, this.isFromWelcome}) : super(key: key);
  @override
  _DisabledNotificationState createState() => _DisabledNotificationState();
}

class _DisabledNotificationState extends State<DisabledNotification> {
  FirebaseAnalytics analytics = FirebaseAnalytics();

  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");

  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    if (widget.isFromWelcome != null && widget.isFromWelcome) {
    } else {
      Global.setOnboardingId(31);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return PlatformScaffold(
        appBar: PlatformAppBar(
          material: (_, __) => MaterialAppBarData(
            backgroundColor: AppColors.blueColor,
            elevation: 0.0,
            leading: IconButton(
              padding: EdgeInsetsDirectional.only(start: 10.0),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 25,
              ),
              iconSize: 30,
              onPressed: () {
                Navigator.pop(context);
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
              leading: CupertinoNavigationBarBackButton(
                  color: Colors.white,
                  previousPageTitle: null,
                  onPressed: () {
                    Navigator.pop(context);
                  })),
        ),
        body: Scaffold(
          backgroundColor: AppColors.blueColor,
          body: Center(
              child: Column(
            children: <Widget>[
              SizedBox(
                height: height * 0.1,
              ),
              Text(
                "Notifications\ndisabled! 😢",
                style: TextStyle(
                    fontSize:
                        AppConfig.heightWithDForSmallDevice(context, 48, 20),
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: AppConfig.heightWithDForSmallDevice(context, 80, 20),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "You can always turn them on\nusing your phone’s Settings.",
                  style: TextStyle(
                      fontSize:
                          AppConfig.heightWithDForSmallDevice(context, 24, 10),
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 20),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 60,
                      width: 300,
                      child: PlatformButton(
                          onPressed: () {
                            if (widget.isFromWelcome != null &&
                                widget.isFromWelcome) {
                              // go feed
                              Global.removeOnboardingId();
                              Routes.sailor.navigate("/homes",
                                  params: {'tabIndex': 0},
                                  navigationType:
                                      NavigationType.pushAndRemoveUntil,
                                  removeUntilPredicate:
                                      (Route<dynamic> route) => false);
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProfileConfirm()));
                            }
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
                            "Continue",
                            style: TextStyle(
                                fontSize: AppConfig.fontsizeForSmallDevice(
                                    context, 20),
                                color: AppColors.blueColor,
                                fontWeight: FontWeight.w700),
                          )),
                    ),
                  ),
                ),
              )
            ],
          )),
        ));
  }
}
