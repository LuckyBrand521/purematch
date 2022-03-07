// this is the wdidget with yes no questions only

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/NoReason.dart';
import 'package:pure_match/pages/onboarding/ThankYouQues.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/cupertino.dart';
import '../AppColors.dart';

class Question {
  final int id;
  final String text;
  final String verse;

  Question(this.id, this.text, this.verse);

  Question.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        text = json["text"],
        verse = json["verse"];
}

class YesNoQues extends StatefulWidget {
  @override
  _YesNoQuesState createState() => _YesNoQuesState();
}

class _YesNoQuesState extends State<YesNoQues> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  List<Question> _questions = [];
  bool loading = true;
  int _currentQueIndex = -1;
  String noReason;

  List<String> headerMessages = [
    "Let the fun begin!",
    "Off to a great start!",
    "You're doing great!",
    "Just a few more...",
    "Keep going!",
    "Almost there...",
    "Last one!\nThanks for your responses!"
  ];

  void _getQuestions() async {
    try {
      var res = await MyHttp.get("/questions/all");
      List<Question> questions1 = [];
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        print(body);
        var questions = body["questions"] as List<dynamic>;
        if (questions != null && questions.length > 0) {
          setState(() {
            questions1 = questions.map((q) {
              return Question.fromJson(q);
            }).toList();

            //To remove once backend questions DB is updated
            if (questions1.length >= 8)
              questions1.removeRange(8, questions1.length);
            questions1.removeAt(0);

            _questions = questions1;
          });
        }
        setState(() {
          _currentQueIndex = 0;
        });
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      loading = false;
    });
  }

  void _sendAnswer(String text) async {
    setState(() {
      loading = true;
    });
    var data = {
      "text": text,
      "questionId": _questions[_currentQueIndex].id,
      "reason": this.noReason
    };
    print(data);
    try {
      var res = await MyHttp.post("/answers", data);
      if (res.statusCode == 200 || res.statusCode == 201) {
        print(res.body);
        this._nextQuestion();
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
    Global.setOnboardingId(4);
    this._getQuestions();
    super.initState();
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);

    // Analytics tracking code
    analytics.setCurrentScreen(
        screenName: "yes_no_question", screenClassOverride: "yes_no_question");
    amplitudeAnalytics.logEvent("yes_no_question_page");
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Colors.white,
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            padding: EdgeInsetsDirectional.only(
              start: AppConfig.heightWithDForSmallDevice(context, 20, 4),
            ),
            icon: Icon(Icons.arrow_back, color: AppColors.offWhiteColor),
            onPressed: () {
              if (this._currentQueIndex - 1 != -1 && noReason == null) {
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
              start: AppConfig.heightWithDForSmallDevice(context, 10, 4),
            ),
            leading: CupertinoNavigationBarBackButton(
              color: AppColors.offWhiteColor,
              previousPageTitle: null,
              onPressed: () => Navigator.pop(context),
            )),
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
                          numberOfInidcators: _questions.length,
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
                          _questions[_currentQueIndex].text,
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
                        Text(
                          _questions[_currentQueIndex].verse != null
                              ? _questions[_currentQueIndex].verse
                              : "Verse",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: AppConfig.heightWithDForSmallDevice(
                                  context, 14, 4),
                              color: AppColors.referenceColor),
                          textAlign: TextAlign.center,
                        ),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: AppConfig.heightWithDForSmallDevice(
                                context, 20, 4),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            bottom: AppConfig.heightWithDForSmallDevice(
                                context, 20, 4),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _getButton("Yes", AppColors.blueColor, () {
                                  this._sendAnswer("Yes");
                                }),
                                SizedBox(
                                  height: 10,
                                ),
                                _getButton("No", AppColors.noButtonColor, () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => NoReason()))
                                      .then((val) {
                                    if (val != null) {
                                      setState(() {
                                        this.noReason = val["noReason"];
                                      });
                                      this._sendAnswer("No");
                                    }
                                  });
                                }), //_getButton
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
      ),
    );
  }

  void _nextQuestion() {
    if (_currentQueIndex == this._questions.length - 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ThankYouQues()));
      analytics.setCurrentScreen(
          screenName: "thank_you_questions",
          screenClassOverride: "thank_you_questions");
      amplitudeAnalytics.logEvent("thank_you_questions_page");
    } else {
      noReason = null;
      setState(() {
        _currentQueIndex += 1;
      });
    }
  }

  Padding _getButton(String name, Color buttonColor, Function f) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: SizedBox(
        width: double.infinity,
        height: AppConfig.heightWithDForSmallDevice(context, 60, 10),
        child: PlatformButton(
            onPressed: f,
            padding: EdgeInsets.symmetric(
              vertical: AppConfig.heightWithDForSmallDevice(context, 20, 4),
            ),
            color: buttonColor,
            materialFlat: (_, __) => MaterialFlatButtonData(
                  color: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
            cupertino: (_, __) => CupertinoButtonData(
                  borderRadius: BorderRadius.circular(10),
                ),
            child: Text(
              name,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: AppConfig.heightWithDForSmallDevice(context, 20, 4),
                  fontWeight: FontWeight.w700),
            )),
      ),
    );
  }
}
