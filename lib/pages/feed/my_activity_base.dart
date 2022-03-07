import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/common/feed_drawer.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/settings/settings_main.dart';
import 'package:pure_match/pages/feed/my_activity.dart';
import 'package:pure_match/pages/feed/search_feed.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

class MyActivityBase extends StatefulWidget {
  @override
  _MyActivityBaseState createState() => _MyActivityBaseState();
}

class _MyActivityBaseState extends State<MyActivityBase>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  Map<int, Widget> map = new Map();
  List<Widget> childWidgets = [];
  int selectedIndex = 0;

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  void initState() {
    loadCupertinoTabs();
    loadChildWidgets();
    _tabController = TabController(length: childWidgets.length, vsync: this);

    //analytics code
    amplitudeAnalytics.init(apiKey);

    // this is the listener to hide the keyboard if we switch tabs
    _tabController.addListener(() {
      int i = _tabController.previousIndex;
      if (i == 0) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
      //Analytics code
      String pageName = "";
      if (_tabController.index == 0) {
        pageName = "my_activity_liked";
        analytics.setCurrentScreen(
            screenName: pageName, screenClassOverride: pageName);
        amplitudeAnalytics.logEvent(pageName + "_page");
      } else if (_tabController.index == 1) {
        pageName = "my_activity_saved";
        analytics.setCurrentScreen(
            screenName: pageName, screenClassOverride: pageName);
        amplitudeAnalytics.logEvent(pageName + "_page");
      } else if (_tabController.index == 2) {
        pageName = "my_activity_my_post";
        analytics.setCurrentScreen(
            screenName: pageName, screenClassOverride: pageName);
        amplitudeAnalytics.logEvent(pageName + "_page");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: FeedDrawer(
          openPageType: DrawerPage.MY_ACTIVITY,
        ),
        appBar: AppBar(
          backgroundColor: AppColors.yellowColor,
          title: Text(
            "My Activity",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
          ),
          bottom: (Platform.isAndroid)
              ? TabBar(
                  indicatorColor: Colors.white,
                  controller: _tabController,
                  tabs: <Widget>[
                    Tab(
                      child: Text("Liked"),
                    ),
                    Tab(
                      child: Text("Saved"),
                    ),
                    Tab(
                      child: Text("My Posts"),
                    )
                  ],
                )
              : PreferredSize(
                  child: Container(),
                  preferredSize: const Size.fromHeight(0.0)),
          actions: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchFeed()));
              },
              child: SizedBox(
                  width: 100,
                  height: 30,
                  child: Padding(
                    padding: EdgeInsets.only(right: 25),
                    child: Image.asset(
                      "assets/images/search_bar.png",
                      fit: BoxFit.contain,
                    ),
                  )),
            ),
            InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MainSettings()));
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: SizedBox(
                      width: 35,
                      height: 31,
                      child: Image.asset(
                        "assets/images/setting_logo.png",
                        fit: BoxFit.contain,
                      )),
                )),
          ],
        ),
        body: Stack(
          children: [
            SafeArea(
              child: (Platform.isAndroid)
                  ? TabBarView(
                      controller: _tabController,
                      children: childWidgets,
                    )
                  : Container(
                      child: Column(
                        children: <Widget>[
                          ConstrainedBox(
                            constraints: BoxConstraints.expand(height: 32.0),
                            child: CupertinoSlidingSegmentedControl(
                              onValueChanged: (value) {
                                setState(() {
                                  selectedIndex = value;
                                });
                                //Analytics code
                                if (selectedIndex == 0) {
                                  analytics.setCurrentScreen(
                                      screenName: "my_activity_liked",
                                      screenClassOverride: "my_activity_liked");
                                  amplitudeAnalytics
                                      .logEvent("my_activity_liked_page");
                                } else if (selectedIndex == 1) {
                                  analytics.setCurrentScreen(
                                      screenName: "my_activity_saved",
                                      screenClassOverride: "my_activity_saved");
                                  amplitudeAnalytics
                                      .logEvent("my_activity_saved_page");
                                } else if (selectedIndex == 2) {
                                  analytics.setCurrentScreen(
                                      screenName: "my_activity_my_post",
                                      screenClassOverride:
                                          "my_activity_my_post");
                                  amplitudeAnalytics
                                      .logEvent("my_activity_my_post_page");
                                }
                              },
                              groupValue: selectedIndex,
                              //selectedColor, unselected color, padding etc.
                              children: map,
                            ),
                          ),
                          Expanded(child: getChildWidget()),
                        ],
                      ),
                    ),
            ),
          ],
        ));
  }

  void loadCupertinoTabs() {
    map = new Map();
    map[0] = Text("Liked");
    map[1] = Text("Saved");
    map[2] = Text("My Posts");
  }

  void loadChildWidgets() {
    childWidgets = [
      MyActivity(
        feedType: FeedType.LIKED,
        key: UniqueKey(),
      ),
      MyActivity(feedType: FeedType.SAVED, key: UniqueKey()),
      MyActivity(feedType: FeedType.MY_POST, key: UniqueKey())
    ];
  }

  Widget getChildWidget() => childWidgets[selectedIndex];
}
