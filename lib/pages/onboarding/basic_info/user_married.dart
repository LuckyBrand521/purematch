import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_body_type.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_married_warning.dart';

class UserMarried extends StatefulWidget {
  @override
  _UserMarriedState createState() => _UserMarriedState();
}

class _UserMarriedState extends State<UserMarried> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int marriedStatus = -1;
  String error = "";
  String status1 = "Single";
  String status2 = "In a Relationship";
  String status3 = "Married";
  String status4 = "Divorced";
  bool _loading = false;

  Future<void> _setMarriedStatus() async {
    setState(() {
      _loading = true;
    });
    var res = await MyHttp.put(
        "users/update", {"marital_status": this.marriedStatus});
    if (res?.statusCode == 200) {
      _sendOnBoardingEvent(analytics, this.marriedStatus);
      print("User updated");
      print(res.body);
      Map map = Map<String, Object>();
      if (this.marriedStatus == 1 || this.marriedStatus == 2) {
        map.putIfAbsent("matching_active", () => false);
        Global.matching_active = false;
      } else {
        map.putIfAbsent("matching_active", () => true);
        Global.matching_active = true;
      }
      var res1 = await MyHttp.post("settings/privacy_settings/update", map);
      print(res1.body);
      if (res1.statusCode != 200) {
        Global.matching_active = true;
      }
      _loading = false;
      setState(() {});
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        var body = json.decode(res.body);
        error = body["message"] ?? "error";
        _loading = false;
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(14);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Colors.white,
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            padding: EdgeInsetsDirectional.only(start: 10.0),
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.offWhiteColor,
              size: 25,
            ),
            iconSize: 30,
            onPressed: () {
              Navigator.pop(context);
              //Analytics code
              analytics.setCurrentScreen(
                  screenName: "onboarding_user_gender_height",
                  screenClassOverride: "onboarding_user_gender_height");
              amplitudeAnalytics.logEvent("onboarding_user_gender_height_page");
            },
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            backgroundColor: Colors.white,
            border: Border(bottom: BorderSide.none),
            padding: EdgeInsetsDirectional.only(start: 10.0),
            leading: CupertinoNavigationBarBackButton(
                color: AppColors.offWhiteColor,
                previousPageTitle: null,
                onPressed: () {
                  Navigator.pop(context);
                  //Analytics code
                  analytics.setCurrentScreen(
                      screenName: "onboarding_user_gender_height",
                      screenClassOverride: "onboarding_user_gender_height");
                  amplitudeAnalytics
                      .logEvent("onboarding_user_gender_height_page");
                })),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: AppConfig.heightWithDForSmallDevice(context, 10, 4),
              ),
              RoundIndicators(
                currentIndicatorIndex: 8,
                numberOfInidcators: 14,
                circleSize: 12,
              ),
              SizedBox(
                height: AppConfig.heightWithDForSmallDevice(context, 30, 15),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("I am…",
                        style: TextStyle(
                            fontSize:
                                AppConfig.fontsizeForSmallDevice(context, 36),
                            fontWeight: FontWeight.w600)),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 30, 15),
                    ),
                    MyButtons.getBorderedButton(status1, AppColors.blueColor,
                        () {
                      setState(() {
                        this.marriedStatus = 0;
                        (_loading == false) ? this._setMarriedStatus() : null;
                      });
                    }, this.marriedStatus == 0),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 10, 4),
                    ),
                    MyButtons.getBorderedButton(status2, AppColors.blueColor,
                        () {
                      setState(() {
                        this.marriedStatus = 1;
                        (_loading == false) ? this._setMarriedStatus() : null;
                      });
                    }, this.marriedStatus == 1),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 10, 4),
                    ),
                    MyButtons.getBorderedButton(status3, AppColors.blueColor,
                        () {
                      setState(() {
                        this.marriedStatus = 2;
                        (_loading == false) ? this._setMarriedStatus() : null;
                      });
                    }, this.marriedStatus == 2),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 10, 4),
                    ),
                    MyButtons.getBorderedButton(status4, AppColors.blueColor,
                        () {
                      setState(() {
                        this.marriedStatus = 3;
                        (_loading == false) ? this._setMarriedStatus() : null;
                      });
                    }, this.marriedStatus == 3),
                  ],
                ),
              ),
              SizedBox(
                height: AppConfig.heightWithDForSmallDevice(context, 10, 4),
              ),
              Center(
                child: Text(
                  "This information will not be displayed on\nyour profile. Instead, a colored circle will\nappear around your profile indicating your\navailability.",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: AppConfig.fontsizeForSmallDevice(context, 18),
                      color: AppColors.redColor),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: AppConfig.heightWithDForSmallDevice(context, 20, 10),
              ),
              Container(
                width: AppConfig.fullWidth(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_getPictureGuide(1), _getPictureGuide(2)],
                ),
              ),
              SizedBox(
                height: AppConfig.heightWithDForSmallDevice(context, 20, 10),
              ),
              Padding(
                  padding: EdgeInsetsDirectional.only(
                      bottom: 15.0, start: 30.0, end: 30.0),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: (_loading)
                          ? PlatformCircularProgressIndicator()
                          : SizedBox(
                              height: 60,
                              child: PlatformButton(
                                  onPressed: (marriedStatus != -1)
                                      ? () {
                                          // Go Continue
                                          if (this.marriedStatus != 2 &&
                                              this.marriedStatus != 1) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserBodyType()));
                                            // Analytics tracking code
                                            analytics.setCurrentScreen(
                                                screenName:
                                                    'onboarding_user_body_type',
                                                screenClassOverride:
                                                    'onboarding_user_body_type');
                                            amplitudeAnalytics.logEvent(
                                                "onboarding_user_body_type_page");
                                          } else {
                                            print(
                                                "married selected-go to feed");
                                            // Go married warning
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserMarriedWarning()));
                                          }
                                        }
                                      : null,
                                  color: AppColors.blueColor,
                                  disabledColor: AppColors.disabledBlueColor,
                                  materialFlat: (_, __) =>
                                      MaterialFlatButtonData(
                                        color: AppColors.blueColor,
                                        disabledColor:
                                            AppColors.disabledBlueColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                        fontSize: 20),
                                  )),
                            )))
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _getPictureGuide(int index) {
    return SizedBox(
      width: 150,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(
                width: 2,
                color: (index == 2)
                    ? AppColors.redColor
                    : AppColors.matchBrowseMatchReactivateMatching,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Image.asset(
                "assets/images/userpic.png",
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            (index == 2)
                ? "In a Relationship,\nMarried, Matching OFF"
                : "Single,\nDivorced",
            style: TextStyle(
              color: AppColors.blackColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Analytics tracking code
  Future<void> _sendOnBoardingEvent(
      FirebaseAnalytics analytics, int status) async {
    List statusList = ["Single", "In a Relationship", "Married", "Divorced"];
    int status = -1;
    String marital_status = "";
    if (status == 0) {
      marital_status = statusList[0];
    } else if (status == 1) {
      marital_status = statusList[1];
    } else if (status == 2) {
      marital_status = statusList[2];
    } else if (status == 3) {
      marital_status = statusList[3];
    }
    analytics.logEvent(
        name: "saved_marital_status",
        parameters: <String, dynamic>{'marital_status': marital_status});
    amplitudeAnalytics.logEvent("saved_marital_status",
        eventProperties: {'marital_status': marital_status});
  }
}
