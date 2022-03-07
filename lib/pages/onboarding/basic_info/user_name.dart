import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_birth_date.dart';
import 'package:flutter/cupertino.dart';

class UserName extends StatefulWidget {
  @override
  _UserNameState createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String firstName = "";
  String lastName = "";
  bool _loading = false;

  void _setName() async {
    setState(() {
      _loading = true;
    });
    var res = await MyHttp.put(
        "users/update", {"first_name": firstName, "last_name": lastName});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(name: "saved_name", parameters: <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName
      });
      amplitudeAnalytics.logEvent("saved_name",
          eventProperties: {'first_name': firstName, 'last_name': lastName});

      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserBirthDate()));
      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: 'onboarding_user_birth_date',
          screenClassOverride: 'onboarding_user_birth_date');
      amplitudeAnalytics.logEvent("onboarding_user_birth_date_page");
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(7);
  }

  @override
  Widget build(BuildContext context) {
    double pageSize = MediaQuery.of(context).size.height;
    double notifySize = MediaQuery.of(context).padding.top;
    double appBarSize = Platform.isIOS
        ? CupertinoNavigationBar().preferredSize.height
        : AppBar().preferredSize.height;
    double scHeight = pageSize -
        (appBarSize + notifySize) -
        20 -
        MediaQuery.of(context).padding.bottom;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        backgroundColor: Colors.white,
        material: (_, __) => MaterialAppBarData(
          elevation: 0.0,
          leading: IconButton(
            padding: EdgeInsetsDirectional.only(start: 20.0),
            icon: Icon(Icons.arrow_back, color: AppColors.offWhiteColor),
            onPressed: () {
              Navigator.pop(context);
              //Analytics code
              analytics.setCurrentScreen(
                  screenName: "onboarding_user_email",
                  screenClassOverride: "onboarding_user_email");
              amplitudeAnalytics.logEvent("onboarding_user_email_page");
            },
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            brightness: Brightness.dark,
            automaticallyImplyLeading: false,
            automaticallyImplyMiddle: false,
            border: Border(bottom: BorderSide.none),
            padding: EdgeInsetsDirectional.only(start: 10.0),
            leading: CupertinoNavigationBarBackButton(
                color: AppColors.offWhiteColor,
                previousPageTitle: null,
                onPressed: () {
                  Navigator.pop(context);
                  //Analytics code
                  analytics.setCurrentScreen(
                      screenName: "onboarding_user_email",
                      screenClassOverride: "onboarding_user_email");
                  amplitudeAnalytics.logEvent("onboarding_user_email_page");
                })),
      ),
      body: SafeArea(
          child: Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: SizedBox(
                  height: scHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            RoundIndicators(
                              currentIndicatorIndex: 1,
                              numberOfInidcators: 14,
                              circleSize: 12,
                            ),
                            SizedBox(
                              height: AppConfig.heightWithDForSmallDevice(
                                  context, 50, 10),
                            ),
                            Text("My Name is...",
                                style: TextStyle(
                                    fontSize:
                                        AppConfig.heightWithDForSmallDevice(
                                            context, 36, 4),
                                    fontWeight: FontWeight.w600)),
                            SizedBox(
                              height: AppConfig.heightWithDForSmallDevice(
                                  context, 30, 10),
                            ),
                            PlatformTextField(
                              style: TextStyle(
                                  fontSize: AppConfig.heightWithDForSmallDevice(
                                      context, 28, 4),
                                  color: AppColors.blueColor,
                                  fontWeight: FontWeight.w700),
                              textCapitalization: TextCapitalization.words,
                              onChanged: (String name) {
                                setState(() {
                                  firstName = name;
                                });
                              },
                              material: (_, __) => MaterialTextFieldData(
                                decoration: InputDecoration(
                                    hintText: "First Name",
                                    hintStyle: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                        color: Colors.grey),
                                    contentPadding: EdgeInsets.all(0.0),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.blueColor,
                                            width: 2))),
                              ),
                              cupertino: (_, __) => CupertinoTextFieldData(
                                keyboardAppearance: Brightness.light,
                                placeholder: "First Name",
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: AppColors.blueColor, width: 2),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppConfig.heightWithDForSmallDevice(
                                  context, 30, 10),
                            ),
                            PlatformTextField(
                              style: TextStyle(
                                  fontSize: AppConfig.heightWithDForSmallDevice(
                                      context, 28, 4),
                                  color: AppColors.blueColor,
                                  fontWeight: FontWeight.w700),
                              textCapitalization: TextCapitalization.words,
                              onChanged: (String name) {
                                setState(() {
                                  lastName = name;
                                });
                              },
                              material: (_, __) => MaterialTextFieldData(
                                decoration: InputDecoration(
                                    hintText: "Last Name",
                                    hintStyle: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                        color: Colors.grey),
                                    contentPadding: EdgeInsets.all(0.0),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.blueColor,
                                            width: 2))),
                              ),
                              cupertino: (_, __) => CupertinoTextFieldData(
                                keyboardAppearance: Brightness.light,
                                placeholder: "Last Name",
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: AppColors.blueColor, width: 2),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                        Spacer(),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                                child: SizedBox(
                              height: 60,
                              width: 220,
                              child: PlatformButton(
                                  onPressed:
                                      (this.firstName.trim().isNotEmpty &&
                                              this.lastName.trim().isNotEmpty)
                                          ? () {
                                              (_loading == false)
                                                  ? this._setName()
                                                  : null;
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
                                        fontSize: 16),
                                  )),
                            )))
                      ],
                    ),
                  ),
                ),
              ))),
    );
  }
}
