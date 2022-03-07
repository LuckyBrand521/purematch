import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/loading.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'dart:io' show Platform;

class NotificationSettings extends StatefulWidget {
  final int userId;

  const NotificationSettings({Key key, this.userId}) : super(key: key);

  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  var json;
  Map<String, dynamic> pushSettings;
  Map<String, dynamic> emailSettings;
  bool calledBefore = false;
  bool status = false;
  bool currentUser = true;
  bool isIOS = Platform.isIOS;
  bool loading = false;

  Future<String> _getStatus() async {
    var sp = await SharedPreferences.getInstance();
    int id = sp.getInt("id");
    //int id = 53;
    print(id);
    if (widget.userId != null) {
      if (widget.userId != id) {
        currentUser = false;
        id = widget.userId;
      }
    }
    try {
      // var res = await MyHttp.get("users/user/$id");
      // var res2 = await MyHttp.get("users/uploads");
      // var json = jsonDecode(res.body);
      // status = json["user"]["status"];
      // if (status == "premium") {
      //   premium = true;
      // }
      var res2 = await MyHttp.get("/settings/member-status");
      var json2 = jsonDecode(res2.body);
      status = json2["success"];
      if (status == true) Global.isPremium = true;
      print(status);

      // print(res.body);
      print(res2.body);
    } catch (e) {
      print(e);
    }
    print(id);
  }

  Future<Map<String, dynamic>> _getNotifications() async {
    setState(() {
      loading = true;
    });
    var res = await MyHttp.get("settings/notification_settings");
    json = jsonDecode(res.body);

    if (!calledBefore) {
      await _getStatus();
      setState(() {
        pushSettings = json["PushSettings"] as Map<String, dynamic>;
        emailSettings = json["EmailSettings"] as Map<String, dynamic>;
      });

      print("pushSettings $pushSettings");
      print("emailSettings $emailSettings");
      calledBefore = true;
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> _setEmailNotifications() async {
    var res = await MyHttp.post(
        "settings/notification_settings/email/update", emailSettings);
    print(res.statusCode);
  }

  Future<void> _sendData() {
    _setPushNotifications();
    _setEmailNotifications();
  }

  Future<void> _setPushNotifications() async {
    try {
      var res = await MyHttp.post(
          "settings/notification_settings/push/update", pushSettings);
      print("Update push notification settings code: ${res.body}");
    } catch (e) {
      print("Update push notification settings code error: ${e}");
    }
  }

  @override
  void initState() {
    this._getNotifications();
    super.initState();
    //Analytics code
    amplitudeAnalytics.init(apiKey);
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
              onPressed: () async {
                await _sendData();
                Navigator.pop(context);

                //Analytics tracking code
                analytics.setCurrentScreen(
                    screenName: "settings", screenClassOverride: "settings");
                amplitudeAnalytics.logEvent("settings_page");
              },
            ),
          ),
          title: Text(
            "Notifications",
            style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal),
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          brightness: Brightness.dark,
          automaticallyImplyLeading: false,
          automaticallyImplyMiddle: false,
          backgroundColor: AppColors.offWhiteColor,
          leading: MaterialButton(
            onPressed: () {},
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.white,
              onPressed: () async {
                await _sendData();
                Navigator.pop(context);

                //Analytics tracking code
                analytics.setCurrentScreen(
                    screenName: "settings", screenClassOverride: "settings");
                amplitudeAnalytics.logEvent("settings_page");
              },
            ),
          ),
          title: Text(
            "Notifications",
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
        child: Scaffold(
          backgroundColor: Colors.white,
          body: (this.loading)
              ? Loading.showLoading()
              : (this.emailSettings == null)
                  ? Text("Error loading the data")
                  : SingleChildScrollView(
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            //First Container for Push Notifications
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(
                                      left: 10.0,
                                    ),
                                    color: AppColors.greyColor,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        SizedBox(height: 20.0),
                                        Text(
                                          "Push Notifications",
                                          style: TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(
                                          "Turn push notifications ON for:",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontStyle: FontStyle.normal),
                                        ),
                                        SizedBox(height: 10.0),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Mutual Matches",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Switch.adaptive(
                                                onChanged: (bool) {
                                                  pushSettings.update(
                                                    "new_match",
                                                    (bool) => !bool,
                                                    ifAbsent: () => bool,
                                                  );
                                                  this._setPushNotifications();
                                                  setState(() {});
                                                  //Analytics tracking code
                                                  analytics.logEvent(
                                                      name:
                                                          "modified_notification_settings",
                                                      parameters: <String, dynamic>{
                                                        'push_notification':
                                                            'mutual_matches',
                                                        'value': bool
                                                      });

                                                  amplitudeAnalytics.logEvent(
                                                      "modified_notification_settings",
                                                      eventProperties: {
                                                        'push_notification':
                                                            'mutual_matches',
                                                        'value': bool
                                                      });
                                                },
                                                activeTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveThumbColor:
                                                    AppColors.offWhiteColor,
                                                value:
                                                    pushSettings["new_match"]),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Profile Likes",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Switch.adaptive(
                                                onChanged: (bool) {
                                                  pushSettings.update(
                                                    "new_like",
                                                    (bool) => !bool,
                                                    ifAbsent: () => bool,
                                                  );
                                                  this._setPushNotifications();
                                                  setState(() {});
                                                  //Analytics tracking code
                                                  analytics.logEvent(
                                                      name:
                                                          "modified_notification_settings",
                                                      parameters: <String, dynamic>{
                                                        'email_notification':
                                                            'profile_likes',
                                                        'value': bool
                                                      });

                                                  amplitudeAnalytics.logEvent(
                                                      "modified_notification_settings",
                                                      eventProperties: {
                                                        'email_notification':
                                                            'profile_likes',
                                                        'value': bool
                                                      });
                                                },
                                                activeTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveThumbColor:
                                                    AppColors.offWhiteColor,
                                                value:
                                                    pushSettings["new_like"]),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Messages",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Switch.adaptive(
                                                onChanged: (bool) {
                                                  pushSettings.update(
                                                    "new_message",
                                                    (bool) => !bool,
                                                    ifAbsent: () => bool,
                                                  );
                                                  this._setPushNotifications();
                                                  setState(() {});

                                                  //Analytics tracking code
                                                  analytics.logEvent(
                                                      name:
                                                          "modified_notification_settings",
                                                      parameters: <String, dynamic>{
                                                        'email_notification':
                                                            'messages',
                                                        'value': bool
                                                      });

                                                  amplitudeAnalytics.logEvent(
                                                      "modified_notification_settings",
                                                      eventProperties: {
                                                        'email_notification':
                                                            'messages',
                                                        'value': bool
                                                      });
                                                },
                                                activeTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveThumbColor:
                                                    AppColors.offWhiteColor,
                                                value: pushSettings[
                                                    "new_message"]),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Post Likes",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Switch.adaptive(
                                                onChanged: (bool) {
                                                  pushSettings.update(
                                                    "new_post_like",
                                                    (bool) => !bool,
                                                    ifAbsent: () => bool,
                                                  );
                                                  this._setPushNotifications();
                                                  setState(() {});

                                                  //Analytics tracking code
                                                  analytics.logEvent(
                                                      name:
                                                          "modified_notification_settings",
                                                      parameters: <String, dynamic>{
                                                        'email_notification':
                                                            'post_likes',
                                                        'value': bool
                                                      });

                                                  amplitudeAnalytics.logEvent(
                                                      "modified_notification_settings",
                                                      eventProperties: {
                                                        'email_notification':
                                                            'post_likes',
                                                        'value': bool
                                                      });
                                                },
                                                activeTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveThumbColor:
                                                    AppColors.offWhiteColor,
                                                value: pushSettings[
                                                    "new_post_like"]),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Friend Request",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Switch.adaptive(
                                                onChanged: (bool) {
                                                  pushSettings.update(
                                                    "new_friend_request",
                                                    (bool) => !bool,
                                                    ifAbsent: () => bool,
                                                  );
                                                  this._setPushNotifications();
                                                  setState(() {});
                                                  //Analytics tracking code
                                                  analytics.logEvent(
                                                      name:
                                                          "modified_notification_settings",
                                                      parameters: <String, dynamic>{
                                                        'email_notification':
                                                            'friend_request',
                                                        'value': bool
                                                      });

                                                  amplitudeAnalytics.logEvent(
                                                      "modified_notification_settings",
                                                      eventProperties: {
                                                        'email_notification':
                                                            'friend_request',
                                                        'value': bool
                                                      });
                                                },
                                                activeTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveThumbColor:
                                                    AppColors.offWhiteColor,
                                                value: pushSettings[
                                                    "new_friend_request"]),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Special Offers & Promotions",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Switch.adaptive(
                                                onChanged: (bool) {
                                                  pushSettings.update(
                                                    "new_PM_offer",
                                                    (bool) => !bool,
                                                    ifAbsent: () => bool,
                                                  );
                                                  this._setPushNotifications();
                                                  setState(() {});
                                                  //Analytics tracking code
                                                  analytics.logEvent(
                                                      name:
                                                          "modified_notification_settings",
                                                      parameters: <String, dynamic>{
                                                        'email_notification':
                                                            'special_offer_promotions',
                                                        'value': bool
                                                      });

                                                  amplitudeAnalytics.logEvent(
                                                      "modified_notification_settings",
                                                      eventProperties: {
                                                        'email_notification':
                                                            'special_offer_promotions',
                                                        'value': bool
                                                      });
                                                },
                                                activeTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveThumbColor:
                                                    AppColors.offWhiteColor,
                                                value: pushSettings[
                                                    "new_PM_offer"]),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Profile Views",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: !Global.isPremium,
                                              child: Text(
                                                "Unlock with Premium",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FontStyle.normal),
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  !Global.isPremium && !isIOS,
                                              child: Icon(
                                                Icons.lock_outline,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Stack(
                                              alignment: Alignment.centerRight,
                                              children: <Widget>[
                                                Switch.adaptive(
                                                    onChanged: Global
                                                                .isPremium ==
                                                            true
                                                        ? (bool) {
                                                            pushSettings.update(
                                                              "new_profile_view",
                                                              (bool) => !bool,
                                                              ifAbsent: () =>
                                                                  bool,
                                                            );
                                                            this._setPushNotifications();
                                                            setState(() {});
                                                            //Analytics tracking code
                                                            analytics.logEvent(
                                                                name:
                                                                    "modified_notification_settings",
                                                                parameters: <String, dynamic>{
                                                                  'email_notification':
                                                                      'profile_views',
                                                                  'value': bool
                                                                });

                                                            amplitudeAnalytics.logEvent(
                                                                "modified_notification_settings",
                                                                eventProperties: {
                                                                  'email_notification':
                                                                      'profile_views',
                                                                  'value': bool
                                                                });
                                                          }
                                                        : null,
                                                    activeTrackColor: AppColors
                                                        .settingsDividerColor,
                                                    inactiveTrackColor: AppColors
                                                        .settingsDividerColor,
                                                    inactiveThumbColor:
                                                        AppColors.offWhiteColor,
                                                    value: Global.isPremium ==
                                                            true
                                                        ? pushSettings[
                                                            "new_profile_view"]
                                                        : false),
                                                Positioned(
                                                  right: 4,
                                                  child: Visibility(
                                                    visible:
                                                        !Global.isPremium &&
                                                            isIOS,
                                                    child: Icon(
                                                      Icons.lock_outline,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //Second Container for Email Notifications
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(
                                      left: 10.0,
                                    ),
                                    color: AppColors.greyColor,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        SizedBox(height: 20.0),
                                        Text(
                                          "Email Notifications",
                                          style: TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(
                                          "Turn push notifications ON for:",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontStyle: FontStyle.normal),
                                        ),
                                        SizedBox(height: 10.0),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Mutual Matches",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Switch.adaptive(
                                                onChanged: (bool) {
                                                  emailSettings.update(
                                                    "new_match",
                                                    (bool) => !bool,
                                                    ifAbsent: () => bool,
                                                  );
                                                  this._setEmailNotifications();

                                                  setState(() {});
                                                },
                                                activeTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveThumbColor:
                                                    AppColors.offWhiteColor,
                                                value:
                                                    emailSettings["new_match"]),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Profile Likes",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Switch.adaptive(
                                                onChanged: (bool) {
                                                  emailSettings.update(
                                                    "new_like",
                                                    (bool) => !bool,
                                                    ifAbsent: () => bool,
                                                  );
                                                  this._setEmailNotifications();
                                                  setState(() {});
                                                },
                                                activeTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveThumbColor:
                                                    AppColors.offWhiteColor,
                                                value:
                                                    emailSettings["new_like"]),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Messages",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Switch.adaptive(
                                                onChanged: (bool) {
                                                  emailSettings.update(
                                                    "new_message",
                                                    (bool) => !bool,
                                                    ifAbsent: () => bool,
                                                  );
                                                  this._setEmailNotifications();

                                                  setState(() {});
                                                },
                                                activeTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveThumbColor:
                                                    AppColors.offWhiteColor,
                                                value: emailSettings[
                                                    "new_message"]),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Post Likes",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Switch.adaptive(
                                                onChanged: (bool) {
                                                  emailSettings.update(
                                                    "new_post_like",
                                                    (bool) => !bool,
                                                    ifAbsent: () => bool,
                                                  );
                                                  this._setEmailNotifications();
                                                  setState(() {});
                                                },
                                                activeTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveThumbColor:
                                                    AppColors.offWhiteColor,
                                                value: emailSettings[
                                                    "new_post_like"]),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Friend Request",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Switch.adaptive(
                                                onChanged: (bool) {
                                                  emailSettings.update(
                                                    "new_friend_request",
                                                    (bool) => !bool,
                                                    ifAbsent: () => bool,
                                                  );
                                                  this._setEmailNotifications();
                                                  setState(() {});
                                                },
                                                activeTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveThumbColor:
                                                    AppColors.offWhiteColor,
                                                value: emailSettings[
                                                    "new_friend_request"]),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Special Offers & Promotions",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Switch.adaptive(
                                                onChanged: (bool) {
                                                  emailSettings.update(
                                                    "new_PM_offer",
                                                    (bool) => !bool,
                                                    ifAbsent: () => bool,
                                                  );
                                                  this._setEmailNotifications();

                                                  setState(() {});
                                                },
                                                activeTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveTrackColor: AppColors
                                                    .settingsDividerColor,
                                                inactiveThumbColor:
                                                    AppColors.offWhiteColor,
                                                value: emailSettings[
                                                    "new_PM_offer"]),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Profile Views",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: !Global.isPremium,
                                              child: Text(
                                                "Unlock with Premium",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FontStyle.normal),
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  !Global.isPremium && !isIOS,
                                              child: Icon(
                                                Icons.lock_outline,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Stack(
                                              alignment: Alignment.centerRight,
                                              children: <Widget>[
                                                Switch.adaptive(
                                                    onChanged:
                                                        Global.isPremium == true
                                                            ? (bool) {
                                                                emailSettings
                                                                    .update(
                                                                  "new_profile_view",
                                                                  (bool) =>
                                                                      !bool,
                                                                  ifAbsent:
                                                                      () =>
                                                                          bool,
                                                                );
                                                                this._setEmailNotifications();

                                                                setState(() {});
                                                              }
                                                            : null,
                                                    activeTrackColor: AppColors
                                                        .settingsDividerColor,
                                                    inactiveTrackColor: AppColors
                                                        .settingsDividerColor,
                                                    inactiveThumbColor:
                                                        AppColors.offWhiteColor,
                                                    value: Global.isPremium ==
                                                            true
                                                        ? emailSettings[
                                                            "new_profile_view"]
                                                        : false),
                                                Positioned(
                                                  right: 4,
                                                  child: Visibility(
                                                    visible:
                                                        !Global.isPremium &&
                                                            isIOS,
                                                    child: Icon(
                                                      Icons.lock_outline,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          height: 3,
                                          color: Colors.grey.shade100,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
