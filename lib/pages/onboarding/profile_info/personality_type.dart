import 'dart:convert';
import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/profile_info/love_language.dart';
import 'package:pure_match/pages/onboarding/profile_info/user_dating_preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class PersonalityType extends StatefulWidget {
  @override
  _PersonalityTypeState createState() => _PersonalityTypeState();
}

class _PersonalityTypeState extends State<PersonalityType> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String selectedPersonality = "Select";
  int selectedIndex = 0;
  String temSelectedPersonality = "Select";
  int tempSelectedIndex = 0;
  String error = "";
  bool _loading = false;
  Text selectedValue = new Text(
    "Select",
    textAlign: TextAlign.left,
  );
  List<String> personalities = <String>[
    'Select',
    'INTJ',
    'INTP',
    'ENTJ',
    'ENTP',
    'INFJ',
    'INFP',
    'ENFJ',
    'ENFP',
    'ISTJ',
    'ISFJ',
    'ESTJ',
    'ESFJ',
    'ISTP',
    'ISFP',
    'ESTP',
    'ESFP',
  ];

  FixedExtentScrollController _scrollController;

  void _setPersonality() async {
    setState(() {
      _loading = true;
    });
    var res = await MyHttp.put(
        "users/update", {"personality_type": this.selectedPersonality});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "saved_personality",
          parameters: <String, dynamic>{'personality': selectedPersonality});

      amplitudeAnalytics.logEvent("saved_personality",
          eventProperties: {'personality': selectedPersonality});

      print("User updated");
      print(res.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoveLanguage()));
      //Analytics code
      analytics.setCurrentScreen(
          screenName: "love_language", screenClassOverride: "love_language");
      amplitudeAnalytics.logEvent("love_language_page");
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

  void _setNoPersonality() {
    setState(() {
      this.selectedPersonality = null;
      _setPersonality();
    });
  }

  _launchURL() async {
    const url = 'https://www.16personalities.com';
    launch(url);
  }

  Column _buildBottomPersonalityPicker() {
    _scrollController =
        new FixedExtentScrollController(initialItem: this.selectedIndex);
    tempSelectedIndex = selectedIndex;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.doneBarColor,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.doneBarColor,
                  width: 0.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: CupertinoButton(
                      child: Icon(CupertinoIcons.left_chevron,
                          color: AppColors.blueColor, size: 30.0),
                      onPressed: () => _scrollController.jumpToItem(
                          tempSelectedIndex != 0
                              ? tempSelectedIndex - 1
                              : personalities.length - 1)),
                ),
                Center(
                  child: CupertinoButton(
                      child: Icon(CupertinoIcons.right_chevron,
                          color: AppColors.blueColor, size: 30.0),
                      onPressed: () => _scrollController.jumpToItem(
                          tempSelectedIndex != personalities.length - 1
                              ? tempSelectedIndex + 1
                              : 0)),
                ),
                new Spacer(),
                Center(
                  child: CupertinoButton(
                    child: Text(
                      "Done",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 20),
                    ),
                    onPressed: () => _doneButtonClicked(),
                  ),
                ),
              ],
            )),
        SizedBox(
          height: AppConfig.heightWithDForSmallDevice(context, 300, 50),
          child: CupertinoPicker(
            itemExtent: 50,
            backgroundColor: Colors.white,
            useMagnifier: true,
            children: List<Widget>.generate(personalities.length, (int i) {
              return Text(personalities[i] ?? "No Personality",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                      fontSize: 23.0));
            }),
            scrollController: _scrollController,
            onSelectedItemChanged: (index) {
              setState(() {
                this.tempSelectedIndex = index;
                this.temSelectedPersonality = personalities[index];
              });
            },
          ),
        )
      ],
    );
  }

  void _doneButtonClicked() {
    //Remove bottom modal from widget tree
    Navigator.of(context).pop();

    //Set temp to actual values
    this.selectedPersonality = this.temSelectedPersonality;
    this.selectedIndex = this.tempSelectedIndex;

    //Show the selected values in the drop down container
    setState(() {
      this.selectedValue = new Text(
        this.selectedPersonality,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.blueColor),
      );
    });
  }

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(25);
  }

  @override
  Widget build(BuildContext context) {
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
                  screenName: "onboarding_user_interest",
                  screenClassOverride: "onboarding_user_interest");
              amplitudeAnalytics.logEvent("onboarding_user_interest_page");
            },
          ),
        ),
        body: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  RoundIndicators(
                    currentIndicatorIndex: 4,
                    numberOfInidcators: 6,
                    circleSize: 12,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "What’s your \nPersonality Type?",
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 36),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 200,
                          decoration: new BoxDecoration(
                              border: Border.all(
                                  color: AppColors.greyColor, width: 1.0)),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.blueColor,
                              ),
                              value: selectedPersonality,
                              hint: Text("Select"),
                              items: personalities.map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(
                                    value,
                                    style: TextStyle(
                                        color: AppColors.blueColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String personality) {
                                setState(() {
                                  this.selectedPersonality = personality;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Don’t know your type?",
                          style: TextStyle(
                              color: AppColors.blueColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          child: Text("Find out Here",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.blueColor,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  decoration: TextDecoration.underline)),
                          onTap: () => _launchURL(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(height: 20),
                  ),
                  Center(
                    child: InkWell(
                        child: Text("I'll do this later",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.blueColor,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                decoration: TextDecoration.underline)),
                        onTap: () => _setNoPersonality()),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 30.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 60,
                        width: 200,
                        child: FlatButton(
                            onPressed: (this.selectedPersonality != "Select")
                                ? () {
                                    (_loading == false)
                                        ? this._setPersonality()
                                        : null;
                                  }
                                : null,
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 55),
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
                  ),
                ],
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
                    screenName: "onboarding_user_interest",
                    screenClassOverride: "onboarding_user_interest");
                amplitudeAnalytics.logEvent("onboarding_user_interest_page");
              }),
        ),
        child: SafeArea(
          child: CupertinoPageScaffold(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: AppConfig.heightWithDForSmallDevice(context, 10, 4),
                  ),
                  RoundIndicators(
                    currentIndicatorIndex: 4,
                    numberOfInidcators: 6,
                    circleSize: 12,
                  ),
                  SizedBox(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 50, 15),
                  ),
                  Text("What’s your \nPersonality Type?",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 25))),
                  SizedBox(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 50, 15),
                  ),
                  Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                            width: 250,
                            height: 50,
                            decoration: new BoxDecoration(
                                border: Border.all(
                                    color: AppColors.greyColor, width: 1.0)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 1),
                            child: GestureDetector(
                              child: Row(
                                children: <Widget>[
                                  selectedValue,
                                  new Spacer(),
                                  Icon(Icons.keyboard_arrow_down,
                                      color: AppColors.blueColor)
                                ],
                              ),
                              onTap: () => showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.white,
                                  elevation: 1.0,
                                  builder: (BuildContext pickerContext) {
                                    return _buildBottomPersonalityPicker();
                                  }),
                            )),
                        SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 10, 4),
                        ),
                        Text(
                          "Don’t know your type?",
                          style: TextStyle(
                              color: AppColors.blueColor,
                              fontWeight: FontWeight.w600,
                              fontSize: AppConfig.fontsizeForSmallDevice(
                                  context, 16)),
                        ),
                        SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 10, 4),
                        ),
                        CupertinoButton(
                          color: Colors.white,
                          disabledColor: Colors.white,
                          child: Text(
                            "Find out Here",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: AppConfig.fontsizeForSmallDevice(
                                    context, 16),
                                color: AppColors.blueColor,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                decoration: TextDecoration.underline),
                          ),
                          onPressed: () => _launchURL(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 20, 4)),
                  ),
                  Center(
                      child: CupertinoButton(
                    color: Colors.white,
                    disabledColor: Colors.white,
                    child: Text(
                      "I'll do this later",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 16),
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.underline),
                    ),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserDatingPreference())),
                  )),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 30.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 60,
                        width: 220,
                        child: CupertinoButton(
                            onPressed: (this.selectedPersonality != "Select")
                                ? () {
                                    (_loading == false)
                                        ? this._setPersonality()
                                        : null;
                                  }
                                : null,
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 55),
                            color: AppColors.blueColor,
                            disabledColor: AppColors.disabledBlueColor,
                            borderRadius: BorderRadius.circular(10),
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
