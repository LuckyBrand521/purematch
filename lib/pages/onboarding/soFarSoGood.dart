import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/onboarding/profile_info/profile_photo.dart';
import 'package:amplitude_flutter/amplitude.dart';

class SoFarSoGood extends StatelessWidget {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(20);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
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

                // Analytics tracking code
                analytics.setCurrentScreen(
                    screenName: 'onboarding_user_kids',
                    screenClassOverride: 'onboarding_user_kids');
                amplitudeAnalytics.logEvent("onboarding_user_kids_page");
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
                    // Analytics tracking code
                    analytics.setCurrentScreen(
                        screenName: 'onboarding_user_kids',
                        screenClassOverride: 'onboarding_user_kids');
                    amplitudeAnalytics.logEvent("onboarding_user_kids_page");
                  })),
        ),
        body: Scaffold(
          backgroundColor: AppColors.blueColor,
          body: Center(
              child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                    height: AppConfig.heightWithDForSmallDevice(
                        context, (height * 0.07).toInt(), 10)),
                Text(
                  "So far\nso good!!",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppConfig.fontsizeForSmallDevice(context, 48),
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 60, 20),
                ),
                Text(
                  "We are almost there.\nNow time\nfor the fun stuff!",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppConfig.fontsizeForSmallDevice(context, 28),
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(top: 20, bottom: 15),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 60,
                        width: 300,
                        child: FlatButton(
                            onPressed: () {
                              //Routes.sailor.navigate("/homes", navigationType: NavigationType.pushAndRemoveUntil, removeUntilPredicate: (Route<dynamic> route) => false);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePhoto()));
                              // Analytics tracking code
                              analytics.setCurrentScreen(
                                  screenName: "onboarding_profile_picture",
                                  screenClassOverride:
                                      "onboarding_profile_picture");
                              amplitudeAnalytics
                                  .logEvent("onboarding_profile_picture_page");
                            },
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  color: AppColors.blueColor),
                            )),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
        ));
  }
}
