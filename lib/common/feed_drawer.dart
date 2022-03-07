import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/models/friend_request_list.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/feed/feed_base_enum.dart';
import 'package:pure_match/pages/messaging/home_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

import 'global.dart';

enum DrawerPage { MY_FEED, MY_ACTIVITY, NOTIFICATION, FRIENDS }

class FeedDrawer extends StatefulWidget {
  final DrawerPage openPageType;

  const FeedDrawer({Key key, @required this.openPageType}) : super(key: key);

  @override
  _FeedDrawerState createState() => _FeedDrawerState();
}

class _FeedDrawerState extends State<FeedDrawer> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  FriendRequestList frl;
  List<FriendRequestList> friendrequest = [];

  @override
  void initState() {
    _getfriendRequest();
    _getUnreadFeedNotification();
    // TODO: implement initState
    super.initState();

    //Analytics code

    amplitudeAnalytics.init(apiKey);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        child: Drawer(
            child: Container(
//            height: double.infinity,
                color: AppColors.yellowColor,
                child: SafeArea(
                  child: ListView(
                    // Important: Remove any padding from the ListView.
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Community',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight:
                                  (widget.openPageType == DrawerPage.MY_FEED)
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                        ),
                        onTap: () {
                          if (widget.openPageType != DrawerPage.MY_FEED)
//                            Navigator.push(context, MaterialPageRoute(builder: (context) => MyFeed()));
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(
                                          baseFeedEnum: BaseFeedEnum.MY_FEED,
                                        )));
                        },
                      ),
                      ListTile(
                        title: Text(
                          'My Activity',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: (widget.openPageType ==
                                      DrawerPage.MY_ACTIVITY)
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                        onTap: () {
                          if (widget.openPageType != DrawerPage.MY_ACTIVITY)
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(
                                          baseFeedEnum:
                                              BaseFeedEnum.MY_ACTIVITY,
                                        )));
                        },
                      ),
                      ListTile(
                        title: Row(children: <Widget>[
                          Text(
                            'Notifications',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: (widget.openPageType ==
                                        DrawerPage.NOTIFICATION)
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Visibility(
                            visible: (Global.unreadFeedNotificationCount > 0),
                            child: Badge(
                              badgeContent: Text(
                                Global.unreadFeedNotificationCount.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ]),
                        onTap: () {
                          if (widget.openPageType != DrawerPage.NOTIFICATION)
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(
                                          baseFeedEnum:
                                              BaseFeedEnum.NOTIFICATION,
                                        )));
                        },
                      ),
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Text(
                              'Friends',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: (widget.openPageType ==
                                          DrawerPage.FRIENDS)
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Visibility(
                              visible: (Global.unreadFriendRequestCount > 0),
                              child: Badge(
                                badgeContent: Text(
                                  Global.unreadFriendRequestCount.toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          if (widget.openPageType != DrawerPage.FRIENDS)
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(
                                          baseFeedEnum: BaseFeedEnum.FRIENDS,
                                        )));
                        },
                      ),
                    ],
                  ),
                ))));
  }

  void _getfriendRequest() async {
    try {
      var res = await MyHttp.get("friends/requests/");
      if (res.statusCode == 200 || res.statusCode == 201) {
        var jsonData = jsonDecode(res.body);
        var request = jsonData["friendReqs"];
        print(request);

        for (var p in request) {
          frl = FriendRequestList.fromJson(p);
          friendrequest.add(frl);
        }
        Global.unreadFriendRequestCount = friendrequest.length;
      }
      setState(() {});
    } catch (e) {}
  }

  void _getUnreadFeedNotification() async {
    try {
      var res = await MyHttp.get("users/unread-notifications");
      if (res.statusCode == 200) {
        var jsonData = jsonDecode(res.body);
        Global.unreadFeedNotificationCount = jsonData["count"];
        print(jsonData);
      }
      setState(() {});
    } catch (e) {}
  }
}
