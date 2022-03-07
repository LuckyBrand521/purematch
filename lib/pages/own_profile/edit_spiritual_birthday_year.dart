import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/own_profile/edit_profile_details_app_bar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:sailor/sailor.dart';
import '../../routes.dart';
import '../AppColors.dart';
import '../MyHttp.dart';
import 'dart:io' show Platform;

class EditSpiritualBirthdayYear extends StatefulWidget {
  final String spiritualYear;

  EditSpiritualBirthdayYear(this.spiritualYear);

  @override
  EditSpiritualBirthdayYearState createState() =>
      EditSpiritualBirthdayYearState();
}

class EditSpiritualBirthdayYearState extends State<EditSpiritualBirthdayYear> {
  String pickedYear;
  String pickedYear1;
  DateTime pickedDate;
  String error = "";

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  void initState() {
    pickedYear = (int.parse(widget.spiritualYear)).toString();
    pickedYear1 = pickedYear;
    pickedDate = DateTime.parse(pickedYear + "-01-01");
    super.initState();

    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "spiritual_birthday_year",
        screenClassOverride: "spiritual_birthday_year");
    amplitudeAnalytics.logEvent("spiritual_birthday_year_page");
  }

  bool isChangedValues() {
    var isChanged = false;
    (pickedYear1 != pickedYear) ? isChanged = true : isChanged = false;
    return isChanged;
  }

  Future<void> _setSpiritualYear() async {
    String spiritualBirthday = Platform.isIOS
        ? DateTime.parse(this.pickedYear + "-01-01").toIso8601String()
        : this.pickedDate.toIso8601String();
    print(spiritualBirthday);
    // TODO: To check with algorithm developer whether the year only data is separately required. Options -> change my_spiritual_birthday to a String - "pickedYear-XX-XX 00:00:00.000" or create a new input for "spiritual_year" = 2020
    var res = await MyHttp.put(
        "users/update", {"my_spiritual_birthday": spiritualBirthday});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(name: "edited_profile", parameters: <String, dynamic>{
        'spiritual_birthday_year': this.pickedYear.toString()
      });
      amplitudeAnalytics.logEvent("edited_profile", eventProperties: {
        'spiritual_birthday_year': this.pickedYear.toString()
      });

      print("User updated");
      print(res.body);

      Routes.sailor.navigate("/homes",
          params: {'tabIndex': 4},
          navigationType: NavigationType.pushAndRemoveUntil,
          removeUntilPredicate: (Route<dynamic> route) => false);
    } else {
      Global.ownProfileSaved = true;
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
    double pageSize = MediaQuery.of(context).size.height;
    double notifySize = MediaQuery.of(context).padding.top;
    double appBarSize = Platform.isIOS
        ? CupertinoNavigationBar().preferredSize.height
        : AppBar().preferredSize.height;
    int prev100Year = DateTime.now().year - 100;
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
                        height: 20,
                      ),
                      Text("No problem! Just select the year:",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: AppConfig.heightWithDForSmallDevice(
                                context, 28, 8),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      PlatformWidget(
                        cupertino: (_, __) => Center(
                          child: SizedBox(
                            height: 200,
                            width: 300,
                            child: CupertinoPicker(
                              itemExtent: AppConfig.heightWithDForSmallDevice(
                                  context, 50, 20),
                              backgroundColor: CupertinoColors.white,
                              useMagnifier: true,
                              children: List<Widget>.generate(101, (int i) {
                                return Text(
                                    (prev100Year + i).toString() ?? "No Year",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.blackColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20.0));
                              }),
                              scrollController: new FixedExtentScrollController(
                                initialItem:
                                    int.parse(pickedYear) - prev100Year,
                              ),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  this.pickedYear =
                                      (prev100Year + index).toString();
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
                              firstDate: DateTime.parse(
                                  prev100Year.toString() + "-01-01"),
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
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Text(
                          this.error,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.redColor),
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Center(
                        child: SizedBox(
                          height: 60,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: PlatformButton(
                                onPressed: () {
                                  this._setSpiritualYear();
                                },
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
