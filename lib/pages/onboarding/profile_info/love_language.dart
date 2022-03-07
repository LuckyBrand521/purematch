import 'dart:convert';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/listviewcard.dart';
import 'package:pure_match/pages/onboarding/profile_info/user_dating_preference.dart';

import '../../AppColors.dart';
import '../../MyHttp.dart';

class LoveLanguage extends StatefulWidget {
  @override
  _LoveLanguageState createState() => _LoveLanguageState();
}

class _LoveLanguageState extends State<LoveLanguage> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String error = "";
  bool _loading = false;

  List<String> loveLanguage = [
    'Words of Affirmation',
    'Quality Time',
    'Physical Touch',
    'Gifts',
    'Acts of Service'
  ];

  void _setLoveLanguge() async {
    setState(() {
      _loading = true;
    });
    String position = "position";

    var details = new Map();

    details = loveLanguage
        .asMap()
        .map((key, value) => MapEntry(position + (key + 1).toString(), value));
    print(details);

    var res = await MyHttp.put("users/love-languages", details);
    if (res.statusCode == 201) {
      //Analytics tracking code
      analytics.logEvent(
          name: "saved_love_language",
          parameters: <String, dynamic>{"set_love_language": details[0]});
      amplitudeAnalytics.logEvent("set_love_language",
          eventProperties: {"saved_love_language": details[0]});
      print("Love Language updated");
      print(res.body);
      _loading = false;
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserDatingPreference()));

      //Analytics tracking code
      analytics.setCurrentScreen(
          screenName: "onboarding_match_preference",
          screenClassOverride: "onboarding_match_preference");
      amplitudeAnalytics.logEvent("onboarding_match_preference_page");
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
    Global.setOnboardingId(26);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return PlatformScaffold(
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
              // Analytics tracking code
              analytics.setCurrentScreen(
                  screenName: "onboarding_personality_type",
                  screenClassOverride: "onboarding_personality_type");
              amplitudeAnalytics.logEvent("onboarding_personality_type_page");
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
                      screenName: "onboarding_personality_type",
                      screenClassOverride: "onboarding_personality_type");
                  amplitudeAnalytics
                      .logEvent("onboarding_personality_type_page");
                })),
      ),
      body: SafeArea(
          child: Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: AppConfig.heightWithDForSmallDevice(
                                    context, 10, 4),
                              ),
                              RoundIndicators(
                                currentIndicatorIndex: 4,
                                numberOfInidcators: 6,
                                circleSize: 12,
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(
                                  AppConfig.heightWithDForSmallDevice(
                                      context, 30, 10),
                                ),
                              ),
                              Text(
                                  "Rearrange these love\nLanguage in order of\nimportance to you:",
                                  style: TextStyle(
                                      fontSize:
                                          AppConfig.fontsizeForSmallDevice(
                                              context, 28),
                                      fontWeight: FontWeight.w600)),
                              SizedBox(
                                height: ScreenUtil().setHeight(
                                  AppConfig.heightWithDForSmallDevice(
                                      context, 20, 10),
                                ),
                              ),
                              Container(
                                color: AppColors.greyColor,
                                height: 0.50 * height,
                                child: ReorderableListView(
                                  onReorder: _onReorder,
                                  scrollDirection: Axis.vertical,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  children: List.generate(
                                    loveLanguage.length,
                                    (index) {
                                      return ListViewCard(
                                        loveLanguage,
                                        index,
                                        Key('$index'),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(
                                  AppConfig.heightWithDForSmallDevice(
                                      context, 20, 10),
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.only(bottom: 30.0),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    height: 60,
                                    width: 200,
                                    child: FlatButton(
                                        onPressed: () {
                                          (_loading == false)
                                              ? _setLoveLanguge()
                                              : null;
                                        },
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 55),
                                        color: AppColors.blueColor,
                                        disabledColor:
                                            AppColors.disabledBlueColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                            ]))),
              ))),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(
      () {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final String item = loveLanguage.removeAt(oldIndex);
        loveLanguage.insert(newIndex, item);
      },
    );
  }
}
