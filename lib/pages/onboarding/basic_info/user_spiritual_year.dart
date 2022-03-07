import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_gender.dart';
import '../../AppColors.dart';
import '../../MyHttp.dart';
import 'dart:io' show Platform;

class UserSpiritualYear extends StatefulWidget {
  @override
  _UserSpiritualYearState createState() {
    return _UserSpiritualYearState();
  }
}

class _UserSpiritualYearState extends State<UserSpiritualYear> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String pickedYear = (DateTime.now().year - 5).toString();
  DateTime pickedDate =
      DateTime.parse((DateTime.now().year - 5).toString() + "-01-01");
  String error = "";

  Future<void> _setSpiritualYear() async {
    // Analytics tracking code
    analytics.setCurrentScreen(
        screenName: "spiritual_year", screenClassOverride: "spiritual_year");
    amplitudeAnalytics.logEvent("spiritual_year_page");

    String spiritualBirthday = Platform.isIOS
        ? DateTime.parse(this.pickedYear + "-01-01").toIso8601String()
        : this.pickedDate.toIso8601String();
    print(spiritualBirthday);
    // TODO: To check with algorithm developer whether the year only data is separately required. Options -> change my_spiritual_birthday to a String - "pickedYear-XX-XX 00:00:00.000" or create a new input for "spiritual_year" = 2020
    var res = await MyHttp.put(
        "users/update", {"my_spiritual_birthday": spiritualBirthday});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "saved_spiritual_year",
          parameters: <String, dynamic>{'spiritual_year': this.pickedYear});

      amplitudeAnalytics.logEvent("saved_spiritual_year",
          eventProperties: {'spiritual_year': this.pickedYear});
      print("User updated");
      print(res.body);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserGender()));
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        var body = json.decode(res.body);
        error = body["message"] ?? "error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);

    int prev100Year = DateTime.now().year - 100;
    return PlatformScaffold(
      backgroundColor: Colors.white,
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            padding: EdgeInsetsDirectional.only(start: 20.0),
            icon: Icon(Icons.arrow_back, color: AppColors.offWhiteColor),
            onPressed: () {
              Navigator.pop(context);
              //Analytics tracking code
              analytics.setCurrentScreen(
                  screenName: "spiritual_birthday",
                  screenClassOverride: "spiritual_year");
              amplitudeAnalytics.logEvent("spiritual_birthday_page");
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
                  //Analytics tracking code
                  analytics.setCurrentScreen(
                      screenName: "spiritual_birthday",
                      screenClassOverride: "spiritual_year");
                  amplitudeAnalytics.logEvent("spiritual_birthday_page");
                })),
      ),
      body: SafeArea(
        child: PlatformScaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              RoundIndicators(
                currentIndicatorIndex: 6,
                numberOfInidcators: 14,
                circleSize: 12,
              ),
              SizedBox(
                height: 50,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "No problem! Just select the year:",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize:
                          AppConfig.heightWithDForSmallDevice(context, 30, 10),
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: AppConfig.heightWithDForSmallDevice(context, 40, 10),
              ),
              PlatformWidget(
                cupertino: (_, __) => Center(
                  child: SizedBox(
                    height: 200,
                    width: 300,
                    child: CupertinoPicker(
                      itemExtent:
                          AppConfig.heightWithDForSmallDevice(context, 50, 15),
                      backgroundColor: CupertinoColors.white,
                      useMagnifier: true,
                      children: List<Widget>.generate(101, (int i) {
                        return Text((prev100Year + i).toString() ?? "No Year",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 20.0));
                      }),
                      scrollController: new FixedExtentScrollController(
                        initialItem: 95,
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          this.pickedYear = (prev100Year + index).toString();
                        });
                      },
                    ),
                  ),
                ),
                material: (_, __) => Center(
                  child: SizedBox(
                    height: 200,
                    width: 300,
                    child: YearPicker(
                      firstDate:
                          DateTime.parse(prev100Year.toString() + "-01-01"),
                      lastDate: DateTime.parse(
                          (prev100Year + 101).toString() + "-01-01"),
                      selectedDate: this.pickedDate,
                      onChanged: (newDate) {
                        setState(() {
                          this.pickedDate = newDate;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                          padding: EdgeInsetsDirectional.only(bottom: 20),
                          child: SizedBox(
                              height: 60,
                              width: 220,
                              child: PlatformButton(
                                color: AppColors.blueColor,
                                disabledColor: AppColors.disabledBlueColor,
                                onPressed: () {
                                  this._setSpiritualYear();
                                },
                                child: Text(
                                  "Continue",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.0),
                                ),
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
                              )))))
            ],
          ),
        ),
      ),
    );
  }
}
