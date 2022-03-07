import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_location.dart';
import 'package:flutter/cupertino.dart';

class LocationTutorial extends StatefulWidget {
  final bool isFromWelcome;
  const LocationTutorial({Key key, this.isFromWelcome}) : super(key: key);
  @override
  _LocationTutorialState createState() => _LocationTutorialState();
}

class _LocationTutorialState extends State<LocationTutorial> {
  // Analytics code
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
      Global.setOnboardingId(32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          brightness: Brightness.dark,
          automaticallyImplyLeading: false,
          automaticallyImplyMiddle: false,
          backgroundColor: Colors.white,
          border: Border(bottom: BorderSide.none),
          padding: EdgeInsetsDirectional.only(start: 10.0),
        ),
      ),
      body: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "To see and be seen by matches\nnear your current location,\nselect ‘Allow while using app’\nin the next screen.",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: AppConfig.fontsizeForSmallDevice(context, 24),
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: AppConfig.fontsizeForSmallDevice(context, 10),
                ),
                Stack(
                  children: <Widget>[
                    Image.asset("assets/images/map_tutorial.png",
                        width: AppConfig.fullWidth(context) - 40,
                        height: 513 / 896 * AppConfig.fullHeight(context),
                        fit: BoxFit.contain),
                    Image.asset(
                      "assets/images/overlay_light.png",
                      width: AppConfig.fullWidth(context) - 40,
                      height: 513 / 896 * AppConfig.fullHeight(context),
                      fit: BoxFit.contain,
                    ),
                    Positioned.fill(
                      left: 50,
                      right: 50,
                      child: Image.asset(
                        "assets/images/location_prompt_tutorial.png",
                        fit: BoxFit.contain,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: AppConfig.fontsizeForSmallDevice(context, 10),
                ),
                Text(
                  "You can adjust this anytime\nin your phone’s settings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: AppConfig.fontsizeForSmallDevice(context, 16),
                      fontWeight: FontWeight.w400),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 60, 10),
                          width: 220,
                          child: PlatformButton(
                              onPressed: () {
                                if (widget.isFromWelcome != null &&
                                    widget.isFromWelcome) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => UserLocation(
                                            isFromWelcome: true,
                                          )));
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => UserLocation()));
                                }
                              },
                              color: Colors.white,
                              disabledColor: AppColors.greyColor,
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                    color: AppColors.blueColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              )),
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
