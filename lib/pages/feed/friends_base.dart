import 'dart:io' show Platform;

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pure_match/common/feed_drawer.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/feed/FriendRequest.dart';
import 'package:pure_match/pages/feed/friends_feed.dart';

import 'package:pure_match/pages/settings/settings_main.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

import '../AppColors.dart';

class FriendsBase extends StatefulWidget {
  bool isFriendReuest;
  final Function(int) selectOptionFriendRequest;
  FriendsBase({isFriendReuest, this.selectOptionFriendRequest}) {
    this.isFriendReuest = isFriendReuest ?? false;
  }
  @override
  _FriendsBaseState createState() => _FriendsBaseState();
}

class _FriendsBaseState extends State<FriendsBase>
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

  void initState() {
    if (widget.isFriendReuest) {
      setState(() {
        selectedIndex = 1;
      });
    }
    loadCupertinoTabs();
    loadChildWidgets();
    _tabController = TabController(length: childWidgets.length, vsync: this);

    // Analytics event tracking code
    amplitudeAnalytics.init(apiKey);

    // this is the listener to hide the keyboard if we switch tabs
    _tabController.addListener(() {
      int i = _tabController.previousIndex;
      if (i == 0) {
        FocusScope.of(context).requestFocus(FocusNode());
      }

      // Analytics tracking code
      if (_tabController.index == 0) {
        analytics.setCurrentScreen(
            screenName: "friends", screenClassOverride: "friends");
        amplitudeAnalytics.logEvent("friends_page");
      } else if (_tabController.index == 1) {
        analytics.setCurrentScreen(
            screenName: "friend_requests",
            screenClassOverride: "friend_requests");
        amplitudeAnalytics.logEvent("friend_requests_page");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: FeedDrawer(
        openPageType: DrawerPage.FRIENDS,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.yellowColor,
        title: Text(
          "Friends",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
        ),
        bottom: (Platform.isAndroid)
            ? TabBar(
                indicatorColor: Colors.white,
                controller: _tabController,
                tabs: <Widget>[
                  Tab(
                    child: Text("Friends"),
                  ),
                  Tab(
                    child: (Global.unreadFriendRequestCount == 0)
                        ? Text("Friend Requests")
                        : Container(
                            height: 28,
                            padding: EdgeInsets.zero,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Friend Requests"),
                                SizedBox(
                                  width: 5,
                                ),
                                Badge(
                                  badgeContent: Text(
                                    Global.unreadFriendRequestCount.toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          ),
                  ),
                ],
              )
            : PreferredSize(
                child: Container(), preferredSize: const Size.fromHeight(0.0)),
        actions: <Widget>[
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
      body: SafeArea(
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
                          // Analytics event tracking code
                          if (selectedIndex == 0) {
                            analytics.setCurrentScreen(
                                screenName: "friends",
                                screenClassOverride: "friends");
                            amplitudeAnalytics.logEvent("friends_page");
                          } else if (selectedIndex == 1) {
                            analytics.setCurrentScreen(
                                screenName: "friend_requests",
                                screenClassOverride: "friend_requests");
                            amplitudeAnalytics.logEvent("friend_requests_page");
                          }
                          ;
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
    );
  }

  void onSelectFriendOption(index) {
    widget.selectOptionFriendRequest(index);
    loadCupertinoTabs();
    setState(() {});
  }

  void loadCupertinoTabs() {
    map = new Map();
    map[0] = Text("Friends");
    map[1] = (Global.unreadFriendRequestCount == 0)
        ? Text("Friend Requests")
        : Container(
            height: 28,
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Friend Requests"),
                SizedBox(
                  width: 5,
                ),
                Badge(
                  badgeContent: Text(
                    Global.unreadFriendRequestCount.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          );
  }

  void loadChildWidgets() {
    childWidgets = [
      FriendsFeed(
        friendsType: FriendType.FRIENDS,
        key: UniqueKey(),
      ),
      FriendsRequest(
        friendsType: FriendType.FRIEND_REQUEST,
        selectFriendOption: onSelectFriendOption,
        key: UniqueKey(),
      ),
    ];
  }

  Widget getChildWidget() => childWidgets[selectedIndex];
}
