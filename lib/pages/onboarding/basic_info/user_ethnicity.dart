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
import 'package:pure_match/pages/onboarding/basic_info/user_education.dart';
import 'package:flutter/cupertino.dart';

class UserEthnicity extends StatefulWidget {
  @override
  _UserEthnicityState createState() => _UserEthnicityState();
}

class _UserEthnicityState extends State<UserEthnicity> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  var ethnicities = [];
  String error = "";
  bool _loading = false;

  var bodyTypes = [
    "Indigenous/Native\nAmerican",
    "East/Southeast\nAsian",
    "Hispanic/Latinx",
    "Pacific Islander",
    "Mixed Race",
    "Black/African\ndescent",
    "South Asian",
    "Middle Eastern",
    "White",
    "Other",
  ];
  E firstOrNull<E>(List<E> list) {
    return list == null || list.isEmpty ? null : list.first;
  }

  Future<void> _setBodyType() async {
    setState(() {
      _loading = true;
    });
    var ethnicitiesWord = this.ethnicities.map((d) {
      return this.bodyTypes[d].replaceAll("\n", " ");
    });

    var first = firstOrNull(ethnicitiesWord.toList());
    if (first == null) {
      return;
    }
    int index = -1;
    if (first == "Indigenous/Native American") {
      index = 1;
    } else if (first == "East/Southeast Asian") {
      index = 3;
    } else if (first == "Hispanic/Latinx") {
      index = 5;
    } else if (first == "Pacific Islander") {
      index = 7;
    } else if (first == "Mixed Race") {
      index = 9;
    } else if (first == "Black/African descent") {
      index = 2;
    } else if (first == "South Asian") {
      index = 4;
    } else if (first == "Middle Eastern") {
      index = 6;
    } else if (first == "White") {
      index = 8;
    } else if (first == "Other") {
      index = 10;
    }
    var res = await MyHttp.put("users/update", {"ethnicity": index});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(name: "saved_ethnicity", parameters: <String, dynamic>{
        'ethnicity': ethnicitiesWord.toList()[0]
      });
      amplitudeAnalytics.logEvent("saved_ethnicity",
          eventProperties: {'ethnicity': ethnicitiesWord.toList()[0]});

      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserEducation()));
      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: "onboarding_user_education",
          screenClassOverride: "user_education");
      amplitudeAnalytics.logEvent("onboarding_user_education_page");
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
    Global.setOnboardingId(16);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    List<Widget> button1 = List<Widget>();

    for (var i = 0; i < 5; i++) {
      button1.add(Column(
        children: <Widget>[
          SizedBox(
            height: ScreenUtil().setHeight(11),
          ),
          MyButtons.getBorderedButton(bodyTypes[i], AppColors.blueColor, () {
            setState(() {
              if (this.ethnicities.contains(i))
                this.ethnicities.remove(i);
              else
                this.ethnicities.add(i);
            });
          }, this.ethnicities.contains(i),
              fontSize: 15.0,
              unselectedButtonFontWt: FontWeight.w500,
              verticalPadding: bodyTypes[i] == "Indigenous/Native\nAmerican" ||
                      bodyTypes[i] == "East/Southeast\nAsian"
                  ? 8.0
                  : 20.0),
        ],
      ));
    }

    // ignore: deprecated_member_use
    List<Widget> button2 = List<Widget>();

    for (var i = 5; i < bodyTypes.length; i++) {
      button2.add(Column(
        children: <Widget>[
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          MyButtons.getBorderedButton(bodyTypes[i], AppColors.blueColor, () {
            setState(() {
              if (this.ethnicities.contains(i))
                this.ethnicities.remove(i);
              else
                this.ethnicities.add(i);
            });
          }, this.ethnicities.contains(i),
              fontSize: 15.0,
              unselectedButtonFontWt: FontWeight.w500,
              verticalPadding:
                  bodyTypes[i] == "Black/African\ndescent" ? 8.0 : 20.0),
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
                  screenName: 'onboarding_user_body_type',
                  screenClassOverride: 'onboarding_user_body_type');
              amplitudeAnalytics.logEvent("onboarding_user_body_type_page");
            },
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            brightness: Brightness.dark,
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
                      screenName: 'onboarding_user_body_type',
                      screenClassOverride: 'onboarding_user_body_type');
                  amplitudeAnalytics.logEvent("onboarding_user_body_type_page");
                })),
      ),
      body: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  RoundIndicators(
                    currentIndicatorIndex: 10,
                    numberOfInidcators: 14,
                    circleSize: 12,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  Text(
                    "My Ethnicity is…\n(select all that apply)",
                    style: TextStyle(
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 32),
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(20),
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
                        width: ScreenUtil().setHeight(5),
                      ),
                      Expanded(
                        child: Column(
                          children: button2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 150, 50)),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 20.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 60,
                        width: 220,
                        child: PlatformButton(
                            onPressed: (this.ethnicities.isNotEmpty)
                                ? () {
                                    (_loading == false)
                                        ? this._setBodyType()
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
