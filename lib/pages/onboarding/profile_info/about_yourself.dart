import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/profile_info/favorite_verse.dart';
import 'package:flutter/cupertino.dart';

class AboutYourself extends StatefulWidget {
  @override
  _AboutYourselfState createState() => _AboutYourselfState();
}

class _AboutYourselfState extends State<AboutYourself> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int _charCount = 0;

  String _aboutMe = "";
  String error = "";
  bool _loading = false;
  final whitespaces = RegExp(r'\s+', multiLine: true);

  void _sendAboutYourself() async {
    if (_charCount > 500) {
      Global.alertUserForCardAction(
          // context, "Sorry", "A maximum of 100 words are allowed.", "OK", () {
          context,
          "Sorry",
          "A maximum of 500 characters are allowed.",
          "OK", () {
        Navigator.pop(context);
      }, "", null, "", null);
      return;
    }
    setState(() {
      _loading = true;
    });
    var res = await MyHttp.put("users/update", {
      "about_me": this._aboutMe,
    });
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "saved_about_me",
          parameters: <String, dynamic>{'about_me': this._aboutMe});

      amplitudeAnalytics.logEvent("saved_about_me",
          eventProperties: {'about_me': "about_me"});

      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FavoriteVerse()));

      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: "onboarding_favorite_verse",
          screenClassOverride: "onboarding_favorite_verse");
      amplitudeAnalytics.logEvent("onboarding_favorite_verse_page");
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
    Global.setOnboardingId(22);
  }

  @override
  Widget build(BuildContext context) {
    var borderSideProperty = BorderSide(color: Colors.transparent, width: 0);
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
                  screenName: "onboarding_profile_picture",
                  screenClassOverride: "onboarding_profile_picture");
              amplitudeAnalytics.logEvent("onboarding_profile_picture_page");
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
                      screenName: "onboarding_profile_picture",
                      screenClassOverride: "onboarding_profile_picture");
                  amplitudeAnalytics
                      .logEvent("onboarding_profile_picture_page");
                })),
      ),
      body: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
            child: SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    RoundIndicators(
                      currentIndicatorIndex: 1,
                      numberOfInidcators: 6,
                      circleSize: 12,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Tell us about yourself",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 36),
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor),
                    ),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 20, 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.noExplaintationBorderColor,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          children: <Widget>[
                            PlatformTextField(
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              maxLines: 10,
                              onChanged: (String text) {
                                this._aboutMe = text;

                                setState(() {
                                  // _charCount = text.split(whitespaces).length;
                                  _charCount = text.length;
                                });
                              },
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                              material: (_, __) => MaterialTextFieldData(
                                decoration: InputDecoration(
                                  hintText: "Type here...",
                                  hintStyle: TextStyle(
                                      color: AppColors.blackColor,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14),
                                  contentPadding: const EdgeInsets.all(20.0),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      borderSide: borderSideProperty),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      borderSide: borderSideProperty),
                                ),
                              ),
                              cupertino: (_, __) => CupertinoTextFieldData(
                                keyboardAppearance: Brightness.light,
                                padding: const EdgeInsets.all(20.0),
                                placeholder: "Type here...",
                                placeholderStyle: TextStyle(
                                    color: AppColors.blackColor,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: Colors.transparent, width: 0),
                                ),
                              ),
                            ),
                            Text(_charCount.toString() + "/500 characters",
                                style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blueColor)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: 60,
                          width: 220,
                          child: PlatformButton(
                              onPressed:
                                  (this._aboutMe.isNotEmpty && _charCount > 5)
                                      ? () {
                                          (_loading == false)
                                              ? this._sendAboutYourself()
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
      ),
    );
  }
}
