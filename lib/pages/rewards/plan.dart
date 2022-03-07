import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/premium_plan.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/rewards/selected_plan.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/shop/rewards_base.dart';
import 'package:sailor/sailor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes.dart';
import '../MyHttp.dart';

class Plan extends StatefulWidget {
  final bool isFromUserMatchPreferences;
  final Function succeedPurchase;
  Plan({Key key, this.isFromUserMatchPreferences, this.succeedPurchase})
      : super(key: key);

  @override
  _PlanState createState() => _PlanState();
}

class _PlanState extends State<Plan> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  PremiumPlan p;
  List<PremiumPlan> _plans = [];
  int i = 0;
  double mediaWidth;
  double mediaHeight;
  bool _loading = false;
  bool isCash = true;
  var balance = 0;
  @override
  void initState() {
    _getGemBalance();

    _getPlans();
    super.initState();
    //Analytics code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "premium_plan", screenClassOverride: "premium_plan");
    amplitudeAnalytics.logEvent("premium_plan_page");
  }

  void _getPlans() async {
    setState(() {
      _loading = true;
    });

    try {
      var res = await MyHttp.get("/shop/plans");
      if (res.statusCode == 200) {
        var jsonData = jsonDecode(res.body);
        print(jsonData);

        var plans = jsonData["premiumPlans"] as List;

        for (var p in plans) {
          var p1 = PremiumPlan.fromJson(p);
          _plans.add(p1);
        }

        print(_plans.length);
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print("Err $e");
    }
  }

  void _clickMenu() {
    isCash = !isCash;
    setState(() {});
  }

  void _getGemBalance() async {
    try {
      var res = await MyHttp.get("shop/gem-balance");
      if (res.statusCode == 200 || res.statusCode == 201) {
        var jsondata = jsonDecode(res.body);

        balance = jsondata["balance"];
        print("balance = $balance");
      }
      setState(() {});
    } catch (e) {}
  }

  void insufficientBalance(int dBalance, int currentBalance) {
    _alertUser(
        context,
        "Insufficient Balance",
        "You need ${dBalance} more gems to buy this\nitem.Your Current balance is ${currentBalance}.",
        "Add Gems");
  }

  _launchTermsURL() async {
    const url = 'https://purematch.co/terms-of-service/';
    launch(url);
  }

  _launchPrivacyURL() async {
    const url = 'https://purematch.co/privacy-policy/';
    launch(url);
  }

  void _alertUser(
      BuildContext context, String title, String content, String button) {
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
                  if (button == "Add Gems") {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => RewardsBase()));
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
              if (button == "Add Gems") {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RewardsBase()));
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
              //todo add analytics code here
            },
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    mediaWidth = MediaQuery.of(context).size.width;
    mediaHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: (this._loading)
            ? this._showLoading()
            : Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: Column(children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Image.asset(
                          isCash
                              ? "assets/images/img_spring2.png"
                              : "assets/images/img_spring.png",
                          width: double.infinity,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Text(
                                "Early-Bird Sale!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              !isCash
                                  ? "Over 60% OFF\nall subscriptions!"
                                  : "50% OFF\nall subscriptions!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                                color: AppColors.redColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: AppConfig.fullWidth(context),
                    height: 32,
                    color: AppColors.profileSecondHeaderColor,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            _clickMenu();
                          },
                          child: Container(
                            width: AppConfig.fullWidth(context) / 2,
                            height: 30,
                            decoration: (!isCash)
                                ? null
                                : BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: AppColors.tabBorderColor,
                                    ),
                                    borderRadius: BorderRadius.circular(7.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.tabShadowColor,
                                        blurRadius: 1.0, // soften the shadow
                                        spreadRadius: 1.0, //extend the shadow
                                        offset: Offset(
                                          0.0, // Move to right 10  horizontally
                                          1.0, // Move to bottom 10 Vertically
                                        ),
                                      )
                                    ],
                                  ),
                            child: Center(
                              child: Text(
                                "Cash",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _clickMenu();
                          },
                          child: Container(
                            width: AppConfig.fullWidth(context) / 2,
                            height: 30,
                            decoration: (isCash)
                                ? null
                                : BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: AppColors.tabBorderColor,
                                    ),
                                    borderRadius: BorderRadius.circular(7.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.tabShadowColor,
                                        blurRadius: 1.0, // soften the shadow
                                        spreadRadius: 1.0, //extend the shadow
                                        offset: Offset(
                                          0.0, // Move to right 10  horizontally
                                          1.0, // Move to bottom 10 Vertically
                                        ),
                                      )
                                    ],
                                  ),
                            // color: Colors.white,
                            child: Center(
                              child: Text(
                                "Pure Gems",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: !isCash,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: InkWell(
                        onTap: () {
                          Routes.sailor.navigate("/shop",
                              params: {
                                'tabIndex': 3,
                                'isShop': true,
                              },
                              navigationType: NavigationType.pushAndRemoveUntil,
                              removeUntilPredicate: (Route<dynamic> route) =>
                                  false);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Balance:",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.circular(16.0),
                                color: AppColors.offWhiteColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/images/gem_medium_icon.png",
                                      width: 20,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      balance.toString() ?? 1,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.only(top: 0),
                        itemCount: _plans.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          PremiumPlan plan = this._plans[index];
                          return allPlans(plan, index);
                        }),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 10.0, bottom: 10.0),
                      child: Wrap(
                        spacing: 0.0,
                        runSpacing: 2.0,
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "Billed as one payment. Recurring billing, cancel any time. ",
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: PlatformButton(
                      onPressed: () {
                        Navigator.pop(context);
                        //Analytics code
                        analytics.setCurrentScreen(
                            screenName: "manage_subscription",
                            screenClassOverride: "manage_subscription");
                        amplitudeAnalytics.logEvent("manage_subscription_page");
                      },
                      child: Text("Cancel",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize:
                                  AppConfig.fontsizeForSmallDevice(context, 20),
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackColor)),
                      materialFlat: (_, __) => MaterialFlatButtonData(
                        color: AppColors.blueColor,
                      ),
                    ),
                  )
                ]),
              ));
  }

  Widget allPlans(PremiumPlan plan, int index) {
    // List <Color> tmpColor =[AppColors.redColor, AppColors.noButtonColor, AppColors.noExplaintationBorderColor, AppColors.offWhiteColor] ;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
          height: 75,

          //color: AppColors.redColor,
          decoration: (plan.duration == "12 Months")
              ? new BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(18.0)))
              : (plan.duration == "6 Months")
                  ? new BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(18.0)))
                  : (plan.duration == "3 Months")
                      ? new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(18.0)))
                      : new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius:
                              BorderRadius.all(Radius.circular(18.0))),
          child: Row(
            children: <Widget>[
              Flexible(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(
                                (plan.duration == "12 Months")
                                    ? "12"
                                    : (plan.duration == "6 Months")
                                        ? "6"
                                        : (plan.duration == "3 Months")
                                            ? "3"
                                            : "1",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppConfig.fontsizeForSmallDevice(
                                      context, 22),
                                  color: AppColors.blackColor,
                                ),
                              ),
                              Text(
                                (plan.duration == "12 Months" ||
                                        plan.duration == "6 Months" ||
                                        plan.duration == "3 Months")
                                    ? " months"
                                    : " month",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppConfig.fontsizeForSmallDevice(
                                        context, 16),
                                    color: AppColors.blackColor),
                              ),
                            ],
                          ),
                          Container(
                            width: 100,
                            height: AppConfig.heightWithDForSmallDevice(
                                context, 20, 4),
                            decoration: new BoxDecoration(
                              boxShadow: ((plan.duration == "12 Months" ||
                                      plan.duration == "6 Months"))
                                  ? [
                                      BoxShadow(
                                        color: Colors.black,
                                        blurRadius: 0.5,
                                        spreadRadius: 0.0,
                                        offset: Offset(0.5,
                                            0.5), // shadow direction: bottom right
                                      )
                                    ]
                                  : null,
                              color: (plan.duration == "12 Months")
                                  ? AppColors.matchBrowseMatchReactivateMatching
                                  : Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: Text(
                              (plan.duration == "12 Months")
                                  ? "Best Deal!"
                                  : (plan.duration == "6 Months")
                                      ? "Good Value"
                                      : "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: (plan.duration == "12 Months")
                                    ? Colors.white
                                    : (plan.duration == "6 Months")
                                        ? AppColors
                                            .matchBrowseMatchReactivateMatching
                                        : (plan.duration == "3 Months")
                                            ? Colors.white
                                            : AppColors.redColor,
                                fontWeight: FontWeight.w600,
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 14, 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
              Flexible(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            isCash
                                ? plan.duration == "1 Month"
                                    ? "\$29.99"
                                    : plan.duration == "3 Months"
                                        ? "\$74.99"
                                        : plan.duration == "6 Months"
                                            ? "\$119.99"
                                            : "\$179.99"
                                : plan.duration == "1 Month"
                                    ? "1000 Gems"
                                    : plan.duration == "3 Months"
                                        ? "2500 Gems"
                                        : plan.duration == "6 Months"
                                            ? "4000 Gems"
                                            : "6000 Gems",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: AppConfig.fontsizeForSmallDevice(
                                    context, 18),
                                color: AppColors.offWhiteColor,
                                decoration: TextDecoration.lineThrough),
                          ),
                          Visibility(
                            visible: isCash,
                            child: Row(
                              children: [
                                Text(
                                  (plan.duration == "1 Month")
                                      ? "\$" + plan.dollar_cost.toString()
                                      : (plan.duration == "3 Months")
                                          ? "\$" + plan.dollar_cost.toString()
                                          : (plan.duration == "6 Months")
                                              ? "\$" +
                                                  plan.dollar_cost.toString()
                                              : "\$" +
                                                  plan.dollar_cost.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          AppConfig.fontsizeForSmallDevice(
                                              context, 22),
                                      color: (plan.duration == "12 Months" ||
                                              plan.duration == "6 Months")
                                          ? AppColors.redColor
                                          : AppColors.blackColor),
                                ),
                                Text(
                                  (plan.duration == "1 Month")
                                      ? " (" +
                                          "\$" +
                                          plan.dollar_cost.toString() +
                                          "/mo" +
                                          ")"
                                      : (plan.duration == "3 Months")
                                          ? " (" +
                                              "\$" +
                                              Global.getNumber(
                                                      plan.dollar_cost / 3,
                                                      precision: 2)
                                                  .toString() +
                                              "/mo" +
                                              ")"
                                          : (plan.duration == "6 Months")
                                              ? " (" +
                                                  "\$" +
                                                  Global.getNumber(
                                                          plan.dollar_cost / 6,
                                                          precision: 2)
                                                      .toString() +
                                                  "/mo" +
                                                  ")"
                                              : " (" +
                                                  "\$" +
                                                  Global.getNumber(
                                                          plan.dollar_cost / 12,
                                                          precision: 2)
                                                      .toString() +
                                                  "/mo" +
                                                  ")",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          AppConfig.fontsizeForSmallDevice(
                                              context, 14),
                                      color: (plan.duration == "12 Months" ||
                                              plan.duration == "6 Months")
                                          ? AppColors.redColor
                                          : AppColors.blackColor),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: !isCash,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  plan.gem_cost.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          AppConfig.fontsizeForSmallDevice(
                                              context, 22),
                                      color: (plan.duration == "12 Months" ||
                                              plan.duration == "6 Months")
                                          ? AppColors.redColor
                                          : AppColors.blackColor),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Image.asset(
                                  "assets/images/gem_medium_icon.png",
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: AppConfig.heightWithDForSmallDevice(
                                context, 5, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Visibility(
                      // visible: !(isFeburary || isApril),
                      visible: false,
                      child: Container(
                        child: Image.asset("assets/images/separator_img.png",
                            color: AppColors.greyColor),
                        width: 2,
                        height: 67,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 15,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SelectedPlan(
                                  plan: plan,
                                  isCash: isCash,
                                  insufficientBalance: insufficientBalance,
                                ),
                              ));
                            },
                            child: Text(
                              "Select",
                              style: TextStyle(
                                  fontSize: 22,
                                  color: AppColors.blueColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            height: AppConfig.heightWithDForSmallDevice(
                                context, 5, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
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
