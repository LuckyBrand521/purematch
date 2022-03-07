import 'dart:convert';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppColors.dart';
import '../MyHttp.dart';
import 'CheckYourEmail.dart';
import 'ThankYouQues.dart';

class NewQuestions extends StatefulWidget {
  @override
  _NewQuestionsState createState() => _NewQuestionsState();
}

class _NewQuestionsState extends State<NewQuestions> {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  bool loading = false;
  int _currentQueIndex = 0;
  int _currentSelectedAnswerIndex = -1;

  List<String> headerMessages = [
    "Let the fun begin!",
    "Off to a great start!",
    "You're doing great!",
    "Just a few more...",
    "Keep going!",
    "Almost there...",
    "Last one!\nThanks for your responses!"
  ];

  List<String> questions = [
    "Does the Bible teach we should be baptized?",
    "When I was baptized it was:",
    "Is praying Jesus into your heart the Bibical moment of salvation?",
    "4. Do you believe it’s fine to have sex as long as you love and are committed to your partner and you are considering marriage in the future?",
    "5. Do you believe that we're called to fulfill Christ's love as part of a family of believers devoted to spreading the gospel of Christ?",
  ];

  List<List> answers = [
    [
      "A. No, baptism is just a symbol",
      "B. Yes, for the forgiveness of sins and to receive the indwelling of the Holy Spirit",
      "C. Yes, but baptism is not commanded for salvation",
      "D. I don't know"
    ],
    [
      "A. By full immersion",
      "B. By sprinkling",
      "C. I can't exactly remember the method",
      "D. I have not been baptized"
    ],
    ["A. Yes", "B. No"],
    ["A. Yes", "B. No"],
    ["A. Yes", "B. No"],
  ];
  List<String> listAnswers = [
    null,
    null,
    null,
    null,
    null,
  ];
  void _nextQuestion() {
    if (_currentQueIndex == 0 || _currentQueIndex == 1) {
      if (_currentSelectedAnswerIndex == 0) {
        listAnswers[_currentQueIndex] = "A";
      } else if (_currentSelectedAnswerIndex == 1) {
        listAnswers[_currentQueIndex] = "B";
      } else if (_currentSelectedAnswerIndex == 2) {
        listAnswers[_currentQueIndex] = "C";
      } else if (_currentSelectedAnswerIndex == 3) {
        listAnswers[_currentQueIndex] = "D";
      }
    } else {
      if (_currentSelectedAnswerIndex == 0) {
        listAnswers[_currentQueIndex] = "Yes";
      } else if (_currentSelectedAnswerIndex == 1) {
        listAnswers[_currentQueIndex] = "No";
      }
    }
    _currentSelectedAnswerIndex = -1;
    if (_currentQueIndex == this.questions.length - 1) {
      sendAnwsers();
      analytics.setCurrentScreen(
          screenName: "thank_you_questions",
          screenClassOverride: "thank_you_questions");
      amplitudeAnalytics.logEvent("thank_you_questions_page");
    } else {
      setState(() {
        _currentQueIndex += 1;
      });
    }
  }

  Future<void> sendAnwsers() async {
    setState(() {
      loading = true;
    });
    Map map = Map<String, Object>();
    for (int i = 0; i < listAnswers.length; i++) {
      if (i == 0) {
        map.putIfAbsent("q_one", () => listAnswers[i]);
      } else if (i == 1) {
        map.putIfAbsent("q_two", () => listAnswers[i]);
      } else if (i == 2) {
        map.putIfAbsent("q_three", () => listAnswers[i]);
      } else if (i == 3) {
        map.putIfAbsent("q_four", () => listAnswers[i]);
      } else if (i == 4) {
        map.putIfAbsent("q_five", () => listAnswers[i]);
      }
    }
    var sp = await SharedPreferences.getInstance();
    String userEmail = sp.getString("email");
    map.putIfAbsent("email", () => userEmail);
    try {
      var res = await MyHttp.post("/verifyOnboarding", map);
      if (res.statusCode == 200 || res.statusCode == 201) {
        print(res.body);
        var body = json.decode(res.body);
        bool isSuccess = body["succes"];
        if (isSuccess == true) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ThankYouQues()));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CheckYourEmail()));
        }
      } else {
        print(res.statusCode);
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Global.setOnboardingId(4);
    setState(() {});
    amplitudeAnalytics.init(apiKey);

    // Analytics tracking code
    analytics.setCurrentScreen(
        screenName: "yes_no_question", screenClassOverride: "yes_no_question");
    amplitudeAnalytics.logEvent("yes_no_question_page");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PlatformScaffold(
      backgroundColor: Colors.white,
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            padding: EdgeInsetsDirectional.only(
                start: (AppConfig.fullWidth(context) >= 375) ? 20 : 16),
            icon: Icon(Icons.arrow_back, color: AppColors.offWhiteColor),
            onPressed: () {
              if (this._currentQueIndex - 1 != -1) {
                setState(() {
                  this._currentQueIndex = this._currentQueIndex - 1;
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            brightness: Brightness.dark,
            automaticallyImplyLeading: false,
            automaticallyImplyMiddle: false,
            backgroundColor: Colors.white,
            border: Border(bottom: BorderSide.none),
            padding: EdgeInsetsDirectional.only(
                start: (AppConfig.fullWidth(context) >= 375) ? 10 : 6),
            leading: CupertinoNavigationBarBackButton(
                color: AppColors.offWhiteColor,
                previousPageTitle: null,
                onPressed: () => () {
                      if (this._currentQueIndex - 1 != -1) {
                        setState(() {
                          this._currentQueIndex = this._currentQueIndex - 1;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    })),
      ),
      body: SafeArea(
        child: Center(
            child: (loading)
                ? PlatformCircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        RoundIndicators(
                          currentIndicatorIndex: _currentQueIndex,
                          numberOfInidcators: questions.length,
                          circleSize: 12,
                        ),
                        SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 20, 4),
                        ),
                        Text(
                          headerMessages[_currentQueIndex] != null
                              ? headerMessages[_currentQueIndex]
                              : "Keep going!",
                          style: TextStyle(
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                            fontSize: AppConfig.heightWithDForSmallDevice(
                                context, 28, 4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 15, 4),
                        ),
                        Text(
                          questions[_currentQueIndex],
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: AppConfig.heightWithDForSmallDevice(
                                context, 24, 4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 20, 4),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: answers[_currentQueIndex].length,
                            itemBuilder: (context, index) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  MyButtons.getBorderedButton1(
                                      answers[_currentQueIndex][index],
                                      AppColors.blueColor,
                                      AppColors.blackColor, () {
                                    setState(() {
                                      this._currentSelectedAnswerIndex = index;
                                      setState(() {});
                                    });
                                  }, this._currentSelectedAnswerIndex == index),
                                  SizedBox(
                                    height: AppConfig.heightWithDForSmallDevice(
                                        context, 10, 4),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            bottom: AppConfig.heightWithDForSmallDevice(
                                context, 20, 4),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              height: AppConfig.heightWithDForSmallDevice(
                                  context, 60, 10),
                              width: 220,
                              child: PlatformButton(
                                  onPressed: (_currentSelectedAnswerIndex != -1)
                                      ? () {
                                          _nextQuestion();
                                        }
                                      : null,
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
                  )),
      ),
    );
  }
}
