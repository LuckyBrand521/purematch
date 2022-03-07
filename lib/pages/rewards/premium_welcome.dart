import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/settings/settings_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

import '../AppColors.dart';

class PremiumWelcome extends StatefulWidget {
  @override
  _PremiumWelcomeState createState() => _PremiumWelcomeState();
}

class _PremiumWelcomeState extends State<PremiumWelcome> {
  var isFirstTime;
  int next = 0;

//Analytics tracking code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");

  @override
  void initState() {
    // TODO: implement initState
    tutorialPage();
    super.initState();

    //Analytics code
    amplitudeAnalytics.init(apiKey);
  }

  void tutorialPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('tutorial_membership_first_time');
    if (isFirstTime != null && !isFirstTime) {
      print("not first time");
      prefs.setBool('tutorial_membership_first_time', false);
    } else {
      print("first time app runn!!!");
      prefs.setBool('tutorial_membership_first_time', false);
    }
    isFirstTime = true;
  }

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    double mediaHeight = MediaQuery.of(context).size.height;
    return PlatformScaffold(
      backgroundColor: AppColors.blueColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        "assets/images/premium_Membership.png",
                        width: 200,
                        height: 200,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Center(
                    child: Image.asset(
                      "assets/images/welcomepremium.png",
                      // width: mediaWidth,
                    ),
                  ),
                  Center(
                    child: Text(
                      "Now you can :",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 25),
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        "• Use unlimited match preference filters📏📐\n• See who's liked you and who's viewed you👀😄\n• Get your 2 FREE match boost a month🚀🚀\n• Get your Free profile review from  one of your dating coaches👩‍🏫👨‍🏫‍\n• Activate Lurker Mode when you want🙈🙈‍",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize:
                                AppConfig.fontsizeForSmallDevice(context, 20),
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 50, 15),
                  ),
                  Center(
                    child: SizedBox(
                      width: mediaWidth * 0.90,
                      height: 60,
                      child: PlatformButton(
                        disabledColor: AppColors.greyColor,
                        color: AppColors.redColor,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MainSettings(
                                    isFromPremiumWelcome: true,
                                  )));
                        },
                        child: Text(
                          "Got it!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.blueColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 20),
                        ),
                        materialFlat: (_, __) => MaterialFlatButtonData(
                          disabledColor: AppColors.greyColor,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        cupertino: (_, __) => CupertinoButtonData(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              (isFirstTime == true && next == 0)
                  ? Positioned(
                      top: mediaHeight / 2,
                      right: mediaWidth / 7,
                      child: Stack(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.3,
                            height: 150,
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: FittedBox(
                              child: Column(
                                children: [
                                  Text(
                                    "Go to 'Matching' and then select\n'My History to see who viewed\nor liked the profile",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700),
                                  ),

                                  //

                                  SizedBox(
                                    height: 10,
                                  ),
                                  ButtonTheme(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal:
                                            18.0), //adds padding inside the button
                                    materialTapTargetSize: MaterialTapTargetSize
                                        .shrinkWrap, //limits the touch area to the button area
                                    minWidth: 0, //wraps child's width
                                    height: 0,
                                    child: FlatButton(
                                      onPressed: () {
                                        next++;
                                        setState(() {});
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                              color: Colors.white, width: 2)),
                                      color: Colors.white,
                                      child: Text(
                                        "Got it!",
                                        style: TextStyle(
                                            color: AppColors.blueColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                    )
                  : Container(),
              (isFirstTime == true && next == 1)
                  ? Positioned(
                      top: mediaHeight / 2,
                      right: mediaWidth / 7,
                      child: Stack(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.3,
                            height: 150,
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: FittedBox(
                              child: Column(
                                children: [
                                  Text(
                                    "Go to 'Setting' and then select\n'Privacy Settings' and see your\nability to acitvate 'Invisible Mode'",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600),
                                  ),

                                  //

                                  SizedBox(
                                    height: 10,
                                  ),
                                  ButtonTheme(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal:
                                            18.0), //adds padding inside the button
                                    materialTapTargetSize: MaterialTapTargetSize
                                        .shrinkWrap, //limits the touch area to the button area
                                    minWidth: 0, //wraps child's width
                                    height: 0,
                                    child: FlatButton(
                                      onPressed: () {
                                        next++;
                                        setState(() {});
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                              color: Colors.white, width: 2)),
                                      color: Colors.white,
                                      child: Text(
                                        "Got it!",
                                        style: TextStyle(
                                            color: AppColors.blueColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                    )
                  : Container(),
              (isFirstTime == true && next == 2)
                  ? Positioned(
                      top: mediaHeight / 2,
                      right: mediaWidth / 7,
                      child: Stack(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.3,
                            height: 150,
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: FittedBox(
                              child: Column(
                                children: [
                                  Text(
                                    "Go to 'Setting' and then select\n'Match Preference' to see all of\nyour new dating filters!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600),
                                  ),

                                  //

                                  SizedBox(
                                    height: 10,
                                  ),
                                  ButtonTheme(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal:
                                            18.0), //adds padding inside the button
                                    materialTapTargetSize: MaterialTapTargetSize
                                        .shrinkWrap, //limits the touch area to the button area
                                    minWidth: 0, //wraps child's width
                                    height: 0,
                                    child: FlatButton(
                                      onPressed: () {
                                        next++;
                                        setState(() {});
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                              color: Colors.white, width: 2)),
                                      color: Colors.white,
                                      child: Text(
                                        "Got it!",
                                        style: TextStyle(
                                            color: AppColors.blueColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _triangle() {
  //   return CustomPaint(
  //     painter: Triangle(Colors.black),
  //   );
  // }
}
