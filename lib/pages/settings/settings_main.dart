import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/loading.dart';
import 'package:pure_match/common/snackbar.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/onboarding/profile_info/user_dating_preference.dart';
import 'package:pure_match/pages/own_profile/my_profile.dart';
import 'package:pure_match/pages/rewards/plan.dart';
import 'package:pure_match/pages/settings/help_center.dart';
import 'package:pure_match/pages/settings/notifications.dart';
import 'package:pure_match/pages/settings/privacy_settings.dart';
import 'package:pure_match/pages/settings/account_settings/account_settings.dart';
import 'package:pure_match/pages/settings/admin_tools/admin_navigator.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/shop/rewards_base.dart';
import 'package:sailor/sailor.dart';
import 'dart:convert';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplitude_flutter/amplitude.dart';

import '../../routes.dart';

class MainSettings extends StatefulWidget {
  final int userId;
  final bool isFromPremiumWelcome;
  const MainSettings({Key key, this.userId, this.isFromPremiumWelcome = false})
      : super(key: key);

  @override
  _MainSettingsState createState() => _MainSettingsState();
}

class _MainSettingsState extends State<MainSettings> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int i = 0;
  bool isChangedMatchPreferences = false;
  bool isAdmin = false;
  List<dynamic> tabs;

  bool status;
  bool currentUser = true;
  bool loading = false;

  void onLogoutClick() {
    Global.alertUser(
        context,
        Text("Confirm",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        Text("Are you sure you want to log out?",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            )),
        Text("Cancel",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Colors.black)),
        () {
          Navigator.of(context).pop();
        },
        Text("Log Out",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        () async {
          var sp = await SharedPreferences.getInstance();
          int id = sp.getInt("id");
          var data = {
            "device_id": id,
          };

          var res = await MyHttp.put("logout", data);
          if (res.statusCode == 200) {
            sp.remove("token");
            sp.remove("id");
            //Analytic tracking code
            analytics.logEvent(name: "logged_out");
            amplitudeAnalytics.logEvent("logged_out");

            Routes.sailor.navigate("/main",
                navigationType: NavigationType.pushAndRemoveUntil,
                removeUntilPredicate: (Route<dynamic> route) => false);
          } else {
            print("User update error: ${res.statusCode}");
            print("User update error: ${res.body}");
          }
        });
  }

  checkAdmin() async {
    try {
      var res = await MyHttp.get("/admin/check-admin");
      print(res.statusCode);
      print("NOTI");
      print(res.body);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        isAdmin = body["isAdmin"] ?? false;
      }

      if (this.mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Get dat aerr: $e");
    }
  }

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
      // var res = await MyHttp.get("users/user/$id");

      var res2 = await MyHttp.get("/settings/member-status");
      // var json = jsonDecode(res.body);
      var json2 = jsonDecode(res2.body);
      status = json2["success"];
      if (status == true) Global.isPremium = true;
      setState(() {});
    } catch (e) {
      print(e);
    }
    setState(() {
      loading = false;
    });
  }

  // _launchURL() async {
  //   const url = 'http://www.purematch.co/app-help-center';
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw "Couldn't launch URL";
  //   }
  // }

  void onSaveMatchPreferences() {
    Timer(Duration(milliseconds: 300), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarUi.SuccessSnackBar(message: "Match preferences are saved!")
      );
    }); 
    isChangedMatchPreferences = true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAdmin();
    _getStatus();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "settings", screenClassOverride: "settings");
    amplitudeAnalytics.logEvent("settings_page");
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    return PlatformScaffold(
        backgroundColor: Colors.white,
        //bottomNavBar: HomePage(),
        appBar: PlatformAppBar(
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PlatformIconButton(
                onPressed: () {
                  if (widget.isFromPremiumWelcome) {
                    Routes.sailor.navigate("/homes",
                        params: {
                          'tabIndex': 0,
                        },
                        navigationType: NavigationType.pushReplace,
                        removeUntilPredicate: (Route<dynamic> route) => true);
                  } else {
                    Navigator.pop(context, isChangedMatchPreferences);
                  }
                },
                icon: Icon(
                  CupertinoIcons.left_chevron,
                  color: Colors.white,
                ),
                padding: EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
              )
            ],
          ),
          material: (_, __) => MaterialAppBarData(
            backgroundColor: AppColors.offWhiteColor,
            elevation: 0.0,
            title: Text(
              "Settings",
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal),
            ),
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
            brightness: Brightness.dark,
            backgroundColor: AppColors.offWhiteColor,
            title: Text(
              "Settings",
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal),
            ),
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
          ),
        ),
        body: SafeArea(
          child: (this.loading)
              ? Loading.showLoading()
              : Scaffold(
                  backgroundColor: Colors.white,
                  body: SingleChildScrollView(
                    child: IntrinsicHeight(
                      child: Column(
                        children: <Widget>[
                          Visibility(
                            visible: !Global.isPremium,
                            child: Expanded(
                              flex: 2,
                              child: Container(
                                color: Color.fromRGBO(115, 190, 255, 1),
                                padding: EdgeInsets.all(4.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Sign Up for \n Pure Match Premium!",
                                      style: TextStyle(
                                          shadows: [
                                            Shadow(
                                                blurRadius: 3.0,
                                                color: Colors.grey.shade600,
                                                offset: Offset(1.0, 2.0))
                                          ],
                                          fontSize: 36,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Get unlimited messages with Matches, \n FREE Profile Boosts, and more!",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: RaisedButton(
                                        elevation: 10.0,
                                        highlightElevation: 10.0,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 40.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Plan()));
                                        },
                                        color: Colors.white,
                                        child: Text(
                                          "Upgrade",
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade200))),
                              padding: const EdgeInsetsDirectional.only(
                                  start: 0.0, end: 5.0, top: 5.0, bottom: 5.0),
                              alignment: Alignment.center,
                              child: Column(
                                children: <Widget>[
                                  Visibility(
                                    visible: widget.isFromPremiumWelcome,
                                    child: Container(
                                      width: AppConfig.fullWidth(context),
                                      height: 80,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 7),
                                            child: FittedBox(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    "assets/images/Premium_Crown.png",
                                                    width: 75,
                                                    height: 30,
                                                  ),
                                                  SizedBox(
                                                    width: 7,
                                                  ),
                                                  Text(
                                                    "Premium Member since " +
                                                        (today.month)
                                                            .toString() +
                                                        "/" +
                                                        (today.day).toString() +
                                                        "/" +
                                                        (today.year).toString(),
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .blackColor,
                                                        fontSize: 20),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: widget.isFromPremiumWelcome,
                                    child: Divider(
                                      thickness: 2,
                                      height: 3,
                                      color: Colors.grey.shade100,
                                    ),
                                  ),
                                  MyButtons.getSettingsButton(
                                      "assets/images/icon_rewards.png",
                                      "Rewards/Shop", () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RewardsBase()));
                                  }),
                                  Divider(
                                    thickness: 2,
                                    height: 3,
                                    color: Colors.grey.shade100,
                                  ),
                                  MyButtons.getSettingsButton(
                                      "assets/images/icon_profile.png",
                                      "My Profile", () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyProfile(),
                                      ),
                                    );
                                  }),
                                  Divider(
                                    thickness: 2,
                                    height: 3,
                                    color: Colors.grey.shade100,
                                  ),
                                  MyButtons.getSettingsButton(
                                      "assets/images/icon_dating.png",
                                      "Match Preferences", () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UserDatingPreference(
                                                  userDatingPreferencesPageType:
                                                      UserDatingPreferencesPageType
                                                          .SETTINGS,
                                                  onSaveContinue:
                                                      onSaveMatchPreferences,
                                                )));
                                  }),
                                  Divider(
                                    thickness: 2,
                                    height: 3,
                                    color: Colors.grey.shade100,
                                  ),
                                  MyButtons.getSettingsButton(
                                      "assets/images/icon_notifcation.png",
                                      "Notifications", () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationSettings(),
                                      ),
                                    );
                                    //Analytics tracking code
                                    analytics.setCurrentScreen(
                                        screenName: "notification_settings",
                                        screenClassOverride:
                                            "notification_settings");
                                    amplitudeAnalytics
                                        .logEvent("notification_settings_page");
                                  }),
                                  Divider(
                                    thickness: 2,
                                    height: 3,
                                    color: Colors.grey.shade100,
                                  ),
                                  MyButtons.getSettingsButton(
                                      "assets/images/icon_settings.png",
                                      "Privacy Settings", () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PrivacySettings(),
                                      ),
                                    );
                                    //analytics tracking code
                                    analytics.setCurrentScreen(
                                        screenName: "privacy_settings",
                                        screenClassOverride:
                                            "privacy_settings");
                                    amplitudeAnalytics
                                        .logEvent("privacy_settings_page");
                                  }),
                                  Divider(
                                    thickness: 2,
                                    height: 3,
                                    color: Colors.grey.shade100,
                                  ),
                                  MyButtons.getSettingsButton(
                                      "assets/images/icon_settings.png",
                                      "Account Settings", () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AccountSettings(),
                                      ),
                                    );
                                    //Analytics tracking code
                                    analytics.setCurrentScreen(
                                        screenName: "account_settings",
                                        screenClassOverride:
                                            "account_settings");
                                    amplitudeAnalytics
                                        .logEvent("account_settings_page");
                                  }),
                                  Divider(
                                    thickness: 2,
                                    height: 3,
                                    color: Colors.grey.shade100,
                                  ),
                                  MyButtons.getSettingsButton(
                                      "assets/images/icon_help.png",
                                      "Help Center", () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => HelpCenter()));
                                    //Analytics tracking code
                                    analytics.setCurrentScreen(
                                        screenName: "help_center",
                                        screenClassOverride: "help_center");
                                    amplitudeAnalytics
                                        .logEvent("help_center_page");
                                  }),
                                  Visibility(
                                    visible: isAdmin,
                                    child: Divider(
                                      thickness: 2,
                                      height: 3,
                                      color: Colors.grey.shade100,
                                    ),
                                  ),
                                  Visibility(
                                    visible: isAdmin,
                                    child: MyButtons.getSettingsButton(
                                        "assets/images/icon_help.png",
                                        "Admin Tools", () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AdminNavigator(
                                                    index: 0,
                                                  )));
                                    }),
                                  ),
                                  Divider(
                                    thickness: 2,
                                    height: 3,
                                    color: Colors.grey.shade100,
                                  ),
                                  MyButtons.getSettingsButton(
                                      "assets/images/icon_logout.png", "Logout",
                                      () {
                                    onLogoutClick();
                                  }),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: Global.isPremium,
                            child: Expanded(
                              child: Container(),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: AppColors.blueColor,
                              padding: EdgeInsetsDirectional.only(
                                  start: 25.0, end: 5.0),
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 88,
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                      height: 55,
                                      width: 120,
                                      child: RaisedButton(
                                        elevation: 10.0,
                                        highlightElevation: 10.0,
                                        color: Colors.white,
                                        disabledColor: Colors.white,
                                        onPressed: () {
                                          //Analytics tracking code
                                          analytics.setCurrentScreen(
                                              screenName: "send_an_invite",
                                              screenClassOverride:
                                                  "send_an_invite");
                                          amplitudeAnalytics
                                              .logEvent("send_an_invite_page");
                                          Share.share(
                                              'Hey! Check out this free new app where single disciples can connect, date, and socialize! It\'s awesome! www.PureMatch.co/apps',
                                              subject: 'Pure Match App');
                                          // if (Platform.isAndroid) {
                                          //   Share.share(
                                          //       'https://play.google.com/store/apps/details?id=org.purematch.purematch',
                                          //       subject:
                                          //           'Find Love on Pure Match');
                                          // } else {
                                          //   Share.share(
                                          //       'https://apps.apple.com/br/app/pure-match/id1506240839',
                                          //       subject:
                                          //           'Find Love on Pure Match');
                                          // }
                                        },
                                        //onPressed: () => Share.share('Hi! Do check out this awesome app Pure Match!', subject: '$user.firstname $user.last name invited you to try Pure Match!'),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Text(
                                          "Share",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                        child: Text(
                                            "Share Pure Match with your friends & family!",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                            )))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ));
  }
}
