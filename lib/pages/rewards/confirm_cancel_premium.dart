import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/rewards/membership_feedback.dart';
import 'package:amplitude_flutter/amplitude.dart';

import '../AppColors.dart';
import '../MyHttp.dart';
import 'package:intl/intl.dart';

class ConfirmCancel extends StatefulWidget {
  @override
  _ConfirmCancelState createState() => _ConfirmCancelState();
}

class _ConfirmCancelState extends State<ConfirmCancel> {
  String expire = "";
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  bool _loading = false;

  @override
  void initState() {
    _getExpiryDate();
    super.initState();
    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "confirm_cancel_premium",
        screenClassOverride: "confirm_cancel_premium");
    amplitudeAnalytics.logEvent("confirm_cancel_premium_page");
  }

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    double mediaHeight = MediaQuery.of(context).size.height;
    print(mediaWidth);
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
                              Text(
                                "Are you sure you\nwant to cancel your\nPremium membership",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: mediaHeight * 0.05,
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
                            height: mediaHeight * 0.05,
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
                          Container(
                            width: mediaWidth * 0.90,
                            height: 60,
                            //padding: EdgeInsets.only(left: 5, right: 5),
                            child: PlatformButton(
                              disabledColor: AppColors.greyColor,
                              color: AppColors.redColor,
                              onPressed: () {
                                // Navigator.of(context).push(MaterialPageRoute(
                                //     builder: (context) =>
                                //         ManageSubscription()));
                                Navigator.of(context).pop();
                                //Analytics code
                                analytics.setCurrentScreen(
                                    screenName: "manage_subscription",
                                    screenClassOverride: "manage_subscription");
                                amplitudeAnalytics
                                    .logEvent("manage_subscription_page");
                              },
                              padding: EdgeInsets.all(0),
                              child: FittedBox(
                                child: Text(
                                  "Keep my Premium Membership",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: AppColors.blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: (mediaWidth > 375) ? 20 : 16),
                                ),
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
    try {
      setState(() {
        _loading = true;
      });
      var res = await MyHttp.get("settings/member-status");
      if (res.statusCode == 200 || res.statusCode == 201) {
        var jsondata = jsonDecode(res.body);
        var plan = jsondata["plan"];
        String expiration = plan["expiration"];

        DateTime expiredDate = DateTime.parse(expiration);
        var formatter = new DateFormat('dd/MM/yyyy');
        expire = formatter.format(expiredDate);
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {}
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
