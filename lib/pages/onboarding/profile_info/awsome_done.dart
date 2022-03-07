import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/routes.dart';
import 'package:sailor/sailor.dart';

import '../OnboardingMyProfile.dart';

// ignore: must_be_immutable
class AwesomeDone extends StatelessWidget {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  Widget build(BuildContext context) {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.removeOnboardingId();

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
                //Analytics tracking code
                analytics.setCurrentScreen(
                    screenName: "onboarding_match_preference",
                    screenClassOverride: "onboarding_match_preference");
                amplitudeAnalytics.logEvent("onboarding_match_preference_page");
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
                    //Analytics tracking code
                    analytics.setCurrentScreen(
                        screenName: "onboarding_match_preference",
                        screenClassOverride: "onboarding_dating_preference");
                    amplitudeAnalytics
                        .logEvent("onboarding_match_preference_page");
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
                  height: height * 0.1,
                ),
                Text(
                  "Awesome!",
                  style: TextStyle(
                      fontSize: AppConfig.fontsizeForSmallDevice(context, 48),
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 80, 20),
                ),
                Text(
                  "Now let’s review everything to \nmake sure it’s correct.",
                  style: TextStyle(
                      fontSize: AppConfig.fontsizeForSmallDevice(context, 28),
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
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
                              // Routes.sailor.navigate("/homes",
                              //     params: {'tabIndex': 4},
                              //     navigationType:
                              //         NavigationType.pushAndRemoveUntil,
                              //     removeUntilPredicate:
                              //         (Route<dynamic> route) => false);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OnboardingMyProfile()));
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
                                  fontSize: 20,
                                  color: AppColors.blueColor,
                                  fontWeight: FontWeight.w700),
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
