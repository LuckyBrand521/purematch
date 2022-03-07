import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/onboarding/basic_info/location_tutorial.dart';
import 'dart:io' show Platform;

import '../../MyHttp.dart';

class UserBirthDate extends StatefulWidget {
  @override
  _UserBirthDateState createState() => _UserBirthDateState();
}

class _UserBirthDateState extends State<UserBirthDate> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String month = "";
  String date = "";
  String year = "";
  String error = "";
  DateTime pickedDate;
  bool validationCheck = true;
  bool _loading = false;
  // bool pressed = false;
  Future<void> _setBirthDate() async {
    setState(() {
      _loading = true;
    });
    String birthday;
    if (pickedDate == null) {
      birthday = "$year-$month-$date";
    } else {
      birthday = pickedDate.toString();
    }
    print("***********");
    print(birthday);
    var res = await MyHttp.put("users/update", {"birthday": birthday});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "saved_birthday",
          parameters: <String, dynamic>{'date_of_birth': "$year-$month-$date"});

      amplitudeAnalytics.logEvent("saved_birthday",
          eventProperties: {'date_of_birth': "$year-$month-$date"});
      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LocationTutorial()));
      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: 'onboarding_user_location',
          screenClassOverride: 'onboarding_user_location');
      amplitudeAnalytics.logEvent("onboarding_user_location_page");
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
    bool validation = false;
    try {
      DateTime givenDate;
      if (this.pickedDate == null) {
        givenDate = DateTime.parse("$year-$month-$date");
      } else {
        givenDate = pickedDate;
      }
      int ageInDays = DateTime.now().difference(givenDate).inDays;
      if (ageInDays >= 6570 && ageInDays <= 36500) {
        validation = true;
      }
    } on FormatException catch (e) {
      print("Error: ${e.message}");
    }

    setState(() {
      // this.pressed = false;
      validationCheck = validation;
      print(validationCheck);
    });
  }

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(8);
  }

  @override
  Widget build(BuildContext context) {
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
                  screenName: 'onbording_user_name',
                  screenClassOverride: 'onbording_user_name');
              amplitudeAnalytics.logEvent("onbording_user_name_page");
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 20, 4),
                ),
                RoundIndicators(
                  currentIndicatorIndex: 2,
                  numberOfInidcators: 14,
                  circleSize: 12,
                ),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 40, 10),
                ),
                Text("My Birthday is...",
                    style: TextStyle(
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 36, 4),
                        fontWeight: FontWeight.w600)),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 20, 4),
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
                        onEditingComplete: () =>
                            FocusScope.of(context).nextFocus(),
                        maxLength: 2,
                        keyboardType: TextInputType.number,
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
                  height: 50,
                ),
                Visibility(
                  visible: Platform.isAndroid &&
                      !this.validationCheck, 
                      // && this.pressed,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Please enter the valid date",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.redColor,
                        fontWeight: FontWeight.w400,
                      ),
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
                                            // setState(() {
                                            //   this.pressed = true;
                                            // });
                                            (_loading == false)
                                                ? this._setBirthDate()
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
                        screenName: 'onbording_user_name',
                        screenClassOverride: 'onbording_user_name');
                    amplitudeAnalytics.logEvent("onbording_user_name_page");
                  })),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 20, 4),
                ),
                RoundIndicators(
                  currentIndicatorIndex: 3,
                  numberOfInidcators: 13,
                  circleSize: 12,
                ),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 50, 10),
                ),
                Container(
                    child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 32.0),
                  child: Text("My Birthday is...",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w600,
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 36, 4),
                      )),
                )),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 50, 10),
                ),
                Center(
                    child: SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 300, 40),
                        child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime:
                                DateTime.now().subtract(Duration(days: 6570)),
                            minimumYear: 1920,
                            maximumYear: DateTime.now().year,
                            onDateTimeChanged: (newDateTime) {
                              setState(() {
                                pickedDate = newDateTime;
                              });
                              validateDate();
                            }))),
                Expanded(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: EdgeInsetsDirectional.only(bottom: 35),
                            child: SizedBox(
                                height: AppConfig.heightWithDForSmallDevice(
                                    context, 60, 10),
                                width: 220,
                                child: CupertinoButton(
                                    color: AppColors.blueColor,
                                    disabledColor: AppColors.disabledBlueColor,
                                    borderRadius: BorderRadius.circular(10),
                                    onPressed: (this.validationCheck == true)
                                        ? () {
                                            (_loading == false)
                                                ? this._setBirthDate()
                                                : null;
                                          }
                                        : null,
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
