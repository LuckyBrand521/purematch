import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:io';
import 'package:pure_match/pages/settings/admin_tools/ban_user_body.dart';
import 'package:amplitude_flutter/amplitude.dart';

class BanUsers extends StatefulWidget {
  @override
  _BanUsersState createState() => _BanUsersState();
}

class _BanUsersState extends State<BanUsers>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int subpage = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);

    _tabController = TabController(vsync: this, length: 3);

    // Analytics event tracking code
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        analytics.setCurrentScreen(
            screenName: "banned_user_queue",
            screenClassOverride: "banned_user_queue");
        amplitudeAnalytics.logEvent("banned_user_queue_page");
      } else if (_tabController.index == 1) {
        analytics.setCurrentScreen(
            screenName: "banned_user_warned",
            screenClassOverride: "banned_user_warned");
        amplitudeAnalytics.logEvent("banned_user_warned_page");
      } else if (_tabController.index == 2) {
        analytics.setCurrentScreen(
            screenName: "banned_user_banned",
            screenClassOverride: "banned_user_banned");
        amplitudeAnalytics.logEvent("banned_user_banned_page");
      }
    });
    loadChildWidgets();
  }

  void loadChildWidgets() {
    childWidgets = [
      BannedPage(
        page: SubPage.Queue,
      ),
      BannedPage(
        page: SubPage.Warned,
      ),
      BannedPage(
        page: SubPage.Banned,
      ),
    ];
  }

  Widget getChildWidget() => childWidgets[subpage];
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> childWidgets = [];
  final Map<int, Widget> map = {
    0: Text(
      "Queue",
      style: TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
      ),
    ),
    1: Text(
      "Warned",
      style: TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
      ),
    ),
    2: Text(
      "Banned",
      style: TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
      ),
    )
  };
  @override
  Widget build(BuildContext context) {
    // final double iconSize = 40;
    return PlatformScaffold(
      backgroundColor: AppColors.adminBlackHeader,
      //bottomNavBar: HomePage(),
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: AppColors.adminBlackHeader,
          elevation: 0.0,
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => SettingsNavigator(
                //               tabIndex: 2,
                //             )));
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                child: Image(
                  image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
                ),
              ),
            )
          ],
          title: Text(
            "Ban & Warn Users",
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                fontFamily: 'Avenir Next'),
          ),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                child: Text(
                  "Queue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Warned",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Banned",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            ],
            controller: _tabController,
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          automaticallyImplyMiddle: false,
          backgroundColor: AppColors.adminBlackHeader,
          trailing: MaterialButton(
            onPressed: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => SettingsNavigator(
              //               tabIndex: 2,
              //             )));
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
              child: Image(
                image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
              ),
            ),
          ),
          title: Text(
            "Ban & Warn Users",
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                fontFamily: 'Avenir Next'),
          ),
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
        ),
      ),
      body: SafeArea(
        child: (Platform.isAndroid)
            ? TabBarView(
                controller: _tabController,
                children: childWidgets,
              )
            : Scaffold(
                backgroundColor: AppColors.adminBlackBackground,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    PlatformWidget(
                      cupertino: (_, __) => CupertinoSlidingSegmentedControl(
                        children: map,
                        onValueChanged: (int) {
                          setState(() {
                            subpage = int;
                          });
                          // Analytics event tracking code
                          if (subpage == 0) {
                            analytics.setCurrentScreen(
                                screenName: "banned_user_queue",
                                screenClassOverride: "banned_user_queue");
                            amplitudeAnalytics
                                .logEvent("banned_user_queue_page");
                          } else if (subpage == 1) {
                            analytics.setCurrentScreen(
                                screenName: "banned_user_warned",
                                screenClassOverride: "banned_user_warned");
                            amplitudeAnalytics
                                .logEvent("banned_user_warned_page");
                          } else if (subpage == 2) {
                            analytics.setCurrentScreen(
                                screenName: "banned_user_banned",
                                screenClassOverride: "banned_user_banned");
                            amplitudeAnalytics
                                .logEvent("banned_user_banned_page");
                          }
                        },
                        groupValue: subpage,
                        thumbColor: Color.fromRGBO(99, 99, 102, 1),
                        backgroundColor: AppColors.searchBarColor,
                      ),
                    ),
                    Expanded(child: getChildWidget()),
                  ],
                )),
      ),
    );
  }
}
