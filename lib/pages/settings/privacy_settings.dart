import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/loading.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplitude_flutter/amplitude.dart';

class PrivacySettings extends StatefulWidget {
  final int userId;
  final Function refreshMatch;
  const PrivacySettings({Key key, this.userId, this.refreshMatch})
      : super(key: key);
  @override
  _PrivacySettingsState createState() => _PrivacySettingsState();
}

class _PrivacySettingsState extends State<PrivacySettings> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  bool isIOS = Platform.isIOS;
  var res;
  var json;
  Map<String, dynamic> privacySettings;
  bool status;
  bool match_premium_visible = false;
  bool calledBefore = false;
  bool currentUser = true;
  bool loading = false;

  Future<void> _getPriSettings() async {
    setState(() {
      loading = true;
    });
    res = await MyHttp.get("settings/privacy_settings");
    json = jsonDecode(res.body);
    if (!calledBefore) {
      await _getStatus();
      privacySettings = json["user"]["PrivacySetting"] as Map<String, dynamic>;
      // match_premium_visible = privacySettings["match_premium_visible"];
      Global.matching_active = privacySettings["matching_active"];
      print("Privacy setting $privacySettings");
      calledBefore = true;
    }
    setState(() {
      loading = false;
    });
  }

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

  Future<void> _setPrivacySettings() async {
    var res =
        await MyHttp.post("settings/privacy_settings/update", privacySettings);

    print(res.body);
  }

  @override
  void initState() {
    super.initState();
    this._getPriSettings();
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
  }

  @override
  Widget build(BuildContext context) {
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
                Navigator.pop(context);
                if (this.mounted) {
                  widget.refreshMatch();
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
            "Privacy Settings",
            style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal),
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          brightness: Brightness.dark,
          automaticallyImplyLeading: true,
          automaticallyImplyMiddle: false,
          backgroundColor: AppColors.offWhiteColor,
          title: Text(
            "Privacy Settings",
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal),
          ),
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
        ),
      ),
      body: (this.loading)
          ? Loading.showLoading()
          : SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                //might not need to be in scroll view. In that case start the body from First seen
                // Column widget
                body: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(10.0, 20.0, 0, 15.0),
                          color: AppColors.greyColor,
                          child: Text(
                            "Community Activity",
                            style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal),
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(width: 10.0),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Visible to Public",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                                Switch.adaptive(
                                  onChanged: (bool) {
                                    privacySettings.update(
                                        "feed_visible_public", (bool) => !bool);
                                    this._setPrivacySettings();

                                    //Analytics tracking code
                                    analytics.logEvent(
                                        name: "modified_privacy_settings",
                                        parameters: <String, dynamic>{
                                          'feeds_activity': "visible_to_public",
                                          'value': bool
                                        });

                                    amplitudeAnalytics.logEvent(
                                        "modified_privacy_settings",
                                        eventProperties: {
                                          'feeds_activity': "visible_to_public",
                                          'value': bool
                                        });
                                    setState(() {});
                                  },
                                  activeTrackColor:
                                      AppColors.settingsDividerColor,
                                  inactiveTrackColor:
                                      AppColors.settingsDividerColor,
                                  inactiveThumbColor: AppColors.offWhiteColor,
                                  value: privacySettings["feed_visible_public"],
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                            Divider(
                              thickness: 2,
                              height: 3,
                              color: AppColors.greyColor,
                            ),
                            Row(
                              children: <Widget>[
                                SizedBox(width: 10.0),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Visible to Friends",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                                Switch.adaptive(
                                    onChanged: (bool) {
                                      privacySettings.update(
                                          "feed_visible_friends",
                                          (bool) => !bool);
                                      this._setPrivacySettings();
                                      //Analytics tracking code
                                      analytics.logEvent(
                                          name: "modified_privacy_settings",
                                          parameters: <String, dynamic>{
                                            'feeds_activity':
                                                "visible_to_friends",
                                            'value': bool
                                          });

                                      amplitudeAnalytics.logEvent(
                                          "modified_privacy_settings",
                                          eventProperties: {
                                            'feeds_activity':
                                                "visible_to_friends",
                                            'value': bool
                                          });

                                      setState(() {});
                                    },
                                    activeTrackColor:
                                        AppColors.settingsDividerColor,
                                    inactiveTrackColor:
                                        AppColors.settingsDividerColor,
                                    inactiveThumbColor: AppColors.offWhiteColor,
                                    value: privacySettings[
                                        "feed_visible_friends"]),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                            Divider(
                              thickness: 2,
                              height: 3,
                              color: AppColors.greyColor,
                            ),
                            Row(
                              children: <Widget>[
                                SizedBox(width: 10.0),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Visible to Matches",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                                Switch.adaptive(
                                    onChanged: (bool) {
                                      privacySettings.update(
                                          "feed_visible_matches",
                                          (bool) => !bool);
                                      this._setPrivacySettings();
                                      //Analytics tracking code
                                      analytics.logEvent(
                                          name: "modified_privacy_settings",
                                          parameters: <String, dynamic>{
                                            'feeds_activity':
                                                "visible_to_matches",
                                            'value': bool
                                          });

                                      amplitudeAnalytics.logEvent(
                                          "modified_privacy_settings",
                                          eventProperties: {
                                            'feeds_activity':
                                                "visible_to_matches",
                                            'value': bool
                                          });

                                      setState(() {});
                                    },
                                    activeTrackColor:
                                        AppColors.settingsDividerColor,
                                    inactiveTrackColor:
                                        AppColors.settingsDividerColor,
                                    inactiveThumbColor: AppColors.offWhiteColor,
                                    value: privacySettings[
                                        "feed_visible_matches"]),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          color: AppColors.greyColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Includes posts, comments, likes, and/or \n any action on your feed.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    "Community Profile",
                                    style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(width: 10.0),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Visible to Public",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                                Switch.adaptive(
                                    onChanged: (bool) {
                                      privacySettings.update(
                                          "profile_visible_public",
                                          (bool) => !bool);
                                      this._setPrivacySettings();

                                      // Analytics tracking code
                                      analytics.logEvent(
                                          name: "modified_privacy_settings",
                                          parameters: <String, dynamic>{
                                            'community_profile':
                                                'visible_to_public',
                                            'value': bool
                                          });

                                      amplitudeAnalytics.logEvent(
                                          "modified_privacy_settings",
                                          eventProperties: {
                                            'community_profile':
                                                'visible_to_public',
                                            'value': bool
                                          });
                                      setState(() {});
                                    },
                                    activeTrackColor:
                                        AppColors.settingsDividerColor,
                                    inactiveTrackColor:
                                        AppColors.settingsDividerColor,
                                    inactiveThumbColor: AppColors.offWhiteColor,
                                    value: privacySettings[
                                        "profile_visible_public"]),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                            Divider(
                              thickness: 2,
                              height: 3,
                              color: AppColors.greyColor,
                            ),
                            Row(
                              children: <Widget>[
                                SizedBox(width: 10.0),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Visible to Friends",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                                Switch.adaptive(
                                    onChanged: (bool) {
                                      privacySettings.update(
                                          "profile_visible_friends",
                                          (bool) => !bool);
                                      this._setPrivacySettings();

                                      // Analytics tracking code
                                      amplitudeAnalytics.init(apiKey);

                                      analytics.logEvent(
                                          name: "modified_privacy_settings",
                                          parameters: <String, dynamic>{
                                            'community_profile':
                                                'visible_to_friends',
                                            'value': bool
                                          });

                                      amplitudeAnalytics.logEvent(
                                          "modified_privacy_settings",
                                          eventProperties: {
                                            'community_profile':
                                                'visible_to_friends',
                                            'value': bool
                                          });
                                      setState(() {});
                                    },
                                    activeTrackColor:
                                        AppColors.settingsDividerColor,
                                    inactiveTrackColor:
                                        AppColors.settingsDividerColor,
                                    inactiveThumbColor: AppColors.offWhiteColor,
                                    value: privacySettings[
                                        "profile_visible_friends"]),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                            Divider(
                              thickness: 2,
                              height: 3,
                              color: AppColors.greyColor,
                            ),
                            Row(
                              children: <Widget>[
                                SizedBox(width: 10.0),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Visible to Matches",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                                Switch.adaptive(
                                    onChanged: (bool) {
                                      privacySettings.update(
                                          "profile_visible_matches",
                                          (bool) => !bool);
                                      this._setPrivacySettings();

                                      // Analytics tracking code
                                      amplitudeAnalytics.init(apiKey);

                                      analytics.logEvent(
                                          name: "modified_privacy_settings",
                                          parameters: <String, dynamic>{
                                            'community_profile':
                                                'visible_to_matches',
                                            'value': bool
                                          });

                                      amplitudeAnalytics.logEvent(
                                          "modified_privacy_settings",
                                          eventProperties: {
                                            'community_profile':
                                                'visible_to_matches',
                                            'value': bool
                                          });
                                      setState(() {});
                                    },
                                    activeTrackColor:
                                        AppColors.settingsDividerColor,
                                    inactiveTrackColor:
                                        AppColors.settingsDividerColor,
                                    inactiveThumbColor: AppColors.offWhiteColor,
                                    value: privacySettings[
                                        "profile_visible_matches"]),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(10.0, 20.0, 0, 15.0),
                          color: AppColors.greyColor,
                          child: Text(
                            "Matching",
                            style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(width: 10.0),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Active Matching",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                                onChanged: (bool) {
                                  setState(() {
                                    Global.matching_active = bool;
                                    privacySettings.update(
                                        "matching_active", (bool) => !bool);
                                    this._setPrivacySettings();
                                    //Analytics tracking code
                                    analytics.logEvent(
                                        name: "modified_privacy_settings",
                                        parameters: <String, dynamic>{
                                          'matching': 'active_matching',
                                          'value': bool
                                        });

                                    amplitudeAnalytics.logEvent(
                                        "modified_privacy_settings",
                                        eventProperties: {
                                          'matching': 'active_matching',
                                          'value': bool
                                        });
                                  });
                                },
                                activeTrackColor:
                                    AppColors.settingsDividerColor,
                                inactiveTrackColor:
                                    AppColors.settingsDividerColor,
                                inactiveThumbColor: AppColors.offWhiteColor,
                                value: Global.matching_active),
                            SizedBox(
                              width: 10.0,
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0.0, 10, 0, 10.0),
                          color: AppColors.greyColor,
                          child: Text(
                            "Turn this feature OFF to disable the matching module.",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(width: 10.0),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Incognito Mode",
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
                                    fontStyle: FontStyle.normal),
                              ),
                            ),
                            Visibility(
                              visible: !Global.isPremium && !isIOS,
                              child: Icon(
                                Icons.lock_outline,
                                color: Colors.black,
                              ),
                            ),
                            Stack(
                              alignment: Alignment.centerRight,
                              children: <Widget>[
                                Switch.adaptive(
                                    onChanged: Global.isPremium == true
                                        ? (bool) {
                                            setState(() {
                                              privacySettings.update(
                                                  "match_premium_visible",
                                                  (bool) => !bool);
                                              this._setPrivacySettings();
                                              //Analytics tracking code
                                              analytics.logEvent(
                                                  name:
                                                      "modified_privacy_settings",
                                                  parameters: <String, dynamic>{
                                                    'matching':
                                                        'invisible_mode',
                                                    'value': bool
                                                  });

                                              amplitudeAnalytics.logEvent(
                                                  "modified_privacy_settings",
                                                  eventProperties: {
                                                    'matching':
                                                        'invisible_mode',
                                                    'value': bool
                                                  });
                                            });
                                          }
                                        : null,
                                    activeTrackColor:
                                        AppColors.settingsDividerColor,
                                    inactiveTrackColor:
                                        AppColors.settingsDividerColor,
                                    inactiveThumbColor: AppColors.offWhiteColor,
                                    value: Global.isPremium == true
                                        ? privacySettings[
                                            "match_premium_visible"]
                                        : false),
                                Positioned(
                                  right: 3,
                                  child: Visibility(
                                    visible: !Global.isPremium && isIOS,
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
                        Container(
                          padding: EdgeInsets.fromLTRB(0.0, 10, 0, 10.0),
                          color: AppColors.greyColor,
                          child: Text(
                            "Browse potential matches privately. \n When ON, you won't show up in others' match browsing.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                            ),
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
