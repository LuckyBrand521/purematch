import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/pages/rewards/confirm_cancel_premium.dart';
import 'package:pure_match/pages/rewards/plan.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

class ManageSubscription extends StatefulWidget {
  final int userId;

  const ManageSubscription({Key key, this.userId}) : super(key: key);

  @override
  _ManageSubscriptionState createState() => _ManageSubscriptionState();
}

class _ManageSubscriptionState extends State<ManageSubscription> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  bool status;
  Map<String, dynamic> selectedPlan1;
  String price1;
  bool currentUser = true;
  bool loading = false;

  Future<String> _getStatus() async {
    setState(() {
      loading = true;
    });
    var sp = await SharedPreferences.getInstance();
    int id = sp.getInt("id");
    print(id);
    if (widget.userId != null) {
      if (widget.userId != id) {
        currentUser = false;
        id = widget.userId;
      }
    }
    try {
      var res2 = await MyHttp.get("/settings/member-status");
      // var json = jsonDecode(res.body);
      var json2 = jsonDecode(res2.body);
      status = json2["success"];
      if (status == true) {
        Global.isPremium = true;

        selectedPlan1 = json2["plan"] as Map<String, dynamic>;
        price1 = json2["monthly"];
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
    print(id);
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getFeatures();
  }

  void _getFeatures() async {
    await _getStatus();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Colors.white,
      //bottomNavBar: HomePage(),
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: AppColors.offWhiteColor,
          elevation: 0.0,
          leading: MaterialButton(
            onPressed: () {},
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => AccountSettings()));
                //Analytics tracking code
                analytics.setCurrentScreen(
                    screenName: "account_settings",
                    screenClassOverride: "account_settings");
                amplitudeAnalytics.logEvent("account_settings_page");
              },
            ),
          ),
          title: Text(
            "Manage Subscription",
            style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal),
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          automaticallyImplyLeading: false,
          automaticallyImplyMiddle: false,
          backgroundColor: AppColors.offWhiteColor,
          leading: MaterialButton(
            onPressed: () {},
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => AccountSettings()));
                //Analytics tracking code
                analytics.setCurrentScreen(
                    screenName: "account_settings",
                    screenClassOverride: "account_settings");
                amplitudeAnalytics.logEvent("account_settings_page");
              },
            ),
          ),
          title: Text(
            "Manage Subscription",
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal),
          ),
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
        ),
      ),
      body: (loading)
          ? Center(child: PlatformCircularProgressIndicator())
          : SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Container(
                  padding: EdgeInsets.only(left: 10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: 20.0, //consider using 10
                        ),
                        Text(
                          "Current Plan",
                          style: TextStyle(
                              fontSize: 20,
                              color: AppColors.blueColor,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            usersPlan(Global.isPremium),
                            style: TextStyle(
                                fontSize: 20,
                                color: AppColors.blueColor,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        // have a function that will return the right thing depending on users subscription
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          benefitsHeader(Global.isPremium),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Global.premiumTexts(
                          context,
                          Colors.black,
                          AppConfig.fontsizeForSmallDevice(context, 18),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: bottomButtons(Global.isPremium),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  String usersPlan(bool prem) {
    if (!prem) {
      return "Pure Match Free";
    } else {
      String expiration = selectedPlan1['expiration'];
      bool auto_renew = selectedPlan1['auto_renew'];
      DateTime expiredDate = DateTime.parse(expiration);
      var formatter = new DateFormat.yMEd();
      String expire = formatter.format(expiredDate);
      String rtrString = auto_renew
          ? "Pure Match Premium \n${price1} \nRenews automatically on ${expire}"
          : "Pure Match Premium \n${price1} \nExpires on ${expire}";

      return rtrString;
    }
  }

  String benefitsHeader(bool prem) {
    if (!prem) {
      return "Upgrade to get these Benefits";
    } else {
      return "Benefits";
    }
  }

  void _cancelSubscriptionAlert() {
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("To cancel your subscription"),
              content: Text(
                "Please go to your phone Settings, tap your name, then Subscriptions.  Click on the Pure Match app, then choose \"Cancel Subscription\" and follow the instructions.",
                style: TextStyle(height: 1.5),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Got it!",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  ),
                )
              ],
            );
          });
    } else {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("To cancel your subscription"),
              content: Text(
                "Please go to your Google Play app subscriptions screen, select the Pure Match app, and tap Cancel Subscription, then follow the instructions.",
                style: TextStyle(height: 1.5),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Got it!",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  ),
                )
              ],
            );
          });
    }
  }

  Widget bottomButtons(bool prem) {
    if (!prem) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child: PlatformButton(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          color: AppColors.blueColor,
          onPressed: () {},
          materialFlat: (_, __) => MaterialFlatButtonData(
            child: Text(
              "Upgrade to Premium",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal),
            ),
          ),
          cupertino: (_, __) => CupertinoButtonData(
            child: Text(
              "Upgrade to Premium",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal),
            ),
          ),
        ),
      );
    } else {
      return Column(
        children: <Widget>[
          PlatformButton(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 75.0),
            color: AppColors.blueColor,
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Plan()));
            },
            materialFlat: (_, __) => MaterialFlatButtonData(
              child: Text(
                "Change Subscription",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal),
              ),
            ),
            cupertino: (_, __) => CupertinoButtonData(
              child: Text(
                "Change Subscription",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal),
              ),
            ),
          ),
          PlatformButton(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            color: Colors.white,
            onPressed: () {
              //Navigator.push(context,MaterialPageRoute(builder: (context) => ConfirmCancel()));
              _cancelSubscriptionAlert();
            },
            materialFlat: (_, __) => MaterialFlatButtonData(
              child: Text(
                "Cancel Subscription",
                style: TextStyle(
                    fontSize: 20,
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal),
              ),
            ),
            cupertino: (_, __) => CupertinoButtonData(
              child: Text(
                "Cancel Subscription",
                style: TextStyle(
                    fontSize: 20,
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal),
              ),
            ),
          ),
        ],
      );
    }
  }
}
