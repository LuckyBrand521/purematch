import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/myfirebase.dart';
import 'package:pure_match/common/show_message.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/profile_info/awsome_done.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:pure_match/extensions/list_extension.dart';
import 'package:pure_match/pages/rewards/plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'enableNotification.dart';

enum UserDatingPreferencesPageType { ONBOARDING, SETTINGS }

class UserDatingPreference extends StatefulWidget {
  final UserDatingPreferencesPageType userDatingPreferencesPageType;
  final Function() onSaveContinue;
  const UserDatingPreference(
      {Key key, this.userDatingPreferencesPageType, this.onSaveContinue})
      : super(key: key);
  @override
  _UserDatingPreferenceState createState() => _UserDatingPreferenceState();
}

class _UserDatingPreferenceState extends State<UserDatingPreference> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  TextStyle placeHolderStyle =
      TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Colors.grey);

  String height1, height2;
  String height1_1, height2_1;
  String age1 = "", age2 = "";
  String age1_1 = "", age2_1 = "";
  int maxDistance = 50;
  int maxDistance1 = 50;
  List<String> selectedCurrentKids = [];
  List<String> selectedCurrentKids1 = [];
  List<String> selectedWantKids = [];
  List<String> selectedWantKids1 = [];
  List<String> selectedBuild = [];
  List<String> selectedBuild1 = [];
  List<String> selectedEthnicity = [];
  List<String> selectedEthnicity1 = [];
  List<String> selectedEducation = [];
  List<String> selectedEducation1 = [];
  List<String> selectedPersonality = [];
  List<String> selectedPersonality1 = [];
  int heightIndex1 = 7, heightIndex2 = 15;
  bool _loading = false;
  TextEditingController age1Controller = TextEditingController();
  TextEditingController age2Controller = TextEditingController();
  String error = "", ageError = "", heightError = "", baptismAgeError = "";
  bool heightValidation = true;
  bool ageValidation = false;
  bool baptismAgeValidation = false;
  FixedExtentScrollController height1ScrollController;
  FixedExtentScrollController height2ScrollController;
  FixedExtentScrollController baptism1ScrollController;
  FixedExtentScrollController baptism2ScrollController;
  final Map<String, String> heightMap = {
    "4'5 (135 cm)": "135",
    "4'6 (137 cm)": "137",
    "4'7 (139 cm)": "140",
    "4'8 (142 cm)": "142",
    "4'9 (145 cm)": "145",
    "4'10 (147 cm)": "147",
    "4'11 (150 cm)": "150",
    "5'0 (152 cm)": "152",
    "5'1 (154 cm)": "155",
    "5'2 (157 cm)": "158",
    "5'3 (160 cm)": "160",
    "5'4 (162 cm)": "163",
    "5'5 (165 cm)": "165",
    "5'6 (168 cm)": "168",
    "5'7 (170 cm)": "170",
    "5'8 (173 cm)": "173",
    "5'9 (175 cm)": "175",
    "5'10 (178 cm)": "178",
    "5'11 (180 cm)": "180",
    "6'0 (183 cm)": "183",
    "6'1 (185 cm)": "185",
    "6'2 (188 cm)": "188",
    "6'3 (191 cm)": "191",
    "6'4 (193 cm)": "193",
    "6'5 (196 cm)": "196",
    "6'6 (198 cm)": "198",
    "6'7 (200 cm)": "201",
    "6'8 (203 cm)": "203",
  };
  List<String> heightList = ["4'5 (135 cm)"];
  String dropDownVal1 = "5'0 (152 cm)", dropdownValue2 = "5'8 (173 cm)";
  int dropdownBaptismAgeValue1 = 0, dropdownBaptismAgeValue2 = 99;
  int dropdownBaptismAgeValue1_1 = 0, dropdownBaptismAgeValue2_1 = 99;
  List<int> baptismAgeList = [0];

  @override
  void initState() {
    heightList = this.heightMap.keys.toList();
    baptismAgeList = baptismAgeList + List<int>.generate(100, (i) => i + 1);
    print(heightList);
    height1 = "152";
    height2 = "173";
    this._getDatingPreferences();
    this._getPremiumStatus();
    super.initState();
    if (widget.userDatingPreferencesPageType ==
        UserDatingPreferencesPageType.SETTINGS) {
    } else {
      Global.setOnboardingId(27);
    }

    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);

    analytics.setCurrentScreen(
        screenName: "match_preference",
        screenClassOverride: "dating_preference");
    amplitudeAnalytics.logEvent("match_preference_page");

    height1ScrollController =
        FixedExtentScrollController(initialItem: heightIndex1);
    height2ScrollController =
        FixedExtentScrollController(initialItem: heightIndex2);
    baptism1ScrollController =
        FixedExtentScrollController(initialItem: dropdownBaptismAgeValue1);
    baptism2ScrollController =
        FixedExtentScrollController(initialItem: dropdownBaptismAgeValue2);
  }

  void _succeedPurchase() {
    this._getPremiumStatus();
  }

  void validateHeight() {
    if (this.height1.isNotEmpty &&
        this.height2.isNotEmpty &&
        (int.tryParse(this.height1) > int.tryParse(this.height2))) {
      setState(() {
        this.heightError = "Invalid Height Range";
        this.heightValidation = false;
      });
    } else {
      this.heightError = "";
      this.heightValidation = true;
    }
  }

  void validateAge() {
    int age1No, age2No;
    bool age1RangeValidation, age2RangeValidation = true;
    age1No = int.tryParse(this.age1);
    age2No = int.tryParse(this.age2);

    if (age1No != null && (age1No < 18 || age1No > 100)) {
      setState(() {
        this.ageError = "* Ages must be between 18 and 100";
        this.ageValidation = false;
      });
      age1RangeValidation = false;
    } else {
      age1RangeValidation = true;
    }

    if (age2No != null && (age2No < 18 || age2No > 100)) {
      setState(() {
        this.ageError = "* Ages must be between 18 and 100";
        this.ageValidation = false;
      });
      age2RangeValidation = false;
    } else {
      age2RangeValidation = true;
    }

    if (age1RangeValidation == true &&
        age2RangeValidation == true &&
        age1No != null &&
        age2No != null) {
      if (age1No > age2No) {
        setState(() {
          this.ageError = "* Invalid Age Range";
          this.ageValidation = false;
        });
      } else {
        this.ageError = "";
        this.ageValidation = true;
      }
    }
  }

  void validateBaptismAge() {
    if (this.dropdownBaptismAgeValue1 != null &&
        this.dropdownBaptismAgeValue2 != null) {
      if (this.dropdownBaptismAgeValue1 > this.dropdownBaptismAgeValue2) {
        setState(() {
          this.baptismAgeError = "* Invalid Age Range";
          this.baptismAgeValidation = false;
        });
      } else {
        this.baptismAgeError = "";
        this.baptismAgeValidation = true;
      }
    }
  }

  Map getKey(String height) {
    Map map = Map<String, Object>();
    String returnValue = "";
    List<String> heightInCmList = heightMap.values.toList();
    for (var i = 0; i < heightInCmList.length; i++) {
      String height1 = heightInCmList[i];
      if (height == height1) {
        returnValue = heightList[i];

        map.putIfAbsent("height", () => returnValue);
        map.putIfAbsent("index", () => i);
        break;
      }
    }
    return map;
  }

  void _getDatingPreferences() async {
    try {
      var sp = await SharedPreferences.getInstance();
      int id = sp.getInt("id");
      var res = await MyHttp.get("/users/user/$id");
      if (res.statusCode == 200) {
        var body = jsonDecode(res.body);
        var user = body["user"];
        var preferences = user["preferences"];
        if (preferences != null) {
          var p = Preferences.fromJson(preferences);
          setState(() {
            if (p.education != null) {
              this.selectedEducation = p.education;
              if (this.selectedEducation.length > 0) {
                this.selectedEducation1 = List.from(this.selectedEducation);
              }
            }
            if (p.from_height != null) {
              this.height1 = p.from_height;
              if (this.height1 != null) {
                this.height1_1 = this.height1;
                var map = getKey(this.height1);
                if (map != null) {
                  if (map.containsKey("height")) {
                    this.dropDownVal1 = map["height"];
                  }
                  if (map.containsKey("index")) {
                    this.heightIndex1 = map["index"];
                  }
                }
              }
            }

            if (p.to_height != null) {
              this.height2 = p.to_height;
              if (this.height2 != null) {
                this.height2_1 = this.height2;
                var map = getKey(this.height2);
                if (map != null) {
                  if (map.containsKey("height")) {
                    this.dropdownValue2 = map["height"];
                  }
                  if (map.containsKey("index")) {
                    this.heightIndex2 = map["index"];
                  }
                }
              }
            }

            if (p.from_age != null) {
              this.age1 = p.from_age.toString();
              if (this.age1 != "null") {
                this.age1_1 = this.age1;
                this.age1Controller.text = this.age1;
              }
            }
            if (p.to_age != null) {
              this.age2 = p.to_age.toString();
              if (this.age2 != "null") {
                this.age2_1 = this.age2;
                this.age2Controller.text = this.age2;
              }
            }

            if (p.baptism_from_year != null) {
              String baptism_from_year = p.baptism_from_year.toString();
              if (baptism_from_year != "null") {
                this.dropdownBaptismAgeValue1 = int.parse(baptism_from_year);
                this.dropdownBaptismAgeValue1_1 = this.dropdownBaptismAgeValue1;
              }
            }
            if (p.baptism_to_year != null) {
              String baptism_to_year = p.baptism_to_year.toString();
              if (baptism_to_year != "null") {
                this.dropdownBaptismAgeValue2 = int.parse(baptism_to_year);
                this.dropdownBaptismAgeValue2_1 = this.dropdownBaptismAgeValue2;
              }
            }

            if (p.maxDistance != null) {
              String max_distance = p.maxDistance.toString();
              if (max_distance != "null") {
                this.maxDistance = int.parse(max_distance);
                this.maxDistance1 = this.maxDistance;
              }
            }

            if (p.personality_type != null) {
              this.selectedPersonality = p.personality_type;
              if (this.selectedPersonality.length > 0) {
                this.selectedPersonality1 = List.from(this.selectedPersonality);
              }
            }
            if (p.build != null) {
              this.selectedBuild = p.build;
              if (this.selectedBuild.length > 0) {
                this.selectedBuild1 = List.from(this.selectedBuild);
              }
            }
            if (p.ethnicity != null) {
              this.selectedEthnicity = p.ethnicity;
              if (this.selectedEthnicity.length > 0) {
                this.selectedEthnicity1 = List.from(this.selectedEthnicity);
              }
            }

            if (p.kids_have != null) {
              this.selectedCurrentKids = p.kids_have;
              if (this.selectedCurrentKids.length > 0) {
                this.selectedCurrentKids1 = List.from(this.selectedCurrentKids);
              }
            }
            if (p.kids_want != null) {
              this.selectedWantKids = p.kids_want;
              if (this.selectedWantKids.length > 0) {
                this.selectedWantKids1 = List.from(this.selectedWantKids);
              }
            }

            validateHeight();
            validateAge();
            validateBaptismAge();
            height1ScrollController.jumpToItem(heightIndex1);
            height2ScrollController.jumpToItem(heightIndex2);
            baptism1ScrollController.jumpToItem(dropdownBaptismAgeValue1);
            baptism2ScrollController.jumpToItem(dropdownBaptismAgeValue2);
          });
          print("_getDatingPreferences ${p.kids_have}");
        }
      }
    } catch (e) {
      print("_getDatingPreferences error $e");
    }
  }

  //This function check if User is Premium and then if Ethnicity, Build and Education must ben selected
  bool checkFields() {
    if ((selectedEthnicity.length == 0) && (Global.isPremium)) {
      showMessage(
          context: context,
          title: 'Confirm',
          content: 'Please select Ethnicity');
      return false;
    } else if ((selectedBuild.length == 0) && (Global.isPremium)) {
      showMessage(
          context: context, title: 'Confirm', content: 'Please select Build');
      return false;
    } else if ((selectedEducation.length == 0) && (Global.isPremium)) {
      showMessage(
          context: context,
          title: 'Confirm',
          content: 'Please select Education');
      return false;
    }
    return true;
  }

  // TODO: To send location, baptism age preferences
  void _sendDatingPreference(BuildContext context) async {
    if (!checkFields()) return;

    setState(() {
      _loading = true;
    });

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
    Map map = Map<String, Object>();
    if (this.selectedEducation != null && this.selectedEducation.length != 0) {
      map.putIfAbsent("education", () => this.selectedEducation);
    }

    if (this.height1 != null) {
      map.putIfAbsent("from_height", () => int.tryParse(this.height1));
    }

    if (this.height2 != null) {
      map.putIfAbsent("to_height", () => int.tryParse(this.height2));
    }

    if (this.age1 != "null" && this.age1 != "") {
      map.putIfAbsent("from_age", () => this.age1);
    }

    if (this.age2 != "null" && this.age2 != "") {
      map.putIfAbsent("to_age", () => this.age2);
    }

    if (this.selectedBuild != null && this.selectedBuild.length != 0) {
      map.putIfAbsent("build", () => this.selectedBuild);
    }

    if (ethnicityIds != null && ethnicityIds.length != 0) {
      map.putIfAbsent("ethnicity", () => ethnicityIds);
    }

    var kidsHave = [];
    if (this.selectedCurrentKids.contains("No kids")) {
      kidsHave.add("No kids");
    }
    if (this.selectedCurrentKids.contains("Kids at home")) {
      kidsHave.add("Kids at home");
    }
    if (this.selectedCurrentKids.contains("Kids away from home")) {
      kidsHave.add("Kids away from home");
    }
    map.putIfAbsent("kids_have", () => kidsHave);

    var kidsWant = [];
    if (this.selectedWantKids.contains("Doesn't want kids")) {
      kidsWant.add("Doesn't want kids");
    }
    if (this.selectedWantKids.contains("Wants kids")) {
      kidsWant.add("Wants kids");
    }
    if (this.selectedWantKids.contains("Open to kids")) {
      kidsWant.add("Open to kids");
    }
    map.putIfAbsent("kids_want", () => kidsWant);

    map.putIfAbsent("max_distance", () => this.maxDistance);
    if (Global.isPremium) {
      var baptism_from_year = this.dropdownBaptismAgeValue1.toString();
      map.putIfAbsent("baptism_from_year", () => baptism_from_year);

      var baptism_to_year = this.dropdownBaptismAgeValue2.toString();
      map.putIfAbsent("baptism_to_year", () => baptism_to_year);

      if (this.selectedPersonality != null) {
        map.putIfAbsent(
            "personality_type", () => this.selectedPersonality.trimNextLines());
      }
    }

    var res = await MyHttp.post("users/dating_preferences", map);
    print(res.request.url);
    if (res.statusCode == 200) {
      print("User updated");
      print(res.body);

      // analytics tracking code
      var jsonData = jsonDecode(res.body);
      analytics.logEvent(
          name: "saved_match_preference",
          parameters: <String, dynamic>{
            "user_id": jsonData["user"]['id'].toString(),
            "education": this.selectedEducation.isEmpty == true
                ? "None"
                : this.selectedEducation.first,
            "build": this.selectedBuild.isEmpty == true
                ? "None"
                : this.selectedBuild.first,
            "ethnicity": this.selectedEthnicity.isEmpty == true
                ? "None"
                : this.selectedEthnicity.first,
            "current_kids": this.selectedCurrentKids.isEmpty == true
                ? ""
                : this.selectedCurrentKids.first,
            "want_kids": this.selectedWantKids.isEmpty == true
                ? "None"
                : this.selectedWantKids.first,
            "height1": this.height1,
            "height2": this.height2
          });

      amplitudeAnalytics.logEvent("saved_match_preference", eventProperties: {
        "user_id": jsonData["user"]['id'].toString(),
        "education": this.selectedEducation.isEmpty == true
            ? "Nonloe"
            : this.selectedEducation.first,
        "build": this.selectedBuild.isEmpty == true
            ? "None"
            : this.selectedBuild.first,
        "ethnicity": this.selectedEthnicity.isEmpty == true
            ? "None"
            : this.selectedEthnicity.first,
        "current_kids": this.selectedCurrentKids.isEmpty == true
            ? ""
            : this.selectedCurrentKids.first,
        "want_kids": this.selectedWantKids.isEmpty == true
            ? "None"
            : this.selectedWantKids.first,
        "height1": this.height1,
        "height2": this.height2
      });

      setState(() {
        _loading = false;
      });

      if (widget.userDatingPreferencesPageType ==
          UserDatingPreferencesPageType.SETTINGS) {
        Navigator.pop(context);
        widget.onSaveContinue();
      } else {
        //Analytics tracking code
        analytics.setCurrentScreen(
            screenName: "awesome_done", screenClassOverride: "awesome_done");
        amplitudeAnalytics.logEvent("awesome_done_page");
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AwesomeDone()));
      }
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        _loading = false;
        error = res.statusCode.toString() + "\n" + res.body;
      });
    }
  }

  Text _selectAllText() {
    return Text("(Select all that apply)",
        style: TextStyle(color: Colors.black38, fontSize: 14));
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

  void _getPremiumStatus() async {
    try {
      var res2 = await MyHttp.get("/settings/member-status");
      var json2 = jsonDecode(res2.body);
      bool status = json2["success"];
      print("Premium status $status");
      if (status == true) Global.isPremium = true;
      if (this.mounted) {
        setState(() {});
      }
    } catch (e) {
      print("user_dating_preferences.dart _getPremiumStatus $e");
    }
  }

  void _goBack() {
    if (widget.userDatingPreferencesPageType == UserDatingPreferencesPageType.SETTINGS) {
      if (this.heightValidation == true 
        && this.ageValidation == true 
        || this.selectedCurrentKids.isNotEmpty 
        || this.selectedWantKids.isNotEmpty) {
          this._sendDatingPreference(context);          
        }
    } else {
      Navigator.pop(context);
    }
  }

  bool checkIfChanges() {
    var isChanged = false;
    isChanged =
        Global.isChangedListValues(selectedEthnicity, selectedEthnicity1);
    if (isChanged) {
      return isChanged;
    }
    isChanged =
        Global.isChangedListValues(selectedEducation, selectedEducation1);
    if (isChanged) {
      return isChanged;
    }
    isChanged = Global.isChangedListValues(selectedBuild, selectedBuild1);
    if (isChanged) {
      return isChanged;
    }
    isChanged =
        Global.isChangedListValues(selectedCurrentKids, selectedCurrentKids1);
    if (isChanged) {
      return isChanged;
    }
    isChanged = Global.isChangedListValues(selectedWantKids, selectedWantKids1);
    if (isChanged) {
      return isChanged;
    }
    isChanged =
        Global.isChangedListValues(selectedPersonality, selectedPersonality1);
    if (isChanged) {
      return isChanged;
    }
    if (this.height1 != this.height1_1) {
      isChanged = true;
      return isChanged;
    }
    if (this.height2 != this.height2_1) {
      isChanged = true;
      return isChanged;
    }
    if (this.age1 != this.age1_1) {
      isChanged = true;
      return isChanged;
    }
    if (this.age2 != this.age2_1) {
      isChanged = true;
      return isChanged;
    }
    if (this.maxDistance != this.maxDistance1) {
      isChanged = true;
      return isChanged;
    }
    if (this.dropdownBaptismAgeValue1 != this.dropdownBaptismAgeValue1_1) {
      isChanged = true;
      return isChanged;
    }
    if (this.dropdownBaptismAgeValue2 != this.dropdownBaptismAgeValue2_1) {
      isChanged = true;
      return isChanged;
    }
    return isChanged;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<String> heightInCmList = heightMap.values.toList();

    return PlatformScaffold(
      appBar: (widget.userDatingPreferencesPageType ==
              UserDatingPreferencesPageType.SETTINGS)
          ? PlatformAppBar(
              leading: PlatformIconButton(
                onPressed: () {
                  _goBack();
                },
                icon: Icon(
                  CupertinoIcons.left_chevron,
                  color: Colors.white,
                ),
                padding: EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
              ),
              material: (_, __) => MaterialAppBarData(
                backgroundColor: AppColors.offWhiteColor,
                elevation: 0.0,
                centerTitle: true,
              ),
              cupertino: (_, __) => CupertinoNavigationBarData(
                brightness: Brightness.dark,
                backgroundColor: AppColors.offWhiteColor,
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
              ),
              title: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  "Match Preferences",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal),
                ),
              ),
            )
          : PlatformAppBar(
              material: (_, __) => MaterialAppBarData(
                backgroundColor: Colors.white,
                elevation: 0.0,
                leading: IconButton(
                  padding: EdgeInsetsDirectional.only(start: 10.0),
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.offWhiteColor,
                    size: 25,
                  ),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.pop(context);

                    //Analytics code
                    analytics.setCurrentScreen(
                        screenName: "onboarding_love_language",
                        screenClassOverride: "onboarding_love_language");
                    amplitudeAnalytics
                        .logEvent("onboarding_love_language_page");
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

                        //Analytics code
                        analytics.setCurrentScreen(
                            screenName: "onboarding_love_language",
                            screenClassOverride: "onboarding_love_language");
                        amplitudeAnalytics
                            .logEvent("onboarding_love_language_page");
                      })),
            ),
      body: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: (widget.userDatingPreferencesPageType ==
                              UserDatingPreferencesPageType.SETTINGS)
                          ? 0
                          : 10,
                    ),
                    (widget.userDatingPreferencesPageType ==
                            UserDatingPreferencesPageType.SETTINGS)
                        ? Container()
                        : RoundIndicators(
                            currentIndicatorIndex: 5,
                            numberOfInidcators: 6,
                            circleSize: 12,
                          ),
                    SizedBox(
                      height: (widget.userDatingPreferencesPageType ==
                              UserDatingPreferencesPageType.SETTINGS)
                          ? 0
                          : AppConfig.heightWithDForSmallDevice(
                              context, 50, 15),
                    ),
                    Text(
                        (widget.userDatingPreferencesPageType ==
                                UserDatingPreferencesPageType.SETTINGS)
                            ? "Match me with:"
                            : "What are your\ndating preferences?",
                        style: TextStyle(
                            fontSize:
                                AppConfig.fontsizeForSmallDevice(context, 28),
                            fontWeight: FontWeight.w600)),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 20, 4),
                    ),
                    Text(
                      "Height",
                      style: TextStyle(
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 24),
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 20, 4),
                    ),
                    Container(
                      width: width * 0.7,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: SizedBox(
                              width: 500,
                              height: Platform.isIOS ? 100 : 60,
                              child: PlatformWidget(
                                material: (_, __) => Container(
                                  decoration: new BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.blueColor,
                                          width: 2.0)),
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: this.dropDownVal1,
                                      isExpanded: true,
                                      items: heightList.map((String value) {
                                        return new DropdownMenuItem<String>(
                                          value: value,
                                          child: new Text(
                                            value,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String val) {
                                        print(val);
                                        setState(() {
                                          this.dropDownVal1 = val;
                                          this.height1 = heightMap[val];
                                        });
                                        validateHeight();
                                      },
                                    ),
                                  ),
                                ),
                                cupertino: (_, __) => CupertinoPicker(
                                  itemExtent: 50,
                                  backgroundColor: CupertinoColors.white,
                                  useMagnifier: true,
                                  children: List<Widget>.generate(
                                      heightList.length, (int i) {
                                    return Center(
                                      child: Text(heightList[i] ?? "No Height",
                                          style: TextStyle(
                                              color: AppColors.blueColor,
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.0)),
                                    );
                                  }),
                                  scrollController: height1ScrollController,
                                  onSelectedItemChanged: (index) {
                                    setState(() {
                                      this.height1 = heightInCmList[index];
                                    });
                                    validateHeight();
                                  },
                                ),
                              ),
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
                            child: SizedBox(
                              width: 500,
                              height: Platform.isIOS ? 100 : 60,
                              child: PlatformWidget(
                                material: (_, __) => Container(
                                  decoration: new BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.blueColor,
                                          width: 2.0)),
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: this.dropdownValue2,
                                      isExpanded: true,
                                      items: heightList.map((String value) {
                                        return new DropdownMenuItem<String>(
                                          value: value,
                                          child: new Text(
                                            value,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String val) {
                                        print(val);
                                        setState(() {
                                          this.dropdownValue2 = val;
                                          this.height2 = heightMap[val];
                                        });
                                        validateHeight();
                                      },
                                    ),
                                  ),
                                ),
                                cupertino: (_, __) => CupertinoPicker(
                                  itemExtent: 50,
                                  backgroundColor: CupertinoColors.white,
                                  useMagnifier: true,
                                  children: List<Widget>.generate(
                                      heightList.length, (int i) {
                                    return Center(
                                      child: Text(heightList[i] ?? "No Height",
                                          style: TextStyle(
                                              color: AppColors.blueColor,
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.0)),
                                    );
                                  }),
                                  scrollController: height2ScrollController,
                                  onSelectedItemChanged: (index) {
                                    setState(() {
                                      this.height2 = heightInCmList[index];
                                    });
                                    validateHeight();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 800,
                      child: Text(
                        this.heightError,
                        style: TextStyle(
                            color: AppColors.redColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Age",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: width * 0.7,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: PlatformTextField(
                              controller: age1Controller,
                              maxLength: 3,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  fontSize: 22, color: AppColors.blueColor),
                              onChanged: (String age) {
                                setState(() {
                                  this.age1 = age;
                                });
                                validateAge();
                              },
                              material: (_, __) => MaterialTextFieldData(
                                decoration: InputDecoration(
                                    hintText: "18",
                                    counterText: "",
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.blueColor,
                                            width: 2)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.blueColor,
                                            width: 2))),
                              ),
                              cupertino: (_, __) => CupertinoTextFieldData(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.blueColor,
                                          width: 2)),
                                  placeholder: "18"),
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
                            child: PlatformTextField(
                              controller: age2Controller,
                              maxLength: 3,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  fontSize: 22, color: AppColors.blueColor),
                              onChanged: (String age) {
                                setState(() {
                                  this.age2 = age;
                                });
                                validateAge();
                              },
                              material: (_, __) => MaterialTextFieldData(
                                decoration: InputDecoration(
                                    hintText: "100",
                                    counterText: "",
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.blueColor,
                                            width: 2)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.blueColor,
                                            width: 2))),
                              ),
                              cupertino: (_, __) => CupertinoTextFieldData(
                                  placeholder: "100",
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.blueColor,
                                          width: 2))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 800,
                      child: Text(
                        this.ageError,
                        style: TextStyle(
                            color: AppColors.redColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          "Max Distance",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 24),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        (maxDistance != 1010)
                            ? maxDistance.toString() + " mi away"
                            : "No limit",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.blueColor),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor:
                            AppColors.communityProfileOptionsBlueColor,
                        inactiveTrackColor: AppColors.sliderInActiveColor,
                        trackShape: RoundedRectSliderTrackShape(),
                        trackHeight: 4.0,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 12.0),
                        thumbColor: Colors.white,
                        overlayColor: AppColors.sliderOverlayColor,
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 28.0),
                        tickMarkShape: RoundSliderTickMarkShape(),
                        activeTickMarkColor:
                            AppColors.communityProfileOptionsBlueColor,
                        inactiveTickMarkColor: AppColors.sliderInActiveColor,
                        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                        valueIndicatorColor:
                            AppColors.communityProfileOptionsBlueColor,
                        valueIndicatorTextStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      child: Slider(
                        value: (maxDistance.toDouble()),
                        min: 10,
                        max: 1010,
                        divisions: 100,
                        label: '$maxDistance',
                        onChanged: (value) {
                          setState(
                            () {
                              maxDistance = value.toInt();
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("0 miles"),
                              Text("No limit"),
                            ],
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          "Kids",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 24),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        this._selectAllText()
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      spacing: 8,
                      runSpacing: 10,
                      children: <String>[
                        "No \nkids",
                        "Kids at \nhome",
                        "Kids away \nfrom home"
                      ].map((String b) {
                        var a = b.replaceAll("\n", "");
                        return MyButtons.getBorderedButton(
                            b, AppColors.blueColor, () {
                          setState(() {
                            if (this.selectedCurrentKids.contains(a))
                              this.selectedCurrentKids.remove(a);
                            else
                              this.selectedCurrentKids.add(a);
                          });
                        }, this.selectedCurrentKids.contains(a),
                            buttonWidth: 100,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            verticalPadding: 8);
                      }).toList(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      spacing: 8,
                      runSpacing: 10,
                      children: <String>[
                        "Doesn't \nwant kids",
                        "Wants \nkids",
                        "Open to \nkids"
                      ].map((String b) {
                        var a = b.replaceAll("\n", "");
                        return MyButtons.getBorderedButton(
                            b, AppColors.blueColor, () {
                          setState(() {
                            if (this.selectedWantKids.contains(a))
                              this.selectedWantKids.remove(a);
                            else
                              this.selectedWantKids.add(a);
                          });
                        }, this.selectedWantKids.contains(a),
                            buttonWidth: 100,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            verticalPadding: 8);
                      }).toList(),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.lock,
                          size: 20,
                          color: AppColors.blackColor,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Ethnicity",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 24),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!Global.isPremium) {
                          Navigator.of(context).push(MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => Plan()));
                        }
                      },
                      child: Stack(
                        children: <Widget>[
                          Wrap(
                            direction: Axis.horizontal,
                            spacing: 15,
                            runSpacing: 10,
                            children: <String>[
                              "Indigenous/Native\nAmerican",
                              "East/\nSoutheast\nAsian",
                              "Hispanic/Latinx",
                              "Pacific Islander",
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
                              return MyButtons.getBorderedButton(
                                  b, AppColors.blueColor, () {
                                setState(() {
                                  if (this.selectedEthnicity != null &&
                                      this.selectedEthnicity.contains(a))
                                    this.selectedEthnicity.remove(a);
                                  else
                                    this.selectedEthnicity.add(a);
                                });
                              },
                                  this.selectedEthnicity != null &&
                                      this.selectedEthnicity.contains(a),
                                  buttonWidth: 80,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  verticalPadding: getPadding(b));
                            }).toList(),
                          ),
                          (!Global.isPremium)
                              ? Container(
                                  width: width,
                                  height: Platform.isIOS
                                      ? (AppConfig.fullHeight(context) >= 667
                                          ? 320
                                          : 410)
                                      : 253,
                                  /////
                                  color: Colors.black26,
                                )
                              : Container(),
                          (!Global.isPremium)
                              ? Container(
                                  width: width,
                                  height: 237,
                                  child: Center(
                                    child: Text(
                                      "Upgrade to Pure Match Premium to Unlock this filter",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.lock,
                          size: 20,
                          color: AppColors.blackColor,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Build",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 24),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Check premium user or not for all the stack widgets in user_dating_preference.dart before displaying the ad for preimum subscription
                        if (!Global.isPremium) {
                          Navigator.of(context).push(MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => Plan()));
                        }
                      },
                      child: Stack(
                        children: <Widget>[
                          Wrap(
                            direction: Axis.horizontal,
                            spacing: 15,
                            runSpacing: 10,
                            children: <String>[
                              "Thin",
                              "Athletic",
                              "Average",
                              "Plus Size"
                            ].map((String b) {
                              return MyButtons.getBorderedButton(
                                  b, AppColors.blueColor, () {
                                setState(() {
                                  if (this.selectedBuild.contains(b))
                                    this.selectedBuild.remove(b);
                                  else
                                    this.selectedBuild.add(b);
                                });
                              }, this.selectedBuild.contains(b),
                                  buttonWidth: 80,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal);
                            }).toList(),
                          ),
                          (!Global.isPremium)
                              ? Container(
                                  width: width,
                                  height: Platform.isIOS ? 123 : 127,
                                  color: Colors.black26,
                                )
                              : Container(),
                          (!Global.isPremium)
                              ? Container(
                                  width: width,
                                  height: 123,
                                  child: Center(
                                    child: Text(
                                      "Upgrade to Pure Match Premium to Unlock this filter",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.lock,
                          size: 20,
                          color: AppColors.blackColor,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Education",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 24),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Check premium user or not for all the stack widgets in user_dating_preference.dart before displaying the ad for preimum subscription
                        if (!Global.isPremium) {
                          Navigator.of(context).push(MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => Plan()));
                        }
                      },
                      child: Stack(
                        children: <Widget>[
                          Wrap(
                            direction: Axis.horizontal,
                            spacing: 15,
                            runSpacing: 10,
                            children: <String>[
                              "High School",
                              "Associate",
                              "Bachelor",
                              "Graduate",
                              "Doctorate",
                              "Professional"
                            ].map((String b) {
                              return MyButtons.getBorderedButton(
                                  b, AppColors.blueColor, () {
                                setState(() {
                                  if (this.selectedEducation.contains(b))
                                    this.selectedEducation.remove(b);
                                  else
                                    this.selectedEducation.add(b);
                                });
                              }, this.selectedEducation.contains(b),
                                  buttonWidth: 80,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal);
                            }).toList(),
                          ),
                          (!Global.isPremium)
                              ? Container(
                                  width: width,
                                  height: Platform.isIOS
                                      ? (AppConfig.fullHeight(context) >= 667
                                          ? 123
                                          : 190)
                                      : 126,
                                  color: Colors.black26,
                                )
                              : Container(),
                          (!Global.isPremium)
                              ? Container(
                                  width: width,
                                  height: 123,
                                  child: Center(
                                    child: Text(
                                      "Upgrade to Pure Match Premium to Unlock this filter",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.lock,
                          size: 20,
                          color: AppColors.blackColor,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Personality Type",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 24),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Check premium user or not for all the stack widgets in user_dating_preference.dart before displaying the ad for preimum subscription
                        if (Global.isPremium == false) {
                          Navigator.of(context).push(MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => Plan()));
                        }
                      },
                      child: Stack(
                        children: <Widget>[
                          Wrap(
                            direction: Axis.horizontal,
                            spacing: 15,
                            runSpacing: 10,
                            children: <String>[
                              "INTJ",
                              "INTP",
                              "ENTJ",
                              "ENTP",
                              "INFJ",
                              "INFP",
                              "ENFJ",
                              "ENFP",
                              "ISTJ",
                              "ISFJ",
                              "ESTJ",
                              "ESFJ",
                              "ISTP",
                              "ISFP",
                              "ESTP",
                              "ESFP"
                            ].map((String b) {
                              return MyButtons.getBorderedButton(
                                  b, AppColors.blueColor, () {
                                setState(() {
                                  if (this.selectedPersonality.contains(b))
                                    this.selectedPersonality.remove(b);
                                  else
                                    this.selectedPersonality.add(b);
                                });
                              }, this.selectedPersonality.contains(b),
                                  buttonWidth: 80,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal);
                            }).toList(),
                          ),
                          (Global.isPremium == false)
                              ? Container(
                                  width: width,
                                  height: Platform.isIOS
                                      ? (AppConfig.fullHeight(context) >= 667
                                          ? 385
                                          : 520)
                                      : 405,
                                  color: Colors.black26,
                                )
                              : Container(),
                          (Global.isPremium == false)
                              ? Container(
                                  width: width,
                                  height: 385,
                                  child: Center(
                                    child: Text(
                                      "Upgrade to Pure Match Premium to Unlock this filter",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.lock,
                          size: 20,
                          color: AppColors.blackColor,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Years Since Baptism",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Check premium user or not for all the stack widgets in user_dating_preference.dart before displaying the ad for preimum subscription
                        if (!Global.isPremium) {
                          Navigator.of(context).push(MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => Plan()));
                        }
                      },
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: width * 0.7,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: SizedBox(
                                    width: 500,
                                    height: Platform.isIOS ? 100 : 50,
                                    child: PlatformWidget(
                                      material: (_, __) => Container(
                                        decoration: new BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.blueColor,
                                                width: 2.0)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value:
                                                this.dropdownBaptismAgeValue1,
                                            isExpanded: true,
                                            items:
                                                baptismAgeList.map((int value) {
                                              return new DropdownMenuItem<int>(
                                                value: value,
                                                child: new Text(
                                                  value.toString(),
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (int val) {
                                              print(val);
                                              setState(() {
                                                this.dropdownBaptismAgeValue1 =
                                                    val;
                                              });
                                              this.validateBaptismAge();
                                            },
                                          ),
                                        ),
                                      ),
                                      cupertino: (_, __) => CupertinoPicker(
                                        itemExtent: 50,
                                        backgroundColor: CupertinoColors.white,
                                        useMagnifier: true,
                                        children: List<Widget>.generate(
                                            baptismAgeList.length, (int i) {
                                          return Center(
                                            child: Text(
                                                baptismAgeList[i].toString() ??
                                                    "No Age",
                                                style: TextStyle(
                                                    color: AppColors.blueColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15.0)),
                                          );
                                        }),
                                        scrollController:
                                            baptism1ScrollController,
                                        onSelectedItemChanged: (index) {
                                          setState(() {
                                            this.dropdownBaptismAgeValue1 =
                                                baptismAgeList[index];
                                          });
                                          this.validateBaptismAge();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "to",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: SizedBox(
                                    width: 500,
                                    height: Platform.isIOS ? 100 : 50,
                                    child: PlatformWidget(
                                      material: (_, __) => Container(
                                        decoration: new BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.blueColor,
                                                width: 2.0)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value:
                                                this.dropdownBaptismAgeValue2,
                                            isExpanded: true,
                                            items:
                                                baptismAgeList.map((int value) {
                                              return new DropdownMenuItem<int>(
                                                value: value,
                                                child: new Text(
                                                  value.toString(),
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (int val) {
                                              print(val);
                                              setState(() {
                                                this.dropdownBaptismAgeValue2 =
                                                    val;
                                              });
                                              this.validateBaptismAge();
                                            },
                                          ),
                                        ),
                                      ),
                                      cupertino: (_, __) => CupertinoPicker(
                                        itemExtent: 50,
                                        backgroundColor: CupertinoColors.white,
                                        useMagnifier: true,
                                        children: List<Widget>.generate(
                                            baptismAgeList.length, (int i) {
                                          return Center(
                                            child: Text(
                                                baptismAgeList[i].toString() ??
                                                    "No Age",
                                                style: TextStyle(
                                                    color: AppColors.blueColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15.0)),
                                          );
                                        }),
                                        scrollController:
                                            baptism2ScrollController,
                                        onSelectedItemChanged: (index) {
                                          setState(() {
                                            this.dropdownBaptismAgeValue2 =
                                                baptismAgeList[index];
                                          });
                                          this.validateBaptismAge();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            // TODO: Check user premium or not for all black container widget in user_dating_preferences.dart
                            visible: !Global.isPremium,
                            child: Container(
                              width: Platform.isIOS ? 270 : 275,
                              height: Platform.isIOS ? 105 : 90,
                              color: Colors.black26,
                            ),
                          ),
                          Visibility(
                            // TODO: Check user premium or not for all  "Upgrade to Pure Match Premium to Unlock this filter" text widget in user_dating_preferences.dart"
                            visible: !Global.isPremium,
                            child: Container(
                              width: 270,
                              height: 105,
                              child: Center(
                                child: Text(
                                  "Upgrade to Pure Match Premium to Unlock this filter",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 800,
                      child: Text(
                        this.baptismAgeError,
                        style: TextStyle(
                            color: AppColors.redColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 60,
                          width: 200,
                          child: (_loading)
                              ? PlatformCircularProgressIndicator()
                              : PlatformButton(
                                  onPressed: (this.heightValidation == true &&
                                          this.ageValidation == true ||
                                          this.selectedCurrentKids.isNotEmpty ||
                                          this.selectedWantKids.isNotEmpty)
                                      ? () {
                                          (_loading == false)
                                              ? this._sendDatingPreference(
                                                  context)
                                              : null;
                                        }
                                      : null,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 35),
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
                                    widget.userDatingPreferencesPageType == UserDatingPreferencesPageType.SETTINGS ? "Save Changes" : "Continue",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16),
                                  )),
                        ), 
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
