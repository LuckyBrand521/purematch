import 'dart:convert';
import 'dart:ui';

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
import 'package:pure_match/pages/onboarding/basic_info/user_work.dart';
import 'package:flutter/cupertino.dart';

class UserEducation extends StatefulWidget {
  @override
  _UserEducationState createState() => _UserEducationState();
}

class _UserEducationState extends State<UserEducation> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int education = -1;
  String error = "";
  bool _loading = false;
  String schoolName = "";
  var educationLevels = [
    "High School",
    "Bachelor",
    "Doctorate",
    "Associate",
    "Graduate",
    "Professional"
  ];

  Future<void> _setEducation() async {
    setState(() {
      _loading = true;
    });
    var res = await MyHttp.put("users/update", {
      "education": this.educationLevels[this.education],
      "school_name": schoolName
    });
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(name: "saved_education", parameters: <String, dynamic>{
        'education': educationLevels[this.education]
      });
      amplitudeAnalytics.logEvent("saved_education",
          eventProperties: {'education': educationLevels[this.education]});

      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserWork()));

      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: 'onboarding_user_work',
          screenClassOverride: 'onboarding_user_work');
      amplitudeAnalytics.logEvent("onboarding_user_work_page");
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
    Global.setOnboardingId(17);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> button1 = List<Widget>();

    for (var i = 0; i < 3; i++) {
      button1.add(Column(
        children: <Widget>[
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          MyButtons.getBorderedButton(educationLevels[i], AppColors.blueColor,
              () {
            setState(() {
              this.education = i;
            });
          }, this.education == i),
        ],
      ));
    }

    List<Widget> button2 = List<Widget>();

    for (var i = 3; i < educationLevels.length; i++) {
      button2.add(Column(
        children: <Widget>[
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          MyButtons.getBorderedButton(educationLevels[i], AppColors.blueColor,
              () {
            setState(() {
              this.education = i;
            });
          }, this.education == i),
        ],
      ));
    }

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
                  screenName: 'onboarding_user_ethnicity',
                  screenClassOverride: 'onboarding_user_ethnicity');
              amplitudeAnalytics.logEvent("onboarding_user_ethnicity_page");
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
                      screenName: 'onboarding_user_ethnicity',
                      screenClassOverride: 'onboarding_user_ethnicity');
                  amplitudeAnalytics.logEvent("onboarding_user_ethnicity_page");
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
                    height: AppConfig.heightWithDForSmallDevice(context, 10, 6),
                  ),
                  RoundIndicators(
                    currentIndicatorIndex: 11,
                    numberOfInidcators: 14,
                    circleSize: 12,
                  ),
                  SizedBox(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 40, 10),
                  ),
                  Text(
                    "What’s your highest level of Education?",
                    style: TextStyle(
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 36),
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 30, 10),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: button1,
                        ),
                      ),
                      SizedBox(
                        width:
                            AppConfig.heightWithDForSmallDevice(context, 10, 5),
                      ),
                      Expanded(
                        child: Column(
                          children: button2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 30, 10),
                  ),
                  Text(
                    "Where did you go to school?",
                    style: TextStyle(
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 36),
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.start,
                  ),
                  PlatformTextField(
                    style: TextStyle(
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 22),
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.w600),
                    onChanged: (String schoolName) {
                      this.schoolName = schoolName;
                      setState(() {});
                    },
                    textCapitalization: TextCapitalization.words,
                    material: (_, __) => MaterialTextFieldData(
                      decoration: InputDecoration(
                          hintText: "School Name",
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
                      placeholder: "School Name",
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
                        AppConfig.heightWithDForSmallDevice(context, 136, 50)),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 20.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 60,
                        width: 220,
                        child: PlatformButton(
                            onPressed: (this.schoolName.trim().isNotEmpty &&
                                    this.education != -1)
                                ? () {
                                    (_loading == false)
                                        ? this._setEducation()
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
                  ),
                  //
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
