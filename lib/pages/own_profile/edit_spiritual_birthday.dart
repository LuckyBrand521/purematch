import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/own_profile/edit_profile_details_app_bar.dart';
import 'package:sailor/sailor.dart';
import '../../routes.dart';
import '../AppColors.dart';
import '../MyHttp.dart';
import 'dart:io' show Platform;
import 'package:pure_match/extensions/string_extension.dart';

import 'edit_spiritual_birthday_year.dart';

class EditSpiritualBirthday extends StatefulWidget {
  final String spiritualBirthday;
  final bool isFromOnboarding;
  final Function onUpdateProfile;
  EditSpiritualBirthday(
      this.spiritualBirthday, this.isFromOnboarding, this.onUpdateProfile);

  @override
  EditSpiritualBirthdayState createState() => EditSpiritualBirthdayState();
}

class EditSpiritualBirthdayState extends State<EditSpiritualBirthday> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String month;
  String date;
  String year;
  DateTime pickedDate;
  DateTime pickedDate1;
  TextEditingController monthCtrl, dateCtrl, yearCtrl;
  bool validationCheck;
  DateTime now = DateTime.now();
  String error = "";

  @override
  void initState() {
    pickedDate = widget.spiritualBirthday.validateStringToDate()
        ? DateTime.parse(widget.spiritualBirthday)
        : now;
    pickedDate1 = pickedDate;
    month = pickedDate.month.toString();
    date = pickedDate.day.toString();
    year = pickedDate.year.toString();
    validateDate();
    monthCtrl = new TextEditingController();
    dateCtrl = new TextEditingController();
    yearCtrl = new TextEditingController();
    monthCtrl.text = month;
    dateCtrl.text = date;
    yearCtrl.text = year;
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "spiritual_birthday",
        screenClassOverride: "spiritual_birthday");
    amplitudeAnalytics.logEvent("spiritual_birthday_page");
  }

  @override
  void dispose() {
    monthCtrl.dispose();
    dateCtrl.dispose();
    yearCtrl.dispose();
    super.dispose();
  }

  bool isChangedValues() {
    var isChanged = false;
    DateTime spiritualBirthday;
    if (Platform.isAndroid) {
      spiritualBirthday = DateTime.parse(
          "$year-${month.padLeft(2, '0')}-${date.padLeft(2, '0')}");
    } else {
      spiritualBirthday = pickedDate;
    }
    if (pickedDate1 != spiritualBirthday) {
      isChanged = true;
    }
    return isChanged;
  }

  void validateDate() {
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
        validationCheck = true;
      });
    }
  }

  Future<void> _setYearsInChrist() async {
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
      analytics.logEvent(name: "edited_profile", parameters: <String, dynamic>{
        'spiritual_birthday': "$year-$month-$date"
      });
      amplitudeAnalytics.logEvent("edited_profile",
          eventProperties: {'spiritual_birthday': "$year-$month-$date"});

      print("User updated");
      print(res.body);

      if (widget.isFromOnboarding != null && widget.isFromOnboarding) {
        Navigator.pop(context);
        widget.onUpdateProfile();
      } else {
        Global.ownProfileSaved = true;
        Routes.sailor.navigate("/homes",
            params: {'tabIndex': 4},
            navigationType: NavigationType.pushAndRemoveUntil,
            removeUntilPredicate: (Route<dynamic> route) => false);
      }
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        error = res.statusCode.toString() + " " + res.body;
      });
    }
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
      appBar: EditProfileDetailsAppBar(
        context: context,
        text: "Edit Years Since Baptism",
        titleSize: AppConfig.heightWithDForSmallDevice(context, 22, 4),
      ).getAppBar1(isChangedValues()),
      body: PlatformScaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
              child: SizedBox(
                height: scHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 20, 10),
                      ),
                      Text("When were you baptized into Christ?",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 28)),
                      SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 20, 10),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: PlatformWidget(
                          material: (_, __) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 70,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: TextField(
                                  maxLength: 2,
                                  keyboardType: TextInputType.number,
                                  controller: monthCtrl,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize:
                                          AppConfig.heightWithDForSmallDevice(
                                              context, 22, 4),
                                      color: AppColors.blueColor),
                                  onChanged: (String month) {
                                    if (month.isNotEmpty) {
                                      this.month = month;
                                      this.validateDate();
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: "MM",
                                      counterText: "",
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: -10),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.blueColor,
                                              width: 2))),
                                ),
                              ),
                              Text(
                                "/",
                                style: TextStyle(
                                    fontSize: 35, color: AppColors.blueColor),
                              ),
                              Container(
                                width: 70,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: TextField(
                                  maxLength: 2,
                                  keyboardType: TextInputType.number,
                                  controller: dateCtrl,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 22, color: AppColors.blueColor),
                                  onChanged: (String date) {
                                    if (date.isNotEmpty) {
                                      this.date = date;
                                      this.validateDate();
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: "DD",
                                      counterText: "",
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: -10),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.blueColor,
                                              width: 2))),
                                ),
                              ),
                              Text(
                                "/",
                                style: TextStyle(
                                    fontSize: 35, color: AppColors.blueColor),
                              ),
                              Container(
                                width: 90,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: TextField(
                                  maxLength: 4,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: yearCtrl,
                                  style: TextStyle(
                                      fontSize:
                                          AppConfig.heightWithDForSmallDevice(
                                              context, 22, 4),
                                      color: AppColors.blueColor),
                                  onChanged: (String year) {
                                    if (year.isNotEmpty) {
                                      this.year = year;
                                      this.validateDate();
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: "YYYY",
                                      counterText: "",
                                      contentPadding: EdgeInsets.all(0),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.blueColor,
                                              width: 2))),
                                ),
                              )
                            ],
                          ),
                          cupertino: (_, __) => Center(
                              child: SizedBox(
                                  height: 200,
                                  child: CupertinoDatePicker(
                                      mode: CupertinoDatePickerMode.date,
                                      initialDateTime: pickedDate,
                                      minimumYear: now
                                          .subtract(Duration(days: 36500))
                                          .year,
                                      maximumYear: now.year,
                                      onDateTimeChanged: (newDateTime) {
                                        setState(() {
                                          pickedDate = newDateTime;
                                        });
                                      }))),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConfig.heightWithDForSmallDevice(
                              context, 15, 5),
                        ),
                        child: Center(
                          child: PlatformWidget(
                            material: (_, __) => InkWell(
                              child: Text("Don't remember the exact date?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize:
                                          AppConfig.heightWithDForSmallDevice(
                                              context, 18, 4),
                                      color: AppColors.blueColor,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline)),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditSpiritualBirthdayYear(
                                              this.year))),
                            ),
                            cupertino: (_, __) => CupertinoButton(
                              child: Text("Don't remember the exact date?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize:
                                          AppConfig.heightWithDForSmallDevice(
                                              context, 18, 4),
                                      color: AppColors.blueColor,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline)),
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditSpiritualBirthdayYear(this
                                              .pickedDate
                                              .year
                                              .toString()))),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            AppConfig.heightWithDForSmallDevice(context, 15, 5),
                      ),
                      Center(
                        child: Text(
                          this.error,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: AppConfig.heightWithDForSmallDevice(
                                  context, 15, 5),
                              fontWeight: FontWeight.w500,
                              color: AppColors.redColor),
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Visibility(
                        visible:
                            Platform.isAndroid && this.validationCheck == false,
                        child: Text(
                          "Please enter valid date. Please enter the month first, then day, then year.",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.redColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          height: 60,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: PlatformButton(
                                onPressed: (this.validationCheck)
                                    ? () {
                                        _setYearsInChrist();
                                      }
                                    : null,
                                color: AppColors.blueColor,
                                disabledColor: AppColors.disabledBlueColor,
                                materialFlat: (_, __) => MaterialFlatButtonData(
                                      color: AppColors.blueColor,
                                      disabledColor:
                                          AppColors.disabledBlueColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                cupertinoFilled: (_, __) =>
                                    CupertinoFilledButtonData(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                child: Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize:
                                        AppConfig.heightWithDForSmallDevice(
                                            context, 20, 5),
                                  ),
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
        ),
      ),
    );
  }
}
