import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_married.dart';
import 'dart:io' show Platform;

class UserGender extends StatefulWidget {
  @override
  _UserGenderState createState() => _UserGenderState();
}

class _UserGenderState extends State<UserGender> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int gender = -1;
  String error = "";
  String height = "";
  bool _loading = false;

  Future<void> _setGender() async {
    setState(() {
      _loading = true;
    });
    var res = await MyHttp.put(
        "users/update", {"gender": (this.gender == 0) ? "man" : "woman"});
    if (res.statusCode == 200) {
      // Analytics tracking code
      String gender = (this.gender == 0) ? "male" : "female";
      //Analytics tracking code
      analytics.logEvent(
          name: "saved_user_gender",
          parameters: <String, dynamic>{"gender": gender});

      amplitudeAnalytics
          .logEvent("saved_user_gender", eventProperties: {"gender": gender});

      print("User updated");
      print(res.body);
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        var body = json.decode(res.body);
        error = body["message"] ?? "error";
        _loading = false;
      });
    }
  }

  Future<void> _setHeight() async {
    setState(() {
      _loading = true;
    });
    double dHeight = double.tryParse(this.height);
    var res = await MyHttp.put("users/update", {"height": dHeight});
    if (res.statusCode == 200) {
      //analytics tracking code
      analytics.logEvent(
          name: "saved_user_height",
          parameters: <String, dynamic>{"height": this.height});

      amplitudeAnalytics.logEvent("saved_user_height",
          eventProperties: {"height": this.height});

      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserMarried()));
      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: 'onboarding_marital_status',
          screenClassOverride: 'onboarding_marital_status');
      amplitudeAnalytics.logEvent("onboarding_marital_status_page");
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

  // only for android
  String dropDownVal = "4'5 (135 cm)";
  List<String> heightList = ["4'5 (135 cm)"];

  @override
  void initState() {
    heightList = heightMap.keys.toList();
    print(heightList);
    this.dropDownVal = heightList[0];
    super.initState();
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(13);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    List<String> heightInCmList = heightMap.values.toList();

    if (Platform.isAndroid) {
      return Scaffold(
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
                  screenName: "onboarding_spiritual_birthday",
                  screenClassOverride: "onboarding_spiritual_birthday");
              amplitudeAnalytics.logEvent("onboarding_spiritual_birthday_page");
            },
          ),
        ),
        body: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    RoundIndicators(
                      currentIndicatorIndex: 7,
                      numberOfInidcators: 14,
                      circleSize: 12,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text("I am...",
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.w600)),
                    SizedBox(
                      height: 30,
                    ),
                    MyButtons.getBorderedButton("Man", AppColors.blueColor, () {
                      setState(() {
                        this.gender = 0;
                      });
                    }, this.gender == 0),
                    SizedBox(
                      height: 10,
                    ),
                    MyButtons.getBorderedButton("Woman", AppColors.blueColor,
                        () {
                      setState(() {
                        this.gender = 1;
                      });
                    }, this.gender == 1),
                    SizedBox(height: 30),
                    Text("My Height is...",
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.w600)),
                    SizedBox(height: 30),
                    DropdownButton<String>(
                      value: this.dropDownVal,
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
                          this.dropDownVal = val;
                          this.height = heightMap[val];
                        });
                      },
                    ),
//                  TextField(
//                    keyboardType: TextInputType.number,
//                    style: TextStyle(fontSize: 22, color: AppColors.blueColor),
//                    onChanged: (String height) {
//                      setState(() {
//                        this.height = height;
//                      });
//                    },
//                    decoration: InputDecoration(
//                        hintText: "In cm",
//                        contentPadding: EdgeInsets.all(0),
//                        enabledBorder: UnderlineInputBorder(
//                            borderSide: BorderSide(
//                                color: AppColors.blueColor, width: 2))),
//                  ),
                    SizedBox(
                      height: 50,
                    ),
                    Text(this.error),
                    /*SizedBox(
                      height: 30,
                    ),*/
                    Container(
                      padding: EdgeInsetsDirectional.only(bottom: 20, top: 20),
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 60,
                          width: 220,
                          child: FlatButton(
                              onPressed: (this.gender != -1 &&
                                      double.tryParse(this.height) != null)
                                  ? () {
                                      if (_loading == false) {
                                        this._setGender();
                                        this._setHeight();
                                      } else {
                                        null;
                                      }
                                    }
                                  : null,
                              color: AppColors.blueColor,
                              disabledColor: AppColors.disabledBlueColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
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
                // Analytics tracking code
                analytics.setCurrentScreen(
                    screenName: "onboarding_spiritual_birthday",
                    screenClassOverride: "onboarding_spiritual_birthday");
                amplitudeAnalytics
                    .logEvent("onboarding_spiritual_birthday_page");
              }),
        ),
        child: SafeArea(
          child: CupertinoPageScaffold(
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    RoundIndicators(
                      currentIndicatorIndex: 7,
                      numberOfInidcators: 14,
                      circleSize: 12,
                    ),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 30, 10),
                    ),
                    Text("I am...",
                        style: TextStyle(
                            fontSize:
                                AppConfig.fontsizeForSmallDevice(context, 36),
                            fontWeight: FontWeight.w600)),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 30, 10),
                    ),
                    MyButtons.getBorderedButton("Man", AppColors.blueColor, () {
                      setState(() {
                        this.gender = 0;
                      });
                    }, this.gender == 0),
                    SizedBox(
                      height: 10,
                    ),
                    MyButtons.getBorderedButton("Woman", AppColors.blueColor,
                        () {
                      setState(() {
                        this.gender = 1;
                      });
                    }, this.gender == 1),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 30, 10),
                    ),
                    Text("My Height is...",
                        style: TextStyle(
                            fontSize:
                                AppConfig.fontsizeForSmallDevice(context, 36),
                            fontWeight: FontWeight.w600)),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 30, 10),
                    ),
                    Center(
                        child: SizedBox(
                            height: AppConfig.heightWithDForSmallDevice(
                                context, 200, 40),
                            width: 300,
                            child: CupertinoPicker(
                              itemExtent: 50,
                              backgroundColor: CupertinoColors.white,
                              useMagnifier: true,
                              children: List<Widget>.generate(heightList.length,
                                  (int i) {
                                return Text(heightList[i] ?? "No Height",
                                    style: TextStyle(
                                        color: AppColors.blueColor,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24.0));
                              }),
                              scrollController: new FixedExtentScrollController(
                                initialItem: 5,
                              ),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  this.height = heightInCmList[index];
                                });
                              },
                            ))),
                    SizedBox(
                      height: height * 0.1,
                    ),
                    Text(this.error),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 60,
                        width: 220,
                        child: FlatButton(
                            onPressed: (this.gender != -1 &&
                                    double.tryParse(this.height) != null)
                                ? () {
                                    this._setGender();
                                    this._setHeight();
                                  }
                                : null,
                            color: AppColors.blueColor,
                            disabledColor: AppColors.disabledBlueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
