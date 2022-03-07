import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/settings/account_settings/manage_subscription/manage_subscription.dart';
import 'package:pure_match/pages/settings/account_settings/change_location.dart';
import 'package:pure_match/pages/settings/account_settings/change_email.dart';
import 'package:pure_match/pages/settings/account_settings/deactivate_account.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/settings/account_settings/successful_deactivate.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes.dart';
import '../../MyHttp.dart';

class AccountSettings extends StatefulWidget {
  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int i = 0;

  Widget _settingsOptions(String title, Widget newPage) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => newPage,
              ),
            );

            //Analytics tracking code. Logs screen views for manage_subscription, change_email_address, change_location and deactivate_account
            analytics.setCurrentScreen(
                screenName: title.split(" ").join('_').toLowerCase(),
                screenClassOverride: title);
            amplitudeAnalytics
                .logEvent(title.split(" ").join('_').toLowerCase() + "_page");
          },
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 25,
              ),
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios,
                    color: Colors.black, size: 25),
              )
            ],
          ),
        ),
        Divider(
          thickness: 2,
          height: 3,
          color: Colors.grey.shade100,
        ),
      ],
    );
  }

  Future<void> _deactivateAccount() async {
    String date = DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());
    var output = {
      "reason": "No reason is added. Account deactivated",
      "reactivation_date": date,
    };
    var res = await MyHttp.put("users/account/deactivate", output);
    if (res.statusCode == 200) {
      var sp = await SharedPreferences.getInstance();
      sp.remove("token");
      sp.remove("id");
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
    }
    print(res.body);
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
                child: Text("Cancel",
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsBlueColor,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  // Update user model is friend request sent successfully
                  Navigator.of(context).pop();
                }),
            FlatButton(
                child: Text(button,
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsRedColor,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  print(button);
                  if (button == "Deactivate") {
                    _deactivateAccount();
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SuccessfulDeactivatePage()));
                  }
                }),
          ],
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
          CupertinoButton(
            child: Text("Cancel",
                style: TextStyle(
                    color: AppColors.communityProfileOptionsBlueColor,
                    fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoButton(
            child: Text(button,
                style: TextStyle(
                    color: AppColors.communityProfileOptionsRedColor,
                    fontWeight: FontWeight.w600)),
            onPressed: () {
              print(button);
              if (button == "Deactivate") {
                _deactivateAccount();
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SuccessfulDeactivatePage()));
              }
            },
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);

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
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => SettingsNavigator(
                //               tabIndex: 2,
                //             )));
                // analytics tracking code
                analytics.setCurrentScreen(
                    screenName: "settings_page",
                    screenClassOverride: "settings_page");
                amplitudeAnalytics.logEvent("settings_page");
              },
            ),
          ),
          title: Text(
            "Account Settings",
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
          leading: PlatformIconButton(
            padding: EdgeInsets.only(top: 10),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => SettingsNavigator(
              //               tabIndex: 3,
              //             )));
              //Analytics tracking code
              analytics.setCurrentScreen(
                  screenName: "settings", screenClassOverride: "settings");
              amplitudeAnalytics.logEvent("settings_page");
            },
          ),
          title: Text(
            "Account Settings",
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
          body: Container(
            padding: const EdgeInsetsDirectional.only(
                start: 0.0, end: 5.0, top: 5.0, bottom: 5.0),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Divider(
                  thickness: 2,
                  height: 3,
                  color: Colors.grey.shade100,
                ),

                /// commenting out the "Manage Subscription" option to avoid confusion in canceling or managing subscription in-app.
                ///                this._settingsOptions(
                ///                    "Manage Subscription", ManageSubscription()),
                this._settingsOptions("Change Email Address", ChangeEmail()),
                this._settingsOptions("Change Location", ChangeLocation()),

                ///The code below will be used if we want to revert back to how
                ///it used to be with deactivating being an page rather a pop up.
                ///The deactivation page is really a delete page.
                // this._settingsOptions("Deactivate Account", DeactivateAccount()),
                ///This below code is used to show the deactivate account alert
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        _alertUser(
                            context,
                            "Deactivate Account",
                            "This will temporarily remove your account activity, profile, and other information from Pure Match. You can reactivate any time.",
                            "Deactivate");
                      },
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 25,
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Deactivate Account",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios,
                                color: Colors.black, size: 25),
                          )
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 2,
                      height: 3,
                      color: Colors.grey.shade100,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
