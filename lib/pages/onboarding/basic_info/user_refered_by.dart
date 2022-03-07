import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/basic_info/referral_confirm.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_church.dart';

class UserReferredBy extends StatefulWidget {
  @override
  _UserReferredByState createState() => _UserReferredByState();
}

class _UserReferredByState extends State<UserReferredBy> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String code = "";
  bool validationCheck = false;
  String error = "";
  bool _loading = false;

  Future<void> _setReferredBy() async {
    setState(() {
      _loading = true;
    });
    var data = {"code": code};
    var res;
    try {
      res = await MyHttp.put("users/redeem-code", data);

      if (res.statusCode == 200) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ReferralConfirm()));

        //Analytics tracking code
        analytics.logEvent(
            name: "saved_refered_by",
            parameters: <String, dynamic>{'referal_code': code});

        amplitudeAnalytics.logEvent("saved_refered_by",
            eventProperties: {'referal_code': code});
      } else {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => UserChurch()));
        print(res.statusCode);
      }
      setState(() {
        _loading = false;
        ;
      });
    } catch (e) {
      print("Error: " + e);
      print(res.statuscode);
    }

    /* if (this.email.trim().isEmpty) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserChurch()));
      return;
    } */
  }

//  void _setNoReferral() {
//    setState(() {
//      this.email = null;
//    });
//    _setReferredBy();
//  }

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(10);
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
                  screenName: 'onboarding_user_location',
                  screenClassOverride: 'onboarding_user_location');
              amplitudeAnalytics.logEvent("onboarding_user_location_page");
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
                      screenName: 'onboarding_user_location',
                      screenClassOverride: 'onboarding_user_location');
                  amplitudeAnalytics.logEvent("onboarding_user_location_page");
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
                    height: AppConfig.heightWithDForSmallDevice(context, 20, 4),
                  ),
                  RoundIndicators(
                    currentIndicatorIndex: 4,
                    numberOfInidcators: 14,
                    circleSize: 12,
                  ),
                  SizedBox(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 50, 10),
                  ),
                  Text(
                    "Do you have a referral code?",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 30, 4),
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  PlatformTextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 18, 4),
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.w700),
                    onChanged: (String code) {
                      this.code = code;
                    },
                    material: (_, __) => MaterialTextFieldData(
                      decoration: InputDecoration(
                          hintText: "Enter your code",
                          contentPadding: EdgeInsets.all(0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.blueColor, width: 2))),
                    ),
                    cupertino: (_, __) => CupertinoTextFieldData(
                      keyboardAppearance: Brightness.light,
                      placeholder: "Enter your code",
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: AppColors.blueColor, width: 2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppConfig.heightWithDForSmallDevice(context, 20, 4),
                  ),
                  Center(
                    child: InkWell(
                        child: Text("I don't have a referral",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 15, 4),
                                color: AppColors.blueColor,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                decoration: TextDecoration.underline)),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserChurch()));

                          // Analytics tracking code
                          analytics.setCurrentScreen(
                              screenName: 'onboarding_user_church',
                              screenClassOverride: 'onboarding_user_church');
                          amplitudeAnalytics
                              .logEvent("onboarding_user_church_page");
                        }),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 60,
                        width: 220,
                        child: PlatformButton(
                            onPressed: () {
                              (_loading == false)
                                  ? this._setReferredBy()
                                  : null;
                            },
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
