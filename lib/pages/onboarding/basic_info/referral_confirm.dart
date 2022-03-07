import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_church.dart';

import '../../MyHttp.dart';

class ReferralConfirm extends StatefulWidget {
  @override
  _ReferralConfirmState createState() => _ReferralConfirmState();
}

class _ReferralConfirmState extends State<ReferralConfirm> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String friend = "your friend";

  @override
  void initState() {
    getRefferal();
    // TODO: implement initState

    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(screenName: "onboarding_referral_confirmed");
    amplitudeAnalytics.logEvent("onboarding_referral_confirmed_page");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: AppColors.matchBrowseMatchReactivateMatching,
          elevation: 0.0,
          leading: IconButton(
            padding: EdgeInsetsDirectional.only(start: 20.0),
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            automaticallyImplyLeading: false,
            automaticallyImplyMiddle: false,
            backgroundColor: AppColors.matchBrowseMatchReactivateMatching,
            border: Border(bottom: BorderSide.none),
            padding: EdgeInsetsDirectional.only(start: 10.0),
            leading: CupertinoNavigationBarBackButton(
                color: Colors.white,
                previousPageTitle: null,
                onPressed: () => Navigator.pop(context))),
      ),
      body: Scaffold(
        backgroundColor: AppColors.matchBrowseMatchReactivateMatching,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: height * 0.1,
              ),
              Container(
                width: 100.0,
                height: 100.0,
                alignment: Alignment.center,
                decoration: new BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/gem_transparent.png'),
                      fit: BoxFit.fill),
                ),
              ),
              SizedBox(height: 10),
              Text("Great!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              SizedBox(
                height: 10,
              ),
              Text(
                  " You and ${friend} both earned bonus Gems for growing the Pure Match community!\n\n Check out the Rewards section in Settings to see more!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Expanded(
                child: Padding(
                    padding: EdgeInsetsDirectional.only(
                        bottom: 30.0, start: 30.0, end: 30.0),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: 60,
                          child: PlatformButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserChurch()));
                              },
                              color: Colors.white,
                              materialFlat: (_, __) => MaterialFlatButtonData(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                              cupertinoFilled: (_, __) =>
                                  CupertinoFilledButtonData(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                    color: AppColors
                                        .matchBrowseMatchReactivateMatching,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20),
                              )),
                        ))),
              )
            ],
          ),
        ),
      ),
    );
  }

  void getRefferal() async {
    setState(() {});

    var res = await MyHttp.get("users/referral-confirmed");
    if (res.statusCode == 200 || res.statusCode == 201) {
      var jsondata = jsonDecode(res.body);
      friend = jsondata["name"];
      print(friend);

      setState(() {});
    } else {
      print(res.body);
    }
  }
}
