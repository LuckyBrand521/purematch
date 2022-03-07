import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';

class MembershipFeedback extends StatefulWidget {
  const MembershipFeedback({Key key}) : super(key: key);
  @override
  _MembershipFeedbackState createState() => _MembershipFeedbackState();
}

class _MembershipFeedbackState extends State<MembershipFeedback> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String name;
  String imageUrl;

  void _sendData() async {
    final data = {
      "reasons_selected": this.selectedOptions,
      "custom_reason": this.reasonText,
    };

    try {
      var res = await MyHttp.post("/shop/cancel/subscription", data);

      if (res.statusCode == 201 || res.statusCode == 200) {
        //Analytics tracking code
        Global.isPremium = false;
        analytics.logEvent(
            name: "cancelled_subscription",
            parameters: <String, dynamic>{'reason': this.selectedOptions[0]});
        amplitudeAnalytics.logEvent("cancelled_subscription",
            eventProperties: {'reason': this.selectedOptions[0]});
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => ManageSubscription()));
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        print("${res.statusCode}");
      }
    } catch (e) {}
  }

  var communityProfileOptions = [
    "Fake/Inappropriate picture(s)",
    "Harassment or threats",
    "Spam",
    "Others"
  ];

  var selectedOptions = [];
  String reasonText = "";

  void _selectOptions(String option) {
    if (this.selectedOptions.contains(option)) {
      this.selectedOptions.remove(option);
    } else {
      this.selectedOptions.add(option);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //Analytics code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "membership_feedback",
        screenClassOverride: "membership_feedback");
    amplitudeAnalytics.logEvent("membership_feedback_page");
  }

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    double mediaHeight = MediaQuery.of(context).size.height;
    var optionBtns;

    optionBtns = communityProfileOptions
        .asMap()
        .map((i, o) =>
            MapEntry(i, _getOption(o, i, this.selectedOptions.contains(o))))
        .values
        .toList();

    var borderSideProperty = BorderSide(color: Colors.white, width: 1);
    return PlatformScaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          color: AppColors.blueColor,
          height: mediaHeight,
          width: mediaWidth,
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                Text(
                  "We're sorry to \nsee you go!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Please help us improve out service\nby telling us why are you cancelling\nyour subscription:",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Select all that apply:",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Column(
                  children: optionBtns,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    width: double.infinity,
                    child: Text(
                      "Add any addition comments:",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    )),
                SizedBox(
                  height: 5,
                ),
                Container(
                  color: Colors.white,
                  child: PlatformTextField(
                    maxLines: 10,
                    onChanged: (a) {
                      this.reasonText = a.trim();
                    },
                    material: (_, __) => MaterialTextFieldData(
                      decoration: InputDecoration(
                        hintText: "Enter Text...",
                        hintStyle: TextStyle(fontSize: 14),
                        contentPadding: const EdgeInsets.all(8.0),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: borderSideProperty),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: borderSideProperty),
                      ),
                    ),
                    cupertino: (_, __) => CupertinoTextFieldData(
                      placeholder: "Enter Text...",
                      placeholderStyle: TextStyle(fontSize: 14),
                      keyboardAppearance: Brightness.light,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border(
                            left: borderSideProperty,
                            right: borderSideProperty,
                            top: borderSideProperty,
                            bottom: borderSideProperty),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: PlatformButton(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    color: Colors.white,
                    onPressed: () {
                      _sendData();
                    },
                    materialFlat: (_, __) => MaterialFlatButtonData(
                      child: Text(
                        "Back to Pure Match",
                        style: TextStyle(
                            fontSize: 20,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    cupertino: (_, __) => CupertinoButtonData(
                      child: Text(
                        "Back to Pure Match",
                        style: TextStyle(
                            fontSize: 20,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _getOption(String text, int i, bool selected) {
    return Column(
      children: <Widget>[
        Container(
          height: 60,
          width: double.infinity,
          child: FlatButton(
            color: (selected) ? Colors.white : AppColors.blueColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
            onPressed: () {
              this._selectOptions(text);
//              _sendData();
            },
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: (selected) ? AppColors.blueColor : Colors.white,
                  fontSize: 20),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }
}
