// this is also called edit dating preference

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplitude_flutter/amplitude.dart';

class EditMatchSettings extends StatefulWidget {
  @override
  _EditMatchSettingsState createState() => _EditMatchSettingsState();
}

class _EditMatchSettingsState extends State<EditMatchSettings> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  var heightTextEditing1 = MaskedTextController(mask: "0'00\"");
  var heightTextEditing2 = MaskedTextController(mask: "0'00\"");

  String height1 = "";
  String height2 = "";

  TextEditingController _height1TxtEditCtrl = TextEditingController();
  TextEditingController _height2TxtEditCtrl = TextEditingController();

  String age1 = "";
  String age2 = "";

  TextEditingController _age1TxtEditCtrl = TextEditingController();
  TextEditingController _age2TxtEditCtrl = TextEditingController();

  List<String> selectedBuild = [];
  List<String> selectedEthnicity = [];

  List<String> selectedCurrentKids = [];
  List<String> selectedWantKids = [];
  List<String> selectedEducation = [];

  String error = "";

  bool loading = false;

  void _getDatingPreference() async {
    var sp = await SharedPreferences.getInstance();
    int id = sp.getInt("id");
    var res = await MyHttp.get("users/user/$id");
    print("Getting user preferesces");
    print("Res Code: ${res.statusCode}");
    if (res.statusCode == 200) {
      var data = res.body;
      var preferences = json.decode(data);
      preferences = preferences["user"]["preferences"];
      print(preferences);
      setState(() {
        this.selectedEducation = preferences["education"].cast<String>();
        this.height1 = preferences["from_height"].toString();
        this.height2 = preferences["to_height"].toString();
        this.age1 = preferences["from_age"].toString();
        this.age2 = preferences["to_age"].toString();
        this.selectedEthnicity = preferences["ethnicity"].cast<String>();
        this.selectedBuild = preferences["build"].cast<String>();
        this.selectedWantKids = preferences["kids_want"].cast<String>();
        this.selectedCurrentKids = preferences["kids_have"].cast<String>();
      });
      this._height1TxtEditCtrl.text = preferences["from_height"].toString();
      this._height2TxtEditCtrl.text = preferences["to_height"].toString();
      this._age1TxtEditCtrl.text = preferences["from_age"].toString();
      this._age2TxtEditCtrl.text = preferences["to_age"].toString();
    }
  }

  @override
  void initState() {
    super.initState();
    this._getDatingPreference();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_match_settings",
        screenClassOverride: "edit_match_settings");
    amplitudeAnalytics.logEvent("edit_match_settings_page");
  }

  double getPadding(String ethnicity) {
    switch (ethnicity) {
      case "Indigenous/Native\nAmerican":
        return 13;
        break;
      case "East/\nSoutheast\nAsian":
        return 13;
        break;
      case "Hispanic/Latinx":
        return 20;
        break;
      case "Pacific\nIslander":
        return 20;
        break;
      case "Mixed Race":
        return 28;
        break;
      case "Black/African\ndescent":
        return 20;
        break;
      case "South Asian":
        return 28;
        break;
      case "Middle Eastern":
        return 20;
        break;
      case "White":
        return 28;
        break;
      case "Other":
        return 28;
        break;
      default:
        return 20;
    }
  }

  void _sendDatingPreference() async {
    setState(() {
      loading = true;
    });
    double dHeight1 = double.tryParse(this.height1);
    if (dHeight1 == null) {
      setState(() {
        error = "Height should be number";
      });
      return;
    }

    double dHeight2 = double.tryParse(this.height2);
    if (dHeight2 == null) {
      setState(() {
        error = "Height should be number";
      });
      return;
    }
    int iAge1 = int.tryParse(this.age1);
    if (iAge1 == null) {
      setState(() {
        error = "Age should be number";
      });
      return;
    }
    int iAge2 = int.tryParse(this.age2);
    if (iAge2 == null) {
      setState(() {
        error = "Age should be number";
      });
      return;
    }

    // getting the token
    var sp = await SharedPreferences.getInstance();
    int id = sp.getInt("id");
    print("ID:$id");
    var ethnicityIds = [];

    this.selectedEthnicity.forEach((element) {
      if (element == "Indigenous/Native American") {
        ethnicityIds.add(1);
      } else if (element == "East/Southeast Asian") {
        ethnicityIds.add(3);
      } else if (element == "Hispanic/Latinx") {
        ethnicityIds.add(5);
      } else if (element == "Pacific Islander") {
        ethnicityIds.add(7);
      } else if (element == "Mixed Race") {
        ethnicityIds.add(9);
      } else if (element == "Black/African descent") {
        ethnicityIds.add(2);
      } else if (element == "South Asian") {
        ethnicityIds.add(4);
      } else if (element == "Middle Eastern") {
        ethnicityIds.add(6);
      } else if (element == "White") {
        ethnicityIds.add(8);
      } else if (element == "Other") {
        ethnicityIds.add(10);
      }
    });
    var res = await MyHttp.post("users/dating_preferences", {
      "education": this.selectedEducation,
      "from_height": dHeight1,
      "to_height": dHeight2,
      "from_age": iAge1,
      "to_age": iAge2,
      "build": this.selectedBuild,
      "ethnicity": ethnicityIds,
      "kids_have": this.selectedCurrentKids,
      "kids_want": this.selectedWantKids
    });
    print(res.request.url);
    if (res.statusCode == 200) {
      print("User updated");
      print(res.body);
      Navigator.of(context).pop();

      // analytics tracking code
      analytics.logEvent(name: "edited_profile", parameters: <String, dynamic>{
        "user_id": id,
        "education": this.selectedEducation.first,
        "build": this.selectedBuild.first,
        "ethnicity": this.selectedEthnicity.first,
        "current_kids": this.selectedCurrentKids.first,
        "want_kids": this.selectedWantKids.first,
        "height1": this.height1,
        "height2": this.height2
      });

      amplitudeAnalytics.logEvent("edited_profile", eventProperties: {
        "user_id": id,
        "education": this.selectedEducation.first,
        "build": this.selectedBuild.first,
        "ethnicity": this.selectedEthnicity.first,
        "current_kids": this.selectedCurrentKids.first,
        "want_kids": this.selectedWantKids.first,
        "height1": this.height1,
        "height2": this.height2
      });
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        var body = json.decode(res.body);
        error = body["message"] ?? "error";
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.of(context).pop()),
                    SizedBox(
                      width: 20,
                    ),
                    Text("What are your\ndating preferences?",
                        style: TextStyle(
                            fontSize:
                                AppConfig.fontsizeForSmallDevice(context, 25))),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Height",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: width * 0.6,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _height1TxtEditCtrl,
                          maxLength: 5,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              fontSize: 22, color: AppColors.blueColor),
                          onChanged: (String height) {
                            setState(() {
                              this.height1 = height;
                            });
                            Future.delayed(const Duration(milliseconds: 10),
                                () {
                              heightTextEditing1.moveCursorToEnd();
                            });
                          },
                          decoration: InputDecoration(
                              counterText: "",
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.blueColor, width: 2)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.blueColor, width: 2))),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "to",
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _height2TxtEditCtrl,
                          maxLength: 5,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              fontSize: 22, color: AppColors.blueColor),
                          onChanged: (String height) {
                            setState(() {
                              this.height2 = height;
                            });

                            Future.delayed(const Duration(milliseconds: 10),
                                () {
                              heightTextEditing2.moveCursorToEnd();
                            });
                          },
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.blueColor, width: 2)),
                              counterText: "",
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.blueColor, width: 2))),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Age",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: width * 0.6,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _age1TxtEditCtrl,
                          maxLength: 2,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              fontSize: 22, color: AppColors.blueColor),
                          onChanged: (String age) {
                            setState(() {
                              this.age1 = age;
                            });
                          },
                          decoration: InputDecoration(
                              counterText: "",
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.blueColor, width: 2)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.blueColor, width: 2))),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "to",
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _age2TxtEditCtrl,
                          maxLength: 2,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              fontSize: 22, color: AppColors.blueColor),
                          onChanged: (String age) {
                            setState(() {
                              this.age2 = age;
                            });
                          },
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.blueColor, width: 2)),
                              counterText: "",
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.blueColor, width: 2))),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Build",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
                ),
                SizedBox(
                  height: 20,
                ),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 15,
                  runSpacing: 10,
                  children: <String>[
                    "Skinny",
                    "Athletic",
                    "Average",
                    "Plus Size"
                  ].map((String b) {
                    return MyButtons.getBorderedButton(b, AppColors.blueColor,
                        () {
                      setState(() {
                        if (this.selectedBuild.contains(b))
                          this.selectedBuild.remove(b);
                        else
                          this.selectedBuild.add(b);
                      });
                    }, this.selectedBuild.contains(b),
                        buttonWidth: 75,
                        fontSize: 11,
                        fontWeight: FontWeight.normal);
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Ethnicity",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
                ),
                SizedBox(
                  height: 20,
                ),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 15,
                  runSpacing: 10,
                  children: <String>[
                    "Indigenous/Native\nAmerican",
                    "East/\nSoutheast\nAsian",
                    "Hispanic/Latinx",
                    "Pacific\nIslander",
                    "Mixed Race",
                    "Black/African\ndescent",
                    "South Asian",
                    "Middle Eastern",
                    "White",
                    "Other"
                  ].map((String b) {
                    String a = b.replaceAll('\n', " ");
                    if (a == "East/ Southeast Asian") {
                      a = "East/Southeast Asian";
                    }
                    return MyButtons.getBorderedButton(b, AppColors.blueColor,
                        () {
                      setState(() {
                        if (this.selectedEthnicity.contains(a))
                          this.selectedEthnicity.remove(a);
                        else
                          this.selectedEthnicity.add(a);
                      });
                    }, this.selectedEthnicity.contains(a),
                        buttonWidth: 75,
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                        verticalPadding: getPadding(b));
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Kids",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
                ),
                SizedBox(
                  height: 20,
                ),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 15,
                  runSpacing: 10,
                  children: <String>[
                    "No \nkids",
                    "Kids at \nhome",
                    "Kids away \nfrom home"
                  ].map((String b) {
                    var b1 = b.replaceAll("\n", "");
                    return MyButtons.getBorderedButton(b, AppColors.blueColor,
                        () {
                      setState(() {
                        if (this.selectedCurrentKids.contains(b1))
                          this.selectedCurrentKids.remove(b1);
                        else
                          this.selectedCurrentKids.add(b1);
                      });
                    }, this.selectedCurrentKids.contains(b1),
                        buttonWidth: 75,
                        fontSize: 11,
                        fontWeight: FontWeight.normal);
                  }).toList(),
                ),
                SizedBox(
                  height: 10,
                ),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 15,
                  runSpacing: 10,
                  children: <String>[
                    "Doesn’t \nwant kids",
                    "Wants \nkids",
                    "Open to \nkids"
                  ].map((String b) {
                    var b1 = b.replaceAll("\n", "");
                    return MyButtons.getBorderedButton(b, AppColors.blueColor,
                        () {
                      setState(() {
                        if (this.selectedWantKids.contains(b1))
                          this.selectedWantKids.remove(b1);
                        else
                          this.selectedWantKids.add(b1);
                      });
                    }, this.selectedWantKids.contains(b1),
                        buttonWidth: 75,
                        fontSize: 11,
                        fontWeight: FontWeight.normal);
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Education",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
                ),
                SizedBox(
                  height: 20,
                ),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 15,
                  runSpacing: 10,
                  children: <String>[
                    "High School",
                    "Associate",
                    "Bachelor",
                    "Graduate",
                    "Doctorate"
                  ].map((String b) {
                    return MyButtons.getBorderedButton(b, AppColors.blueColor,
                        () {
                      setState(() {
                        if (this.selectedEducation.contains(b))
                          this.selectedEducation.remove(b);
                        else
                          this.selectedEducation.add(b);
                      });
                    }, this.selectedEducation.contains(b),
                        buttonWidth: 75,
                        fontSize: 11,
                        fontWeight: FontWeight.normal);
                  }).toList(),
                ),
                SizedBox(
                  height: 40,
                ),
                Center(
                  child: (loading)
                      ? PlatformCircularProgressIndicator(
                          material: (_, __) => MaterialProgressIndicatorData(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.blueColor),
                          ),
                        )
                      : FlatButton(
                          onPressed: (this.age1.trim().isNotEmpty &&
                                  this.age2.trim().isNotEmpty &&
                                  this.height1.trim().isNotEmpty &&
                                  this.height2.trim().isNotEmpty &&
                                  this.selectedBuild.isNotEmpty &&
                                  this.selectedEthnicity.isNotEmpty &&
                                  this.selectedCurrentKids.isNotEmpty &&
                                  this.selectedWantKids.isNotEmpty &&
                                  this.selectedEducation.isNotEmpty)
                              ? () {
                                  this._sendDatingPreference();
                                  // Analytics tracking code
                                  analytics.logEvent(
                                      name: "edited_profile",
                                      parameters: <String, dynamic>{
                                        'match_setting_min_age':
                                            this.age1.trim(),
                                        'match_setting_max_age':
                                            this.age2.trim(),
                                        'match_setting_min_height':
                                            this.height1.trim(),
                                        'match_setting_max_height':
                                            this.height2.trim(),
                                        'match_setting_build':
                                            this.selectedBuild,
                                        'match_setting_ethnicity':
                                            this.selectedEthnicity,
                                        'match_setting_current_kids':
                                            this.selectedCurrentKids,
                                        'match_setting_want_kids':
                                            this.selectedWantKids,
                                        'match_setting_education':
                                            this.selectedEducation
                                      });

                                  amplitudeAnalytics.logEvent("edited_profile",
                                      eventProperties: {
                                        'match_setting_min_age':
                                            this.age1.trim(),
                                        'match_setting_max_age':
                                            this.age2.trim(),
                                        'match_setting_min_height':
                                            this.height1.trim(),
                                        'match_setting_max_height':
                                            this.height2.trim(),
                                        'match_setting_build':
                                            this.selectedBuild,
                                        'match_setting_ethnicity':
                                            this.selectedEthnicity,
                                        'match_setting_current_kids':
                                            this.selectedCurrentKids,
                                        'match_setting_want_kids':
                                            this.selectedWantKids,
                                        'match_setting_education':
                                            this.selectedEducation
                                      });
                                }
                              : null,
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 55),
                          color: AppColors.blueColor,
                          disabledColor: AppColors.blueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Update",
                            style: TextStyle(color: Colors.white),
                          )),
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
