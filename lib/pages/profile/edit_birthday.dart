import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:sailor/sailor.dart';
import 'dart:io' show Platform;

import '../../routes.dart';
import '../MyHttp.dart';

class EditBirthDate extends StatefulWidget {
  final User user;
  final bool isFromOnboarding;
  final Function() onUpdateProfile;

  const EditBirthDate(
      {Key key, this.user, this.isFromOnboarding, this.onUpdateProfile})
      : super(key: key);

  @override
  _EditBirthDateState createState() => _EditBirthDateState();
}

class _EditBirthDateState extends State<EditBirthDate> {
  String month = "";
  String date = "";
  String year = "";
  String error = "";
  DateTime pickedDate;
  bool validationCheck = false;
  bool _loading = false;

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

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
    var res = await MyHttp.put("users/update", {"birthday": birthday});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "edited_birthday",
          parameters: <String, dynamic>{'birthday': birthday});
      amplitudeAnalytics.logEvent('edited_birthday');

      print("User updated");
      print(res.body);
      _loading = false;

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
      if (ageInDays >= 5840 && ageInDays <= 36500) {
        validation = true;
      }
    } on FormatException catch (e) {
      print("Error: ${e.message}");
    }

    setState(() {
      validationCheck = validation;
      print(validationCheck);
    });
  }

  @override
  Widget build(BuildContext context) {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    print(widget.user);

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
                  height: 20,
                ),
                Text("My Birthday is...",
                    style: TextStyle(
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 36, 8),
                        fontWeight: FontWeight.w600)),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 20, 10),
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
                      width: 70,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        onEditingComplete: () =>
                            FocusScope.of(context).nextFocus(),
                        maxLength: 2,
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
                                          fontSize:
                                              (AppConfig.fullHeight(context) >=
                                                      667)
                                                  ? 20
                                                  : 15),
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
              automaticallyImplyLeading: false,
              automaticallyImplyMiddle: false,
              backgroundColor: CupertinoColors.white,
              border: Border(bottom: BorderSide.none),
              padding: EdgeInsetsDirectional.only(start: 10.0),
              leading: CupertinoNavigationBarBackButton(
                  color: AppColors.offWhiteColor,
                  previousPageTitle: null,
                  onPressed: () => Navigator.pop(context))),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 20, 10),
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
                            AppConfig.heightWithDForSmallDevice(context, 36, 8),
                      )),
                )),
                SizedBox(
                  height: AppConfig.heightWithDForSmallDevice(context, 50, 25),
                ),
                Center(
                    child: SizedBox(
                        height: 300,
                        child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: widget.user.birthday.isEmpty
                                ? DateTime.now().subtract(Duration(days: 6570))
                                : DateTime.parse(widget.user.birthday),
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
                                height: 60,
                                // width: 220,
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
                                      "Save Changes",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w700,
                                          fontSize:
                                              (AppConfig.fullHeight(context) >=
                                                      667)
                                                  ? 20
                                                  : 15),
                                    ))))))
              ]));
    }
  }
}
