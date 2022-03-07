import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/rewards/plan.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

import '../AppColors.dart';
import '../MyHttp.dart';
import 'package:intl/intl.dart';

class PremiumExpireWarning extends StatefulWidget {
  @override
  _PremiumExpireWarningState createState() => _PremiumExpireWarningState();
}

class _PremiumExpireWarningState extends State<PremiumExpireWarning> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String expire;
  String firstName;

  @override
  void initState() {
    _getExpiryDate();
    super.initState();
    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "premium_expire_warning",
        screenClassOverride: "premium_expire_warnng");
    amplitudeAnalytics.logEvent("premium_expire_warning_page");
  }

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      backgroundColor: AppColors.greyColor,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 60, horizontal: 10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 10.0,
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.blueColor,
                    borderRadius: BorderRadius.circular(10)),
                height: 430,
                width: mediaWidth * 0.9,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Don't lose your \nPremium benefits!😱",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "${firstName},your Premium Membership is \nset to expire on ${expire}.Renew now\nto keep enjoying premium \nbenefits like",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Column(
                          children: <Widget>[
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "• Unlimited match filtering📏📐",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: Colors.white),
                                  ),
                                ]),
                            Row(
                              children: <Widget>[
                                Text(
                                  "• Seeing who likes/views you👀😄",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  "• and invisible mode!🙈🙈",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 18,
                            ),
                            Center(
                              child: SizedBox(
                                width: mediaWidth * 0.90,
                                height: 60,
                                child: PlatformButton(
                                  disabledColor: AppColors.greyColor,
                                  color: AppColors.redColor,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Plan()));
                                  },
                                  child: Text(
                                    "RENEW NOW!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors
                                            .matchBrowseMatchReactivateMatching,
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
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: SizedBox(
                                width: mediaWidth * 0.90,
                                height: 60,
                                child: PlatformButton(
                                  disabledColor: AppColors.greyColor,
                                  color: AppColors.redColor,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => PlatformAlertDialog(
                                        title: Text(
                                            "Your Premium Membership \nExpires in 7 days",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600)),
                                        content: Text(
                                            "You will no longer be able to enjoy\nPremium benefits if you don't renew\nafter the subscription period",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                        material: (_, __) =>
                                            MaterialAlertDialogData(
                                          elevation: 1.0,
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("OK",
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .communityProfileOptionsBlueColor,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              onPressed: () {
                                                // Update user model is friend request sent successfully

                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            FlatButton(
                                              child: Text("Renew",
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .communityProfileOptionsBlueColor,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              onPressed: () {
                                                // Update user model is friend request sent successfully

                                                Navigator.of(context).pop();
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Plan()));
                                              },
                                            ),
                                          ],
                                        ),
                                        cupertino: (_, __) =>
                                            CupertinoAlertDialogData(
                                                actions: <Widget>[
                                              CupertinoButton(
                                                child: Text("Close",
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .communityProfileOptionsBlueColor,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              CupertinoButton(
                                                child: Text("Renew",
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .communityProfileOptionsBlueColor,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Plan()));
                                                },
                                              ),
                                            ]),
                                      ),
                                      barrierDismissible: true,
                                    ).then((value) {});
                                  },
                                  child: Text(
                                    "No Thanks",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey[500],
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
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _getExpiryDate() async {
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

        setState(() {});
      }
    } catch (e) {}
  }
}
