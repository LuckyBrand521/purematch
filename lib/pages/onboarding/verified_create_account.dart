import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/onboarding/first_welcome.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'icon_indicator.dart';

class VerifiedCreateAccount extends StatelessWidget {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(1);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: SafeArea(
        child: Column(children: <Widget>[
          SizedBox(
            height: 45,
          ),
          IconIndicator(
            imageAsset: "assets/images/verified_icon.png",
            currentIndicatorIndex: 2,
          ),
          SizedBox(
            height: 25,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: <Widget>[
                Text(
                  "Your device has been verified! What next?",
                  style: TextStyle(
                      fontSize:
                          AppConfig.heightWithDForSmallDevice(context, 36, 6),
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 75, 25),
                ),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 60, 10),
                  child: PlatformButton(
                    padding: EdgeInsets.all(
                        (AppConfig.fullWidth(context) >= 375) ? 15 : 10),
                    color: AppColors.blueColor,
                    disabledColor: AppColors.blueColor,
                    materialFlat: (_, __) => MaterialFlatButtonData(
                      color: AppColors.blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    cupertino: (_, __) => CupertinoButtonData(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text("Create New Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: AppConfig.heightWithDForSmallDevice(
                                context, 20, 4),
                          )),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FirstWelcome()));
                      //Analytics tracking page
                      analytics.setCurrentScreen(
                          screenName: "first_welcome",
                          screenClassOverride: "first_welcome");
                      amplitudeAnalytics.logEvent("first_welcome_page");
                    },
                  ),
                ),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 20, 4),
                ),
                Visibility(
                  visible: false,
                  child: SizedBox(
                    height: 60,
                    child: PlatformButton(
                      onPressed: () {},
                      padding: EdgeInsets.all(15),
                      color: AppColors.facebookButtonColor,
                      disabledColor: AppColors.facebookButtonColor,
                      materialFlat: (_, __) => MaterialFlatButtonData(
                        color: AppColors.facebookButtonColor,
                        disabledColor: AppColors.facebookButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      cupertino: (_, __) => CupertinoButtonData(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Image.asset(
                              'assets/images/facebook.png',
                              height: 25,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Continue with Facebook",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ]))
        ]),
      ),
    );
  }
}
