import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/premium_plan.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/rewards/premium_welcome.dart';
import 'package:pure_match/pages/shop/rewards_base.dart';

import '../MyHttp.dart';
import 'package:intl/intl.dart';

class DiscountedPremium extends StatefulWidget {
  @override
  _DiscountedPremiumState createState() => _DiscountedPremiumState();
}

class _DiscountedPremiumState extends State<DiscountedPremium> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String expire;
  PremiumPlan p;
  int balance;
  bool _loading = false;

  @override
  void initState() {
    _getDiscountedOffer();
    _getGemBalance();
    // TODO: implement initState
    super.initState();
    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "discount_premium_offer",
        screenClassOverride: "discount_premium_offer");
    amplitudeAnalytics.logEvent("discount_premium_offer_page");
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        appBar: PlatformAppBar(
          material: (_, __) => MaterialAppBarData(
            backgroundColor: AppColors.blueColor,
            elevation: 0.0,
            leading: MaterialButton(
              onPressed: () {},
              child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    //Analytics tracking code
                    analytics.setCurrentScreen(
                        screenName: "stay_premium",
                        screenClassOverride: "stay_premium");
                    amplitudeAnalytics.logEvent("stay_premium_page");
                  }),
            ),
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
            automaticallyImplyLeading: false,
            automaticallyImplyMiddle: false,
            backgroundColor: AppColors.blueColor,
            leading: MaterialButton(
              onPressed: () {},
              child: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                  onPressed: () {
                    //Analytics tacking code
                    analytics.setCurrentScreen(
                        screenName: "stay_premium",
                        screenClassOverride: "stay_premium");
                    amplitudeAnalytics.logEvent("stay_premium_page");
                  }),
            ),
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
          ),
        ),
        backgroundColor: AppColors.blueColor,
        body: SafeArea(
            child: (this._loading)
                ? this._showLoading()
                : SingleChildScrollView(
                    child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: 20.0, //consider using 10
                        ),

                        Text(
                          "Selected Plan",
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 50.0),
                          child: Text(
                            "Pure Match Premium \n${p.duration}@ \$ ${p.dollar_cost}/month (50% OFF). \nRenews automatically on ${expire}",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal),
                            textAlign: TextAlign.left,
                          ),
                        ), // have a function that will return the right thing depending on users subscription
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Benefits",
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Global.premiumTexts(
                          context,
                          Colors.white,
                          AppConfig.fontsizeForSmallDevice(context, 18),
                        ),

                        SizedBox(height: 10.0),
                        Text(
                          "Payment",
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal),
                        ),
                        SizedBox(height: 20.0),
                        Column(
                          children: <Widget>[
                            PlatformButton(
                              padding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 47.0),
                              color: Color.fromRGBO(0, 186, 132, 1),
                              onPressed: () {
                                _alertUser(
                                    context,
                                    "Confirm Purchase",
                                    "Unlock ${p.duration} of Pure Match Premium for ${p.gem_cost} Pure Gems?",
                                    "Unlock",
                                    p);
                              },
                              materialFlat: (_, __) => MaterialFlatButtonData(
                                child: Text(
                                  "Suscribe with Pure Gems",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontStyle: FontStyle.normal),
                                ),
                              ),
                              cupertinoFilled: (_, __) =>
                                  CupertinoFilledButtonData(
                                child: Text(
                                  "Suscribe with Pure Gems",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontStyle: FontStyle.normal),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            PlatformButton(
                              padding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 75.0),
                              color: Colors.white,
                              onPressed: () {
                                //Analytics tracking code
                                analytics.setCurrentScreen(
                                    screenName: "in_app_payment",
                                    screenClassOverride: "in_app_payment");
                                amplitudeAnalytics
                                    .logEvent("in_app_payment_page");

                                _purchaseUsingCash(p);
                              },
                              materialFlat: (_, __) => MaterialFlatButtonData(
                                child: Text(
                                  "Suscribe with Pay",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.blackColor,
                                      fontStyle: FontStyle.normal),
                                ),
                              ),
                              cupertinoFilled: (_, __) =>
                                  CupertinoFilledButtonData(
                                child: Text(
                                  "Suscribe with Pay",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.blackColor,
                                      fontStyle: FontStyle.normal),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ))));
  }

  void _getDiscountedOffer() async {
    setState(() {
      _loading = true;
    });

    try {
      var res = await MyHttp.get("settings/discounted-sub");
      if (res.statusCode == 200 || res.statusCode == 201) {
        var jsondata = jsonDecode(res.body);
        var plan = jsondata["plan"];
        var discountedPlan = jsondata["discountPlan"];
        p = PremiumPlan.fromJson(discountedPlan);
        print(p);

        String expiration = plan["expiration"];

        DateTime expiredDate = DateTime.parse(expiration);
        var formatter = new DateFormat('dd/MM/yyyy');
        expire = formatter.format(expiredDate);
        print(expire);

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {}
  }

  void _alertUser(BuildContext context, String title, String content,
      String button, PremiumPlan p) {
    showDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: Text(content,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
        material: (_, __) => MaterialAlertDialogData(
          elevation: 1.0,
          actions: <Widget>[
            FlatButton(
                child: Text(button,
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsBlueColor,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  print(button);
                  if (button == "Unlock") {
                    print("reached");
                    _purchaseUsingGems(p);
                  } else if (button == "Add Gems") {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => RewardsBase()));
                    //Analytics code

                    analytics.setCurrentScreen(
                        screenName: "rewards_awards",
                        screenClassOverride: "rewards_awards");
                    amplitudeAnalytics.logEvent("rewards_awards_page");
                  }
                }),
            FlatButton(
                child: Text("Cancel",
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsRedColor,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  // Update user model is friend request sent successfully
                  Navigator.of(context).pop();
                }),
          ],
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
          CupertinoButton(
            child: Text(button,
                style: TextStyle(
                    color: AppColors.communityProfileOptionsBlueColor,
                    fontWeight: FontWeight.w600)),
            onPressed: () {
              print(button);
              if (button == "Unlock") {
                Navigator.of(context).pop();
                _purchaseUsingGems(p);
              } else if (button == "Add Gems") {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RewardsBase()));
                //Analytics code
                analytics.setCurrentScreen(
                    screenName: "rewards_awards",
                    screenClassOverride: "rewards_awards");
                amplitudeAnalytics.logEvent("rewards_awards_page");
              }
            },
          ),
          CupertinoButton(
            child: Text("Cancel",
                style: TextStyle(
                    color: AppColors.communityProfileOptionsRedColor,
                    fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {});
  }

  void _purchaseUsingGems(PremiumPlan p) async {
    try {
      var res = await MyHttp.post("shop/purchase/${p.item_id}/premium/gem", {});
      if (res.statusCode == 201 || res.statusCode == 200) {
        // Analytics tracking code
        analytics.logEvent(name: "pg_purchase", parameters: <String, dynamic>{
          "item": p.type,
          "amount": p.dollar_cost.toString()
        });
        amplitudeAnalytics.logRevenue(p.type, 1, p.dollar_cost.toDouble());

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => PremiumWelcome()));
        setState(() {});
      } else if (res.statusCode == 403) {
        _alertUser(
            context,
            "Insufficient Balance",
            "You need ${p.gem_cost - balance} more gems to buy this\nitem.Your Current balance is ${balance}.",
            "Add Gems",
            p);
      }
    } catch (e) {
      print("Err $e");
    }
  }

  void _getGemBalance() async {
    try {
      var res = await MyHttp.get("shop/gem-balance");
      if (res.statusCode == 200 || res.statusCode == 201) {
        var jsondata = jsonDecode(res.body);
        balance = jsondata["balance"];
        print(balance);
      }
    } catch (e) {}
  }

  void _purchaseUsingCash(PremiumPlan p) async {
    try {
      var res =
          await MyHttp.post("shop/purchase/${p.item_id}/premium/cash", {});
      if (res.statusCode == 201 || res.statusCode == 200) {
        //Analytics tracking code
        analytics.logEvent(name: "iap_purchase", parameters: <String, dynamic>{
          "item": p.type,
          "amount": p.dollar_cost.toString()
        });
        amplitudeAnalytics.logEvent('iap_purchase', eventProperties: {
          "item": p.type,
          "amount": p.dollar_cost.toString()
        });

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => PremiumWelcome()));

        setState(() {});
      } else {
        print(res.statusCode);
      }
    } catch (e) {
      print("Err $e");
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
