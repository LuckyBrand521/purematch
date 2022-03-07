import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:amplitude_flutter/amplitude.dart';

class EditInterests extends StatefulWidget {
  final List<dynamic> interests;
  EditInterests(this.interests);

  @override
  _EditInterestsState createState() => _EditInterestsState();
}

class _EditInterestsState extends State<EditInterests> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  List<String> interests;
  List<String> selectedInterests;
  String error = "";
  int visibility = 0;

  @override
  void initState() {
    // TODO: get the real interests
    this.interests = widget.interests.cast<String>();
    this.selectedInterests = widget.interests.cast<String>();
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_interest", screenClassOverride: "edit_interest");
    amplitudeAnalytics.logEvent("edit_interest_page");
  }

  void _setInterests() async {
    var res = await MyHttp.put("users", {
      "interests": this.selectedInterests,
      "interests_visibilty": this.visibility
    });
    if (res.statusCode == 200) {
      // analytics tracking code
      analytics.logEvent(name: "edited_profile", parameters: <String, dynamic>{
        'first_interest': selectedInterests[0],
        'second_interest': selectedInterests[1],
        'third_interest': selectedInterests[2]
      });

      amplitudeAnalytics.logEvent("edited_profile", eventProperties: {
        'first_interest': selectedInterests[0],
        'second_interest': selectedInterests[1],
        'third_interest': selectedInterests[2]
      });

      print("User updated");
      print(res.body);
      Navigator.pop(context, {"interests": this.selectedInterests});
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
    List<Widget> renderInterests = [];
    for (int j = 0; j < interests.length; j++) {
      renderInterests.add(this._getButton(interests[j], () {
        bool isSelected = this.selectedInterests.contains(interests[j]);
        if (isSelected == false) {
          this.selectedInterests.add(interests[j]);
        } else {
          this.selectedInterests.remove(interests[j]);
        }
        setState(() {});
      }, this.selectedInterests.contains(interests[j])));
    }

    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                RoundIndicators(
                  currentIndicatorIndex: 2,
                  numberOfInidcators: 5,
                  circleSize: 12,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Select at least 3 Interests",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Scroll to see more choices!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: width * 0.9,
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.blueColor, width: 2.1)),
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        children: renderInterests,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 70),
                  child: FlatButton(
                      onPressed: (this.selectedInterests.length >= 3)
                          ? () {
                              this._setInterests();
                            }
                          : null,
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 55),
                      color: AppColors.blueColor,
                      disabledColor: AppColors.disabledBlueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Continue",
                        style: TextStyle(color: Colors.white),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  FlatButton _getButton(String text, Function f, bool fill) {
    return FlatButton(
        onPressed: f,
        color: fill ? AppColors.blueColor : Colors.white,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: AppColors.blueColor, width: 2)),
        child: Text(
          text,
          style: TextStyle(color: fill ? Colors.white : AppColors.blueColor),
        ));
  }
}
