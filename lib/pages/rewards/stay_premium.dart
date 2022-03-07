import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/rewards/discount_premium_offer.dart';
import 'package:pure_match/pages/rewards/membership_feedback.dart';
import 'package:amplitude_flutter/amplitude.dart';

import '../AppColors.dart';
import '../MyHttp.dart';
import 'package:intl/intl.dart';

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

  String firstName;
  String expire;
  bool _loading = false;

  @override
  void initState() {
    _getExpiryDate();
    // TODO: implement initState
    super.initState();
    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "stay_premium", screenClassOverride: "stay_premium");
    amplitudeAnalytics.logEvent("stay_premium_page");
  }

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    double mediaHeight = MediaQuery.of(context).size.height;
    return PlatformScaffold(
        backgroundColor: AppColors.blueColor,
        body: SafeArea(
            child: (this._loading)
                ? this._showLoading()
                : SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(children: <Widget>[
                          SizedBox(
                            height: mediaHeight * 0.1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: mediaWidth * 0.9,
                                child: Text(
                                  "${firstName},to get you to stay Premium we'd love to offer 50% off for 3 month of monthly subcription",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Your member will continue until\n it expires on ${expire}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: mediaWidth * 0.9,
                                child: Text(
                                  "Your card will not be recharged at the end of the membership period",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: mediaHeight * 0.2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: mediaWidth * 0.90,
                                height: 60,
                                child: PlatformButton(
                                  disabledColor: AppColors.greyColor,
                                  color: AppColors.redColor,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DiscountedPremium()));
                                  },
                                  child: Text(
                                    "Stay and get 50% off",
                                    style: TextStyle(
                                        color: AppColors.blueColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20),
                                  ),
                                  materialFlat: (_, __) =>
                                      MaterialFlatButtonData(
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
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: mediaWidth * 0.90,
                                height: 60,
                                child: PlatformButton(
                                  disabledColor: AppColors.greyColor,
                                  color: AppColors.redColor,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MembershipFeedback()));
                                  },
                                  child: Text(
                                    "Cancel Subscription",
                                    style: TextStyle(
                                        color: AppColors.redColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20),
                                  ),
                                  materialFlat: (_, __) =>
                                      MaterialFlatButtonData(
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
                            ],
                          )
                        ])))));
  }

  void _getExpiryDate() async {
    setState(() {
      _loading = true;
    });

    try {
      var res = await MyHttp.get("settings/member-status");
      if (res.statusCode == 200 || res.statusCode == 201) {
        var jsondata = jsonDecode(res.body);
        var plan = jsondata["plan"];
        var user = jsondata["user"];

        String expiration = plan["expiration"];
        firstName = user["first_name"];
        print(firstName);

        DateTime expiredDate = DateTime.parse(expiration);
        var formatter = new DateFormat('dd/MM/yyyy');
        expire = formatter.format(expiredDate);

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Container _showLoading() {
    return Container(
      height: double.infinity,
      child: Center(
        child: PlatformCircularProgressIndicator(),
      ),
    );
  }
}
