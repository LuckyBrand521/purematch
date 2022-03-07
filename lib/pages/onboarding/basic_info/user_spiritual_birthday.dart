import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_gender.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_spiritual_year.dart';
import 'dart:io' show Platform;
import 'package:pure_match/extensions/string_extension.dart';

import '../../MyHttp.dart';

class UserSpiritualBirthDate extends StatefulWidget {
  @override
  _UserSpiritualBirthDateState createState() => _UserSpiritualBirthDateState();
}

class _UserSpiritualBirthDateState extends State<UserSpiritualBirthDate> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String month = "";
  String date = "";
  String year = "";
  String error = "";
  DateTime now = DateTime.now();
  DateTime pickedDate = DateTime.now();
  bool validationCheck = false;
  bool _loading = false;
  bool pressed = false;
  Future<void> _setYearsInChrist() async {
    setState(() {
      _loading = true;
    });

    DateTime spiritualBirthday;
    if (Platform.isAndroid) {
      spiritualBirthday = DateTime.parse("$year-$month-$date");
    } else {
      spiritualBirthday = pickedDate;
    }
    var res = await MyHttp.put("users/update",
        {"my_spiritual_birthday": spiritualBirthday.toIso8601String()});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "saved_spiritual_birthday",
          parameters: <String, dynamic>{
            'spiritual_birthday': "$year,$month,$date"
          });

      amplitudeAnalytics.logEvent("saved_spiritual_birthday",
          eventProperties: {'spiritual_birthday': "$year,$month,$date"});

      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserGender()));

      //Analytics code
      analytics.setCurrentScreen(
          screenName: "onboarding_user_gender_height",
          screenClassOverride: "onboarding_user_gender_height");
      amplitudeAnalytics.logEvent("onboarding_user_gender_height_page");
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

  void validateDate() {
    //This  code is for one of the conditions to show the error message when button is pressed
    setState(() {
      this.pressed = false;
    });
    // These conditions are for the android users who type in their dates. It prevents them from typing invalid dates
    // such as 11/31 or 2/29/2001
    if (Platform.isAndroid) {
      if (int.parse(month) > 12 || int.parse(date) > 31) {
        validationCheck = false;
      } else {
        if (int.parse(date) == 31 &&
            (int.parse(month) == 2 ||
                int.parse(month) == 4 ||
                int.parse(month) == 6 ||
                int.parse(month) == 9 ||
                int.parse(month) == 11)) {
          validationCheck = false;
        } else {
          if (int.parse(month) == 2 && (int.parse(date) == 30)) {
            validationCheck = false;
          } else {
            if (int.parse(month) == 2 &&
                int.parse(date) == 29 &&
                (int.parse(year) % 4 != 0)) {
              validationCheck = false;
            } else {
              setState(() {
                validationCheck = ("$year-$month-$date").validateStringToDate();
              });
            }
          }
        }
      }
    } else {
      setState(() {
        validationCheck = pickedDate.toIso8601String().validateStringToDate();
      });
    }
  }

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(12);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    if (Platform.isAndroid) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            padding: EdgeInsetsDirectional.only(start: 20.0),
            icon: Icon(Icons.arrow_back, color: AppColors.offWhiteColor),
            onPressed: () {
              Navigator.pop(context);
              // Analytics tracking code
              analytics.setCurrentScreen(
                  screenName: 'onboarding_user_church',
                  screenClassOverride: 'onboarding_user_church');
              amplitudeAnalytics.logEvent("onboarding_user_church_page");
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                RoundIndicators(
                  currentIndicatorIndex: 6,
                  numberOfInidcators: 14,
                  circleSize: 12,
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                Text("When were you baptized into Christ?",
                    style: TextStyle(
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 30),
                        fontWeight: FontWeight.w600)),
                SizedBox(
                  height: height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 70,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        maxLength: 2,
                        onEditingComplete: () =>
                            FocusScope.of(context).nextFocus(),
                        keyboardType: TextInputType.number,
                        //controller: TextEditingController(text: now.month.toString()),
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 22, color: AppColors.blueColor),
                        onChanged: (String month) {
                          (month.length == 2)
                              ? FocusScope.of(context).nextFocus()
                              : null;
                          this.month = month;
                          this.validateDate();
                        },
                        decoration: InputDecoration(
                            hintText: "MM",
                            counterText: "",
                            contentPadding: EdgeInsets.symmetric(vertical: -10),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.blueColor, width: 2))),
                      ),
                    ),
                    Text(
                      "/",
                      style:
                          TextStyle(fontSize: 35, color: AppColors.blueColor),
                    ),
                    Container(
                      width: 70,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        onEditingComplete: () =>
                            FocusScope.of(context).nextFocus(),
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 22, color: AppColors.blueColor),
                        onChanged: (String date) {
                          (date.length == 2)
                              ? FocusScope.of(context).nextFocus()
                              : null;
                          this.date = date;
                          this.validateDate();
                        },
                        decoration: InputDecoration(
                            hintText: "DD",
                            counterText: "",
                            contentPadding: EdgeInsets.symmetric(vertical: -10),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.blueColor, width: 2))),
                      ),
                    ),
                    Text(
                      "/",
                      style:
                          TextStyle(fontSize: 35, color: AppColors.blueColor),
                    ),
                    Container(
                      width: 90,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        maxLength: 4,
                        onEditingComplete: () =>
                            FocusScope.of(context).nextFocus(),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 22, color: AppColors.blueColor),
                        onChanged: (String year) {
                          this.year = year;
                          this.validateDate();
                        },
                        decoration: InputDecoration(
                            hintText: "YYYY",
                            counterText: "",
                            contentPadding: EdgeInsets.all(0),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.blueColor, width: 2))),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: InkWell(
                    child: Text("Don't remember the exact date?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline)),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserSpiritualYear())),
                  ),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Visibility(
                  visible: Platform.isAndroid && this.validationCheck == false,
                  child: Text(
                    "Please enter valid date. Please enter the month first, then day, then year.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.redColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: EdgeInsetsDirectional.only(bottom: 35),
                            child: SizedBox(
                                height: 60,
                                width: 200,
                                child: FlatButton(
                                    color: AppColors.blueColor,
                                    disabledColor: AppColors.disabledBlueColor,
                                    onPressed: (this.validationCheck == true)
                                        ? () {
                                            setState(() {
                                              this.pressed = true;
                                            });
                                            (_loading == false)
                                                ? this._setYearsInChrist()
                                                : null;
                                          }
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "Continue",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16.0),
                                    )))))),
              ],
            ),
          ),
        ),
      );
    } else if (Platform.isIOS) {
      return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.white,
          navigationBar: CupertinoNavigationBar(
              brightness: Brightness.dark,
              automaticallyImplyLeading: false,
              automaticallyImplyMiddle: false,
              backgroundColor: CupertinoColors.white,
              border: Border(bottom: BorderSide.none),
              padding: EdgeInsetsDirectional.only(start: 10.0),
              leading: CupertinoNavigationBarBackButton(
                  color: AppColors.offWhiteColor,
                  previousPageTitle: null,
                  onPressed: () {
                    Navigator.pop(context);
                    // Analytics tracking code
                    analytics.setCurrentScreen(
                        screenName: 'onboarding_user_church',
                        screenClassOverride: 'onboarding_user_church');
                    amplitudeAnalytics.logEvent("onboarding_user_church_page");
                  })),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 20, 10),
                ),
                RoundIndicators(
                  currentIndicatorIndex: 6,
                  numberOfInidcators: 14,
                  circleSize: 12,
                ),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 50, 10),
                ),
                Container(
                    child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 32.0),
                  child: Text("When were you baptized into Christ?",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 30),
                      )),
                )),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 30, 10),
                ),
                Center(
                    child: SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 200, 50),
                        child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: now,
                            minimumYear:
                                now.subtract(Duration(days: 36500)).year,
                            maximumYear: now.year,
                            onDateTimeChanged: (newDateTime) {
                              setState(() {
                                pickedDate = newDateTime;
                              });
                            }))),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: CupertinoButton(
                    child: Text("Don't remember the exact date?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline)),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserSpiritualYear())),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: EdgeInsetsDirectional.only(bottom: 20),
                            child: SizedBox(
                                height: 60,
                                width: 220,
                                child: CupertinoButton(
                                    color: AppColors.blueColor,
                                    disabledColor: AppColors.disabledBlueColor,
                                    borderRadius: BorderRadius.circular(10),
                                    onPressed: () {
                                      (_loading == false)
                                          ? this._setYearsInChrist()
                                          : null;
                                    },
                                    child: Text(
                                      "Continue",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16.0),
                                    ))))))
              ]));
    }
  }
}
