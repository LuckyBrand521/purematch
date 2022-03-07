import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/onboarding/soFarSoGood.dart';

class UserKids extends StatefulWidget {
  @override
  _UserKidsState createState() => _UserKidsState();
}

class _UserKidsState extends State<UserKids> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int currentKidsStatus = -1;
  int futureKidsStatus = -1;
  String error = "";
  bool _loading = false;

  var currentKids = ["No kids", "Kids away\n from home", "Kids at home"];
  var futureKids = ["I don’t want kids", "I'm open to kids", "I want kids"];
  var currentKids1 = ["No kids", "Kids away from home", "Kids at home"];
  var futureKids1 = ["Doesn't want kids", "Open to kids", "Wants kids"];

  Future<void> _setKids() async {
    setState(() {
      _loading = true;
    });
    var res = await MyHttp.put("users/update", {
      "kids_have":
          this.currentKids1[this.currentKidsStatus].replaceAll("\n", ""),
      "kids_want": this.futureKids1[this.futureKidsStatus].replaceAll("\n", "")
    });
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics
          .logEvent(name: "saved_kids_status", parameters: <String, dynamic>{
        'current_kids_status': this.currentKids[this.currentKidsStatus],
        'futureKidsStatus': this.futureKids[this.futureKidsStatus]
      });

      amplitudeAnalytics.logEvent("saved_kids_status", eventProperties: {
        'current_kids_status': this.currentKids[this.currentKidsStatus],
        'futureKidsStatus': this.futureKids[this.futureKidsStatus]
      });

      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SoFarSoGood()));
      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: 'basic_info_done',
          screenClassOverride: 'basic_info_done');
      amplitudeAnalytics.logEvent("basic_info_done_page");
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        var body = json.decode(res.body);
        error = body["message"] ?? "error";
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(19);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            padding: EdgeInsetsDirectional.only(start: 20.0),
            icon: Icon(Icons.arrow_back, color: AppColors.offWhiteColor),
            onPressed: () {
              Navigator.pop(context);
              // Analytics tracking code
              analytics.setCurrentScreen(
                  screenName: 'onboarding_user_work',
                  screenClassOverride: 'onboarding_user_work');
              amplitudeAnalytics.logEvent("onboarding_user_work_page");
            },
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            automaticallyImplyLeading: false,
            automaticallyImplyMiddle: false,
            backgroundColor: Colors.white,
            border: Border(bottom: BorderSide.none),
            padding: EdgeInsetsDirectional.only(start: 10.0),
            leading: CupertinoNavigationBarBackButton(
                color: AppColors.offWhiteColor,
                previousPageTitle: null,
                onPressed: () {
                  Navigator.pop(context);
                  // Analytics tracking code
                  analytics.setCurrentScreen(
                      screenName: 'onboarding_user_work',
                      screenClassOverride: 'onboarding_user_work');
                  amplitudeAnalytics.logEvent("onboarding_user_work_page");
                })),
      ),
      body: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 10, 4)),
                  ),
                  RoundIndicators(
                    currentIndicatorIndex: 13,
                    numberOfInidcators: 14,
                    circleSize: 12,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 40, 10)),
                  ),
                  Text(
                    "As for kids I have...",
                    style: TextStyle(
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 36),
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 30, 10)),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: ScreenUtil().setHeight(
                                  AppConfig.heightWithDForSmallDevice(
                                      context, 10, 4)),
                            ),
                            MyButtons.getBorderedButton(
                                currentKids[0], AppColors.blueColor, () {
                              setState(() {
                                this.currentKidsStatus = 0;
                              });
                            }, this.currentKidsStatus == 0,
                                fontSize: AppConfig.fontsizeForSmallDevice(
                                    context, 18)),
                            SizedBox(
                              height: ScreenUtil().setHeight(10),
                            ),
                            MyButtons.getBorderedButton(
                                currentKids[1], AppColors.blueColor, () {
                              setState(() {
                                this.currentKidsStatus = 1;
                              });
                            }, this.currentKidsStatus == 1,
                                verticalPadding: 8.0,
                                fontSize: AppConfig.fontsizeForSmallDevice(
                                    context, 18)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil().setHeight(5),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: ScreenUtil().setHeight(10),
                            ),
                            MyButtons.getBorderedButton(
                                currentKids[2], AppColors.blueColor, () {
                              setState(() {
                                this.currentKidsStatus = 2;
                              });
                            }, this.currentKidsStatus == 2,
                                fontSize: AppConfig.fontsizeForSmallDevice(
                                    context, 18)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 20, 10)),
                  ),
                  Center(
                    child: Text(
                      "and...",
                      style: TextStyle(
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 24),
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 20, 10)),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: ScreenUtil().setHeight(
                                  AppConfig.heightWithDForSmallDevice(
                                      context, 10, 4)),
                            ),
                            MyButtons.getBorderedButton(
                                futureKids[0], AppColors.blueColor, () {
                              setState(() {
                                this.futureKidsStatus = 0;
                              });
                            }, this.futureKidsStatus == 0,
                                fontSize: AppConfig.fontsizeForSmallDevice(
                                    context, 18)),
                            SizedBox(
                              height: 10,
                            ),
                            MyButtons.getBorderedButton(
                                futureKids[1], AppColors.blueColor, () {
                              setState(() {
                                this.futureKidsStatus = 1;
                              });
                            }, this.futureKidsStatus == 1,
                                fontSize: AppConfig.fontsizeForSmallDevice(
                                    context, 18)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil().setHeight(5),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: ScreenUtil().setHeight(
                                  AppConfig.heightWithDForSmallDevice(
                                      context, 10, 4)),
                            ),
                            MyButtons.getBorderedButton(
                                futureKids[2], AppColors.blueColor, () {
                              setState(() {
                                this.futureKidsStatus = 2;
                              });
                            }, this.futureKidsStatus == 2,
                                fontSize: AppConfig.fontsizeForSmallDevice(
                                    context, 18)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 20.0),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height: 60,
                            width: 220,
                            child: PlatformButton(
                                onPressed: (this.currentKidsStatus != -1 &&
                                        this.futureKidsStatus != -1)
                                    ? () {
                                        (_loading == false)
                                            ? this._setKids()
                                            : null;
                                      }
                                    : null,
                                color: AppColors.blueColor,
                                disabledColor: AppColors.disabledBlueColor,
                                materialFlat: (_, __) => MaterialFlatButtonData(
                                      color: AppColors.blueColor,
                                      disabledColor:
                                          AppColors.disabledBlueColor,
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
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                )),
                          ))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
