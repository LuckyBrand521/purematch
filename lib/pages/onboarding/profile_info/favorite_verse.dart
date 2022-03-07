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
import 'package:pure_match/pages/onboarding/profile_info/user_interests.dart';
import 'package:flutter/cupertino.dart';

class FavoriteVerse extends StatefulWidget {
  @override
  _FavoriteVerseState createState() => _FavoriteVerseState();
}

class _FavoriteVerseState extends State<FavoriteVerse> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String _verse = "";
  bool _loading = false;
  String error = "";
  int _charCount = 0;

  void _setFavoriteVerse() async {
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
      "favorite_verse": this._verse,
    });
    if (res.statusCode == 200) {
      //Analytics code
      analytics.logEvent(
          name: "saved_favorite_verse",
          parameters: <String, dynamic>{"verse": this._verse});
      amplitudeAnalytics.logEvent('saved_favorite_verse',
          eventProperties: {"verse": this._verse});

      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserInterests()));

      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: "onboarding_user_interest",
          screenClassOverride: "onboarding_user_interest");
      amplitudeAnalytics.logEvent("onboarding_user_interest_page");
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
    Global.setOnboardingId(23);
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
                  screenName: "onboarding_about_yourself",
                  screenClassOverride: "onboarding_about_yourself");
              amplitudeAnalytics.logEvent("onboarding_about_yourself_page");
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
                      screenName: "onboarding_about_yourself",
                      screenClassOverride: "onboarding_about_yourself");
                  amplitudeAnalytics.logEvent("onboarding_about_yourself_page");
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
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 10, 4),
                    ),
                    RoundIndicators(
                      currentIndicatorIndex: 2,
                      numberOfInidcators: 6,
                      circleSize: 12,
                    ),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 50, 15),
                    ),
                    Text(
                      "Tell us your favorite verse",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 36)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.noExplaintationBorderColor,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          children: [
                            PlatformTextField(
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              maxLines: 10,
                              onChanged: (String text) {
                                this._verse = text;
                                setState(() {
                                  _charCount = text.length;
                                });
                              },
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: AppConfig.fontsizeForSmallDevice(
                                      context, 18),
                                  fontWeight: FontWeight.w400),
                              material: (_, __) => MaterialTextFieldData(
                                decoration: InputDecoration(
                                  hintText: "Type here...",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w300,
                                    fontSize: AppConfig.fontsizeForSmallDevice(
                                        context, 14),
                                  ),
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
                                placeholder: "Type here...",
                                placeholderStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300,
                                  fontSize: AppConfig.fontsizeForSmallDevice(
                                      context, 14),
                                ),
                                keyboardAppearance: Brightness.light,
                                padding: const EdgeInsets.all(20.0),
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
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 20, 10),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 60,
                        width: 220,
                        child: PlatformButton(
                          onPressed: (this._verse.isNotEmpty && _charCount > 5)
                              ? () {
                                  (_loading == false)
                                      ? this._setFavoriteVerse()
                                      : null;
                                }
                              : null,
                          color: AppColors.blueColor,
                          disabledColor: AppColors.disabledBlueColor,
                          child: Text(
                            "Continue",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                          ),
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
                        ),
                      ),
                    ),
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
