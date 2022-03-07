import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

import 'basic_info/user_name.dart';

class ThankYouQues extends StatefulWidget {
  // Analytics code
  @override
  _ThankYouQuesState createState() => _ThankYouQuesState();
}

class _ThankYouQuesState extends State<ThankYouQues> {
  FirebaseAnalytics analytics = FirebaseAnalytics();

  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");

  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  void initState() {
    super.initState();
    //Initializing amplitude analytics api
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(5);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return PlatformScaffold(
      backgroundColor: AppColors.blueColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: height * 0.15,
              ),
              Text("Thank You!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          AppConfig.heightWithDForSmallDevice(context, 48, 4),
                      fontWeight: FontWeight.w700)),
              SizedBox(
                height: AppConfig.heightWithDForSmallDevice(context, 40, 10),
              ),
              Text("Your responses will be reviewed by our team.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          AppConfig.heightWithDForSmallDevice(context, 24, 4),
                      fontWeight: FontWeight.w700)),
              SizedBox(
                height: AppConfig.heightWithDForSmallDevice(context, 40, 10),
              ),
              Text("Let’s continue with some basic information.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          AppConfig.heightWithDForSmallDevice(context, 28, 4),
                      fontWeight: FontWeight.w700)),
              Expanded(
                child: SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 20, 4),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical:
                        AppConfig.heightWithDForSmallDevice(context, 20, 4),
                  ),
                  child: SizedBox(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 60, 10),
                    width:
                        AppConfig.heightWithDForSmallDevice(context, 300, 20),
                    child: PlatformButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserName()));
                          // Analytics tracking code
                          analytics.setCurrentScreen(
                              screenName: "onboarding_user_email",
                              screenClassOverride: "onboarding_user_email");
                          amplitudeAnalytics
                              .logEvent("onboarding_user_email_page");
                        },
                        padding: EdgeInsets.symmetric(
                            vertical: AppConfig.heightWithDForSmallDevice(
                                context, 20, 4),
                            horizontal: 55),
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
                              color: AppColors.blueColor,
                              fontSize: AppConfig.heightWithDForSmallDevice(
                                  context, 20, 4),
                              fontWeight: FontWeight.w700),
                        )),
                  ),
                ),
              ),
              //)
            ],
          ),
        ),
      ),
    );
  }
}
