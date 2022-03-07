import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';

import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/cupertino.dart';

import 'package:pure_match/routes.dart';
import 'package:sailor/sailor.dart';

class ProfileConfirm extends StatefulWidget {
  const ProfileConfirm({Key key}) : super(key: key);
  @override
  _ProfileConfirmState createState() => _ProfileConfirmState();
}

class _ProfileConfirmState extends State<ProfileConfirm> {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");

  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  Future<void> _goFeedScreen() {
    Global.removeOnboardingId();
    Routes.sailor.navigate("/homes",
        params: {'tabIndex': 0},
        navigationType: NavigationType.pushAndRemoveUntil,
        removeUntilPredicate: (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.removeOnboardingId();

    return PlatformScaffold(
        appBar: PlatformAppBar(
          material: (_, __) => MaterialAppBarData(
            backgroundColor: AppColors.matchBrowseMatchReactivateMatching,
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
              backgroundColor: AppColors.matchBrowseMatchReactivateMatching,
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
          backgroundColor: AppColors.matchBrowseMatchReactivateMatching,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Congratulations!",
                        style: TextStyle(
                            fontSize: AppConfig.heightWithDForSmallDevice(
                                context, 36, 18),
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 20, 10)),
                      Image.asset(
                        "assets/images/nav_gem_active.png",
                        width: 198 / 896 * AppConfig.fullHeight(context),
                        height: 178 / 896 * AppConfig.fullHeight(context),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                        height:
                            AppConfig.heightWithDForSmallDevice(context, 14, 7),
                      ),
                      Text(
                        "Welcome to Pure Match!",
                        style: TextStyle(
                            fontSize: AppConfig.heightWithDForSmallDevice(
                                context, 22, 10),
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "You've just earned your first",
                            style: TextStyle(
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 22, 10),
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            " Award",
                            style: TextStyle(
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 22, 10),
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "and received ",
                            style: TextStyle(
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 22, 10),
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          Image.asset(
                            "assets/images/gem_medium_icon.png",
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                          Text(
                            " 100 pure gems",
                            style: TextStyle(
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 22, 10),
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Text(
                        "our unique in-app currency.",
                        style: TextStyle(
                            fontSize: AppConfig.heightWithDForSmallDevice(
                                context, 22, 10),
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 60, 20),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 19),
                        child: Image.asset(
                          "assets/images/nav_bar_profile_confirm.png",
                          width: double.infinity,
                          height: 95,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Check out the ",
                            style: TextStyle(
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 22, 10),
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Rewards",
                            style: TextStyle(
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 22, 10),
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            " section",
                            style: TextStyle(
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 22, 10),
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Text(
                        "to view your awards and discover\nmore ways to earn Pure Gems!",
                        style: TextStyle(
                            fontSize: AppConfig.heightWithDForSmallDevice(
                                context, 22, 10),
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.only(top: 30, bottom: 20),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: PlatformButton(
                              onPressed: () {
                                _goFeedScreen();
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
                                    color: AppColors
                                        .matchBrowseMatchReactivateMatching,
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
