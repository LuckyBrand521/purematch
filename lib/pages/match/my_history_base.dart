import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/match/my_history.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

class MyHistoryBase extends StatefulWidget {
  final int selectedPage;
  final int userId;
  final String matchType;
  const MyHistoryBase({
    Key key,
    this.selectedPage,
    this.userId,
    this.matchType,
  }) : super(key: key);
  @override
  _MyHistoryBaseState createState() => _MyHistoryBaseState();
}

class _MyHistoryBaseState extends State<MyHistoryBase>
    with SingleTickerProviderStateMixin {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  TabController _tabController;
  Map<int, Widget> map = new Map();
  List<Widget> childWidgets = [];
  int selectedIndex = 0;
  MyHistory myHistory;

  void loadCupertinoTabs() {
    map = new Map();
    map[0] = Text("Mutual");
    map[1] = Text("Likes");
    map[2] = Text("Maybe");
    map[3] = Text("Liked Me");
    map[4] = Text("Viewed Me");
  }

  void loadChildWidgets() {
    childWidgets = [
      (widget.matchType != null && widget.matchType == "matches")
          ? MyHistory(
              myHistoryPage: MyHistoryPage.MUTUAL,
              key: UniqueKey(),
              userId: widget.userId,
            )
          : MyHistory(myHistoryPage: MyHistoryPage.MUTUAL, key: UniqueKey()),
      MyHistory(myHistoryPage: MyHistoryPage.LIKES, key: UniqueKey()),
      MyHistory(myHistoryPage: MyHistoryPage.MAYBE, key: UniqueKey()),
      // (widget.matchType != null && widget.matchType == "likes")
      //     ? MyHistory(
      //         myHistoryPage: MyHistoryPage.LIKED_ME,
      //         key: UniqueKey(),
      //         userId: widget.userId,
      //       )
      //     :
      MyHistory(myHistoryPage: MyHistoryPage.LIKED_ME, key: UniqueKey()),
      Container(
          child: MyHistory(
              myHistoryPage: MyHistoryPage.VIEWED_ME, key: UniqueKey())),
    ];
  }

  Widget getChildWidget() {
    print("*************** $selectedIndex");
    return childWidgets[selectedIndex];
  }

  @override
  void initState() {
    this.selectedIndex = widget?.selectedPage ?? 0;
    loadCupertinoTabs();

    loadChildWidgets();

    _tabController = TabController(length: childWidgets.length, vsync: this);

    // Analytics event tracking code
    amplitudeAnalytics.init(apiKey);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        analytics.setCurrentScreen(
            screenName: "my_history_mutual",
            screenClassOverride: "my_history_mutual");
        amplitudeAnalytics.logEvent("my_history_mutual_page");
      } else if (_tabController.index == 1) {
        analytics.setCurrentScreen(
            screenName: "my_history_likes",
            screenClassOverride: "my_history_likes");
        amplitudeAnalytics.logEvent("my_history_likes_pages");
      } else if (_tabController.index == 2) {
        analytics.setCurrentScreen(
            screenName: "my_history_maybe",
            screenClassOverride: "my_history_maybe");
        amplitudeAnalytics.logEvent("my_history_maybe_page");
      } else if (_tabController.index == 3) {
        analytics.setCurrentScreen(
            screenName: "my_history_liked_me",
            screenClassOverride: "my_history_liked_me");
        amplitudeAnalytics.logEvent("my_history_liked_me_page");
      } else if (_tabController.index == 4) {
        analytics.setCurrentScreen(
            screenName: "my_history_viewed_me",
            screenClassOverride: "my_history_viewed_me");
        amplitudeAnalytics.logEvent("my_history_viewed_me_page");
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyColor,
      appBar: AppBar(
        backgroundColor: AppColors.redColor,
        title: Text(
          "My History",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: (Platform.isIOS) ? true : false,
        bottom: (Platform.isAndroid)
            ? TabBar(
                indicatorColor: Colors.white,
                isScrollable: true,
                controller: _tabController,
                tabs: <Widget>[
                  Tab(
                    text: "Mutual",
                  ),
                  Tab(
                    text: "Likes",
                  ),
                  Tab(
                    text: "Maybe",
                  ),
                  Tab(
                    text: "Liked Me",
                  ),
                  Tab(
                    text: "Viewed Me",
                  )
                ],
              )
            : PreferredSize(
                child: Container(),
                preferredSize: const Size.fromHeight(0.0),
              ),
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
                      constraints: BoxConstraints.expand(
                          height:
                              (AppConfig.fullWidth(context) >= 375) ? 32 : 42),
                      child: CupertinoSlidingSegmentedControl(
                        onValueChanged: (value) {
                          print(value);

                          setState(() {
                            selectedIndex = value;
                          });
                          // Analytics event tracking code
                          _tabController.addListener(() {
                            if (selectedIndex == 0) {
                              analytics.setCurrentScreen(
                                  screenName: "my_history_mutual",
                                  screenClassOverride: "my_history_mutual");
                              amplitudeAnalytics
                                  .logEvent("my_history_mutual_page");
                            } else if (selectedIndex == 1) {
                              analytics.setCurrentScreen(
                                  screenName: "my_history_likes",
                                  screenClassOverride: "my_history_likes");
                              amplitudeAnalytics
                                  .logEvent("my_history_likes_page");
                            } else if (selectedIndex == 2) {
                              analytics.setCurrentScreen(
                                  screenName: "my_history_maybe",
                                  screenClassOverride: "my_history_maybe");
                              amplitudeAnalytics
                                  .logEvent("my_history_maybe_page");
                            } else if (selectedIndex == 3) {
                              analytics.setCurrentScreen(
                                  screenName: "my_history_liked_me",
                                  screenClassOverride: "my_history_liked_me");
                              amplitudeAnalytics
                                  .logEvent("my_history_liked_me_page");
                            } else if (selectedIndex == 4) {
                              analytics.setCurrentScreen(
                                  screenName: "my_history_viewed_me",
                                  screenClassOverride: "my_history_viewed_me");
                              amplitudeAnalytics
                                  .logEvent("my_history_viewed_me_page");
                            }
                          });
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
//  void _getData() async {
//    print("******^^^^");
//    try {
//      String url;
//      if (myHistoryPage == MyHistoryPage.MUTUAL) {
//        url = "/matches/all";
//      } else if (myHistoryPage == MyHistoryPage.LIKES) {
//        url = "/matches/like";
//      } else if (myHistoryPage == MyHistoryPage.MAYBE) {
//        url = "/matches/maybe";
//      } else if (myHistoryPage == MyHistoryPage.LIKED_ME) {
//        url = "/matches/liked-me";
//      } else if (myHistoryPage == MyHistoryPage.VIEWED_ME) {
//        url = "/matches/view";
//      }
//      print(url);
//      var res = await MyHttp.get(url);
//      print(res.statusCode);
//      print(res.body);
//      if (res.statusCode == 200) {
//        var body = json.decode(res.body);
//        print(body);
//        var data = body["matches"] ??
//            body["likes"] ??
//            body["maybes"] ??
//            body["users"] ??
//            body["views"] as List<dynamic>;
//        if (data != null && data.length > 0) {
//          for (int i = 0; i < data.length; i++) {
//            var d = data[i];
//            int id = -1; // na user id
//            String firstName = d["first_name"];
//            String image = d["ProfilePictureId"] ??
//                "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg";
//            int age = d["age"] ?? 24; // na
//            String location = d["location"] ?? "Chicago, IL";
//            String height = d["height"] ?? "5 11"; // na
//            String church = d["church"] ?? "The Church"; // na
//            var m1 =
//            MatchCard(id, image, firstName, age, location, height, church);
//            var t = myHistoryPage;
//            if (i % 2 == 0)
//              dummy1.add(t);
//            else
//              dummy2.add(t);
//          }
//        }
//        print(data);
//        setState(() {
//
//        });
//
//      }
//    } catch (e) {
//      print(e);
//    }
//  }

}
