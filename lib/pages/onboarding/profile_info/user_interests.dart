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
import 'package:pure_match/pages/onboarding/profile_info/personality_type.dart';
import 'package:flutter/cupertino.dart';

class UserInterests extends StatefulWidget {
  @override
  _UserInterestsState createState() => _UserInterestsState();
}

class _UserInterestsState extends State<UserInterests> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  bool buttonDisabled = true;
  List<String> interests = [
    "Hiking",
    "Dancing",
    "Salsa Dancing",
    "Football",
    "Running",
    "Reading",
    "Nature",
    "Dogs",
    "Cats",
    "Art",
    "Movies",
    "Video Games",
    "Basketball",
    "Ping Pong",
    "Weight Lifting",
    "Politics",
    "Teaching",
    "Technology",
    "AR/VR",
    "Eating Out",
    "Nutrition",
    "TV Shows",
    "Singing",
    "Knitting",
    "Fashion",
    "Traveling",
    "Eightball Pool",
    "Volleyball",
    "Olympics",
    "Soccer",
    "Baking",
    "Crypto\ncurrency",
    "Feeding the Poor",
    "Music",
    "Learning",
    "Photography",
    "Family",
    "Work/Career",
    "Tabletop Games",
    "Crafts",
    "Cooking",
    "Swing Dancing",
    "Karaoke",
    "Archery",
    "Sushi",
    "Fantasy",
    "Sci-Fi",
    "Comics"
  ];
  List<String> selectedInterests = [];
  String error = "";
  bool _loading = false;

  void _setInterests() async {
    setState(() {
      _loading = true;
    });
    var res =
        await MyHttp.put("users/update", {"interests": this.selectedInterests});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics
          .logEvent(name: "saved_user_interest", parameters: <String, dynamic>{
        'user_interests1': selectedInterests[0],
        'user_interests2': selectedInterests[1],
        'user_interest3': selectedInterests[2]
      });

      amplitudeAnalytics.logEvent("saved_user_interest", eventProperties: {
        'user_interests1': selectedInterests[0],
        'user_interests2': selectedInterests[1],
        'user_interest3': selectedInterests[2]
      });

      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PersonalityType()));

      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: "onboarding_personality_type",
          screenClassOverride: "onboarding_personality_type");
      amplitudeAnalytics.logEvent("onboarding_personality_type_page");
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
    Global.setOnboardingId(24);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> renderInterests = [];
    int mainEnd = interests.length ~/ 3;
    print(mainEnd);

    for (int i = 0; i < mainEnd + 1; i++) {
      renderInterests.add(SizedBox(
        height: 10,
      ));
      int start = i * 3;
      int end = start + 3;
      List<Widget> l = [];
      for (int j = start; j < end && j < interests.length; j++) {
        l.add(SizedBox(
          width: 15,
        ));
        l.add(Expanded(
            child: this._getButton(interests[j], () {
          bool isSelected = this.selectedInterests.contains(interests[j]);
          if (isSelected == false) {
            this.selectedInterests.add(interests[j]);
          } else {
            this.selectedInterests.remove(interests[j]);
          }
          setState(() {});
        }, this.selectedInterests.contains(interests[j]))));
      }
      renderInterests.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: l,
      ));
    }

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

              // Analytics tracking code
              analytics.setCurrentScreen(
                  screenName: "onboarding_favorite_verse",
                  screenClassOverride: "onboarding_favorite_verse");
              amplitudeAnalytics.logEvent("onboarding_favorite_verse_page");
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
                      screenName: "onboarding_favorite_verse",
                      screenClassOverride: "onboarding_favorite_verse");
                  amplitudeAnalytics.logEvent("onboarding_favorite_verse_page");
                })),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: ScreenUtil().setHeight(10),
                ),
                RoundIndicators(
                  currentIndicatorIndex: 3,
                  numberOfInidcators: 6,
                  circleSize: 12,
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(40),
                ),
                Text(
                  "Select at least 3 Interests",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(10),
                ),
                Text(
                  "Scroll to see more choices!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(40),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.blueColor, width: 2.1),
                  ),
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: renderInterests,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(20),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 60,
                      width: 220,
                      child: PlatformButton(
                          onPressed: (this.selectedInterests.length >= 3)
                              ? () {
                                  (_loading == false)
                                      ? this._setInterests()
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
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _getButton(String text, Function f, bool fill) {
    return SizedBox(
      height: 48,
      width: 85,
      child: FlatButton(
          onPressed: f,
          color: fill ? AppColors.blueColor : Colors.white,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: AppColors.blueColor, width: 2)),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: fill ? Colors.white : AppColors.blueColor,
                fontWeight: FontWeight.w600,
                fontSize: 12),
          )),
    );
  }
}
