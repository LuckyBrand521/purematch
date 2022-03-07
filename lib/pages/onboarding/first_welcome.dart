import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/onboarding/moderator_notes.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

class FirstWelcome extends StatelessWidget {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(2);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return PlatformScaffold(
        backgroundColor: AppColors.blueColor,
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
                //Analytics code
                analytics.setCurrentScreen(
                    screenName: "device_verified",
                    screenClassOverride: "device_verified");
                amplitudeAnalytics.logEvent("device_verified_page");
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
                        screenName: "device_verified",
                        screenClassOverride: "device_verified");
                    amplitudeAnalytics.logEvent("device_verified_page");
                  })),
        ),
        body: SafeArea(
          child: PlatformScaffold(
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
                    "Welcome to Pure Match!",
                    style: TextStyle(
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 48, 8),
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: AppConfig.heightWithDForSmallDevice(context, 20, 4),
                  ),
                  Text(
                    "Let’s start with some questions.",
                    style: TextStyle(
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 28, 8),
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: AppConfig.heightWithDForSmallDevice(context, 20, 4),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(bottom: 25),
                        child: SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 60, 10),
                          width: AppConfig.heightWithDForSmallDevice(
                              context, 300, 20),
                          child: PlatformButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ModeratorNotes()));

                              //Analytics tracking code
                              analytics.setCurrentScreen(
                                  screenName: "moderator_notes",
                                  screenClassOverride: "moderator_notes");
                              amplitudeAnalytics
                                  .logEvent("moderator_notes_page");
                            },
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  color: AppColors.blueColor,
                                  fontSize: AppConfig.heightWithDForSmallDevice(
                                      context, 20, 4),
                                  fontWeight: FontWeight.w700),
                              //textAlign: TextAlign.center,
                            ),
                            color: Colors.white,
                            materialFlat: (_, __) => MaterialFlatButtonData(
                              color: Colors.white,
                              disabledColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            cupertino: (_, __) => CupertinoButtonData(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
          ),
        ));
  }
}
