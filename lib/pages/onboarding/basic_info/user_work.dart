import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_kids.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/common/MyButtons.dart';

class UserWork extends StatefulWidget {
  @override
  _UserWorkState createState() => _UserWorkState();
}

class _UserWorkState extends State<UserWork> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String position = "";
  String employer = "";
  String error = "";
  bool selfEmployed = false;
  bool _loading = false;

  Future<void> _setPosition() async {
    setState(() {
      _loading = true;
    });
    var res = await MyHttp.put(
        "users/update", {"position": this.position, "employer": this.employer});
    if (res.statusCode == 200) {
      // Analytics tracking code
      String status = this.selfEmployed == false ? "employed" : "self_employed";
      analytics.logEvent(
          name: "saved_work_status",
          parameters: <String, dynamic>{'employment_status': status});

      amplitudeAnalytics.logEvent("saved_work_status",
          eventProperties: {'employment_status': status});

      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserKids()));

      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: 'onboarding_user_kids',
          screenClassOverride: 'onboarding_user_kids');
      amplitudeAnalytics.logEvent("onboarding_user_kids_page");
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        _loading = false;
        var body = json.decode(res.body);
        error = body["message"] ?? "error";
      });
    }
  }

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(18);
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
                  screenName: "onboarding_user_education",
                  screenClassOverride: "onboarding_user_education");
              amplitudeAnalytics.logEvent("onboarding_user_education_page");
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
                      screenName: "onboarding_user_education",
                      screenClassOverride: "user_education");
                  amplitudeAnalytics.logEvent("onboarding_user_education_page");
                })),
      ),
      body: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  RoundIndicators(
                    currentIndicatorIndex: 12,
                    numberOfInidcators: 14,
                    circleSize: 12,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 40, 10)),
                  ),
                  Text(
                    "Where do you work?",
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 36),
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 40, 10)),
                  ),
                  Text("Position",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 30),
                          fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  PlatformTextField(
                    style: TextStyle(
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 22),
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.w600),
                    onChanged: (String position) {
                      this.position = position;
                      setState(() {});
                    },
                    textCapitalization: TextCapitalization.words,
                    material: (_, __) => MaterialTextFieldData(
                      decoration: InputDecoration(
                          hintText: "Job Title",
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize:
                                  AppConfig.fontsizeForSmallDevice(context, 18),
                              fontWeight: FontWeight.w300),
                          contentPadding: EdgeInsets.all(0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.blueColor, width: 2))),
                    ),
                    cupertino: (_, __) => CupertinoTextFieldData(
                      placeholder: "Job Title",
                      placeholderStyle: TextStyle(
                          color: Colors.grey,
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 18),
                          fontWeight: FontWeight.w300),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: AppColors.blueColor, width: 2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 50, 10)),
                  ),
                  Text("Company",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 30),
                          fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  PlatformTextField(
                    style: TextStyle(
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 22),
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.w600),
                    onChanged: (String employer) {
                      this.employer = employer;
                      setState(() {});
                    },
                    textCapitalization: TextCapitalization.words,
                    material: (_, __) => MaterialTextFieldData(
                      decoration: InputDecoration(
                          hintText: "Company Name",
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize:
                                  AppConfig.fontsizeForSmallDevice(context, 18),
                              fontWeight: FontWeight.w300),
                          contentPadding: EdgeInsets.all(0.0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.blueColor, width: 2))),
                    ),
                    cupertino: (_, __) => CupertinoTextFieldData(
                      placeholder: "Company Name",
                      placeholderStyle: TextStyle(
                          color: Colors.grey,
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 18),
                          fontWeight: FontWeight.w300),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: AppColors.blueColor, width: 2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 30, 10)),
                  ),
                  MyButtons.getBorderedButton(
                      "Self-Employed", AppColors.blueColor, () {
                    if (this.selfEmployed) {
                      setState(() {
                        this.selfEmployed = false;
                      });
                    } else {
                      setState(() {
                        this.selfEmployed = true;
                      });
                    }
                  }, this.selfEmployed == true),
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 230, 30)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 60,
                        width: 220,
                        child: PlatformButton(
                            onPressed: (this.position.trim().isNotEmpty &&
                                    this.employer.trim().isNotEmpty)
                                ? () {
                                    (_loading == false)
                                        ? this._setPosition()
                                        : null;
                                  }
                                : null,
                            color: AppColors.blueColor,
                            disabledColor: AppColors.disabledBlueColor,
                            materialFlat: (_, __) => MaterialFlatButtonData(
                                  color: AppColors.blueColor,
                                  disabledColor: AppColors.disabledBlueColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                            cupertinoFilled: (_, __) =>
                                CupertinoFilledButtonData(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            )),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
