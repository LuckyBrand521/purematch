import 'package:flutter/material.dart';
import 'package:pure_match/common/feed_drawer.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/feed/my_activity.dart';
import 'package:pure_match/pages/feed/search_feed.dart';
import 'package:pure_match/pages/rewards/plan.dart';
import 'package:pure_match/pages/settings/settings_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pure_match/common/triangle.dart';

class MyFeed extends StatefulWidget {
  final int postId;
  MyFeed({Key key, this.postId}) : super(key: key);
  @override
  _MyFeedState createState() => _MyFeedState();
}

class _MyFeedState extends State<MyFeed> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      drawer: FeedDrawer(
        openPageType: DrawerPage.MY_FEED,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.yellowColor,
        title: Text(
          "Community",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
        ),
        leading: Global.getHamburgerMenuBar(() {
          _scaffoldKey.currentState.openDrawer();
        },
            Global.unreadFriendRequestCount +
                Global.unreadFeedNotificationCount),
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
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MainSettings()));

              // Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => Plan()));
            },
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: SizedBox(
                width: 35,
                height: 31,
                child: Image.asset(
                  "assets/images/setting_logo.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: MyActivity(
            feedType: FeedType.My_FEED,
            postId: widget.postId,
          ),
        ),
      ),
    );
  }
}
