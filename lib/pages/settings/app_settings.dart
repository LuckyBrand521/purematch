import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';

class AppSettings extends StatefulWidget {
  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        backgroundColor: Colors.white,
        //bottomNavBar: HomePage(),
        appBar: PlatformAppBar(
          material: (_, __) => MaterialAppBarData(
            backgroundColor: AppColors.offWhiteColor,
            elevation: 0.0,
            leading: null,
            title: Text(
              "App Settings",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal),
            ),
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
            automaticallyImplyLeading: false,
            automaticallyImplyMiddle: false,
            backgroundColor: AppColors.offWhiteColor,
            title: Text(
              "App Settings",
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal),
            ),
          ),
        ),
        body: SafeArea(
            child: Scaffold(
                backgroundColor: Colors.white,
                body: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Push Notifications",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ),
                          Switch.adaptive(
                              activeTrackColor: AppColors.settingsDividerColor,
                              inactiveTrackColor:
                                  AppColors.settingsDividerColor,
                              inactiveThumbColor: AppColors.offWhiteColor,
                              value: true),
                        ],
                      )
                    ],
                  ),
                ))));
  }
}
