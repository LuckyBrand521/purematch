import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:amplitude_flutter/amplitude.dart';

class StayPremium extends StatefulWidget {
  @override
  _StayPremiumState createState() => _StayPremiumState();
}

class _StayPremiumState extends State<StayPremium> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  Widget build(BuildContext context) {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);

    return PlatformScaffold(
      backgroundColor: AppColors.blueColor,
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: AppColors.blueColor,
          elevation: 0.0,
          leading: null,
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          automaticallyImplyLeading: false,
          automaticallyImplyMiddle: false,
          backgroundColor: AppColors.blueColor,
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
        ),
      ),
      body: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.blueColor,
          body: Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: Container()),
                Text(
                  "Ben, to get you to \nstay Premium we’d love to \noffer 50% off for 3 months of \nmonthly subscription",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                      fontSize: 28.0,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Your membership will continue until \nit expires on 3/3/2021.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Your card will not be recharged at the \nend of the membership period.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                      color: Colors.white),
                ),
                Expanded(child: Container()),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 20.0),
                  child: PlatformButton(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    color: Colors.white,
                    onPressed: () {
                      //Analytics tracking code
                      analytics.setCurrentScreen(
                          screenName: "stay_premium",
                          screenClassOverride: "stay_premium");
                      amplitudeAnalytics.logEvent("stay_premium_page");
                    },
                    materialFlat: (_, __) => MaterialFlatButtonData(
                      child: Text(
                        "Stay and get 50% off",
                        style: TextStyle(
                            fontSize: 20,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal),
                      ),
                    ),
                    cupertino: (_, __) => CupertinoButtonData(
                      child: Text(
                        "Stay and get 50% off",
                        style: TextStyle(
                            fontSize: 20,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  child: PlatformButton(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    color: Colors.white,
                    onPressed: () {},
                    materialFlat: (_, __) => MaterialFlatButtonData(
                      child: Text(
                        "Cancel Subscription",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal),
                      ),
                    ),
                    cupertino: (_, __) => CupertinoButtonData(
                      child: Text(
                        "Cancel Subscription",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal),
                      ),
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
