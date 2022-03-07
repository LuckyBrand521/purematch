import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_ethnicity.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';

class UserBodyType extends StatefulWidget {
  @override
  _UserBodyTypeState createState() => _UserBodyTypeState();
}

class _UserBodyTypeState extends State<UserBodyType> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
  int bodyType = -1;
  var bodyTypes = [
    "Thin",
    "Athletic",
    "Average",
    "Plus Size",
    "Prefer not to say"
  ];
  String error = "";
  bool _loading = false;

  Future<void> _setBodyType() async {
    setState(() {
      _loading = true;
    });
    var res =
        await MyHttp.put("users/update", {"body_stat": bodyTypes[bodyType]});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "saved_body_type",
          parameters: <String, dynamic>{'body_type': bodyTypes[bodyType]});
      amplitudeAnalytics.logEvent("saved_body_type",
          eventProperties: {'body_type': bodyTypes[bodyType]});
      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserEthnicity()));
      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: 'onboarding_user_ethnicity',
          screenClassOverride: 'onboarding_user_ethnicity');
      amplitudeAnalytics.logEvent("onboarding_user_ethnicity_page");
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
    Global.setOnboardingId(15);
  }

  @override
  Widget build(BuildContext context) {
    var heignt = MediaQuery.of(context).size.height * 0.05;
    double heightt = MediaQuery.of(context).size.height;

    List<Widget> button = List<Widget>();

    for (var i = 0; i < bodyTypes.length; i++) {
      button.add(Column(
        children: <Widget>[
          SizedBox(
            height: AppConfig.heightWithDForSmallDevice(context, 10, 4),
          ),
          MyButtons.getBorderedButton(bodyTypes[i], AppColors.blueColor, () {
            setState(() {
              this.bodyType = i;
              (_loading == false) ? this._setBodyType() : null;
            });
          }, this.bodyType == i),
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
                  screenName: 'onboarding_marital_status',
                  screenClassOverride: 'onboarding_marital_status');
              amplitudeAnalytics.logEvent("onboarding_marital_status_page");
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
                      screenName: 'onboarding_marital_status',
                      screenClassOverride: 'onboarding_marital_status');
                  amplitudeAnalytics.logEvent("onboarding_marital_status_page");
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
                    height: AppConfig.heightWithDForSmallDevice(context, 10, 4),
                  ),
                  RoundIndicators(
                    currentIndicatorIndex: 9,
                    numberOfInidcators: 14,
                    circleSize: 12,
                  ),
                  SizedBox(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 50, 25),
                  ),
                  Text("I would describe my Body Type as…",
                      style: TextStyle(
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 36),
                          fontWeight: FontWeight.w600)),
                  SizedBox(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 30, 10),
                  ),
                  Column(
                    children: button,
                  ),
                  SizedBox(height: heightt * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
