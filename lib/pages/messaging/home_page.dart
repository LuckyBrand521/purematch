import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/friend_request_list.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/feed/feed_base.dart';
import 'package:pure_match/pages/feed/feed_base_enum.dart';
import 'package:pure_match/pages/match/browse_match.dart';
import 'package:pure_match/pages/messaging/message_base_page.dart';
import 'package:pure_match/pages/own_profile/my_profile.dart';
import 'package:pure_match/pages/shop/rewards_base.dart';

import '../MyHttp.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

class HomePage extends StatefulWidget {
  // For message PN
  int userId;
  int chatId;
  String status;
  String otherUserName;
  String messageType;
  bool isShop;
  // For message PN end

  // For post PN
  int postId;
  // For post PN end

  // For post PN
  String matchType;
  // For post PN end

  bool isFriendRequest;
  int tabIndex;
  // bool ownProfileSaved = Global.ownProfileSaved;
  final BaseFeedEnum baseFeedEnum;
  HomePage(
      {tabIndex,
      this.baseFeedEnum,
      isFriendRequest,
      userId,
      chatId,
      status,
      otherUserName,
      messageType,
      postId,
      matchType,
      isShop}) {
    this.tabIndex = tabIndex ?? 0;
    // this.ownProfileSaved = ownProfileSaved ?? false;
    this.isFriendRequest = isFriendRequest ?? false;
    this.userId = userId ?? 0;
    this.chatId = chatId ?? 0;
    this.status = status ?? "";
    this.otherUserName = otherUserName ?? "";
    this.messageType = messageType ?? "";
    this.postId = postId ?? 0;
    this.matchType = matchType ?? "";
    this.isShop = isShop ?? false;
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int i;
  List<dynamic> tabs;
  FriendRequestList frl;

  List<FriendRequestList> friendrequest = [];

  BaseFeedEnum baseFeedEnum = BaseFeedEnum.MY_FEED;
  void onSelectOptionFriendRequest(index) {
    _setBadger();
    setState(() {});
  }

  void onSelectedFeedNotification(index) {
    _setBadger();
    setState(() {});
  }

  void onChangedUnreadChatCount(index) {
    _setBadger();
    setState(() {});
  }

  @override
  void initState() {
    getInit();

    super.initState();
  }

  getInit() async {
    i = widget.tabIndex;
    if (Global.currentUser == null) {
      await _getUser();
      await _getUnreadChat();
      await _getfriendRequest();
      await _getUnreadFeedNotification();
    }

    baseFeedEnum = widget.baseFeedEnum ?? BaseFeedEnum.MY_FEED;
    if (widget.isFriendRequest == true) {
      baseFeedEnum = BaseFeedEnum.FRIENDS;
    }
    if (widget.postId != 0) {
      baseFeedEnum = BaseFeedEnum.MY_FEED;
    }

    tabs = [
      FeedBase(
        baseFeedEnum: baseFeedEnum,
        isFriendRequest: widget.isFriendRequest,
        onSelectedOptionFriendRequest: onSelectOptionFriendRequest,
        onSelectedFeedNotification: onSelectedFeedNotification,
        postId: widget.postId,
      ),
      (widget.matchType != "" && widget.userId != 0)
          ? BrowseMatch(
              userId: widget.userId,
              matchType: widget.matchType,
            )
          : BrowseMatch(),
      (widget.messageType != null && widget.messageType != "")
          ? MessageBasePage(
              onChangedUnreadChatCount: onChangedUnreadChatCount,
              userId: widget.userId,
              chatId: widget.chatId,
              status: widget.status,
              otherUserName: widget.otherUserName,
              messageType: widget.messageType,
            )
          : MessageBasePage(
              onChangedUnreadChatCount: onChangedUnreadChatCount,
            ),
      RewardsBase(
        isShop: widget.isShop,
      ),
      MyProfile()
    ];

    //Analytics tracking code
    if (i == 2) {
      amplitudeAnalytics.init(apiKey);
      analytics.setCurrentScreen(
          screenName: "messages_all", screenClassOverride: "messages_all");
      amplitudeAnalytics.logEvent("messages_all_page");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = 32;

    return Scaffold(
      body: tabs == null || tabs.length <= i
          ? Center(child: PlatformCircularProgressIndicator())
          : tabs[i],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.greyColor,
        currentIndex: i,
        iconSize: 24,
        items: [
          (Global.unreadFriendRequestCount +
                      Global.unreadFeedNotificationCount >
                  0)
              ? BottomNavigationBarItem(
                  icon: Badge(
                    badgeContent: Text(
                      (Global.unreadFriendRequestCount +
                              Global.unreadFeedNotificationCount)
                          .toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    child: Image(
                      image: AssetImage("assets/images/nav_feed_inactive.png"),
                      height: iconSize,
                    ),
                  ),
                  activeIcon: Badge(
                    badgeContent: Text(
                      (Global.unreadFriendRequestCount +
                              Global.unreadFeedNotificationCount)
                          .toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    child: Image(
                      image: AssetImage("assets/images/nav_feed_active.png"),
                      height: iconSize,
                    ),
                  ),
                  title: Text(""),
                )
              : BottomNavigationBarItem(
                  icon: Image(
                    image: AssetImage("assets/images/nav_feed_inactive.png"),
                    height: iconSize,
                  ),
                  title: Text(""),
                  activeIcon: Image(
                    image: AssetImage("assets/images/nav_feed_active.png"),
                    height: iconSize,
                  ),
                ),
          BottomNavigationBarItem(
            icon: Image(
              image: AssetImage("assets/images/nav_match_inactive.png"),
              height: iconSize,
            ),
            activeIcon: Image(
              image: AssetImage("assets/images/match_icon_active.png"),
              height: iconSize,
            ),
            title: Text(""),
          ),
          (Global.unreadChatsCount != 0)
              ? BottomNavigationBarItem(
                  icon: Badge(
                    badgeContent: Text(
                      Global.unreadChatsCount.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    child: Image(
                      image: AssetImage(
                          "assets/images/nav_messaging_inactive.png"),
                      height: 40,
                    ),
                  ),
                  title: Text(""),
                  activeIcon: Badge(
                    badgeContent: Text(
                      Global.unreadChatsCount.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    child: Image(
                      image:
                          AssetImage("assets/images/nav_messaging_active.png"),
                      height: 40,
                    ),
                  ),
                )
              : BottomNavigationBarItem(
                  icon: Image(
                    image:
                        AssetImage("assets/images/nav_messaging_inactive.png"),
                    height: 40,
                  ),
                  title: Text(""),
                  activeIcon: Image(
                    image: AssetImage("assets/images/nav_messaging_active.png"),
                    height: 40,
                  )),
          BottomNavigationBarItem(
            icon: Image(
              image: AssetImage("assets/images/nav_gem_inactive.png"),
              height: iconSize,
            ),
            activeIcon: Image(
              image: AssetImage("assets/images/nav_gem_active.png"),
              height: iconSize,
            ),
            title: Text(""),
          ),
          (Global.currentUser?.imageUrl != null &&
                  Global.currentUser?.imageUrl.isNotEmpty &&
                  Global.currentUser?.imageUrl != "na")
              ? BottomNavigationBarItem(
                  icon: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: ColorFiltered(
                        colorFilter: false
                            ? ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              )
                            : ColorFilter.mode(
                                Colors.grey,
                                BlendMode.saturation,
                              ),
                        child: (Global.currentUser?.imageUrl != null &&
                                Global.currentUser?.imageUrl.isNotEmpty &&
                                Global.currentUser?.imageUrl != "na")
                            ? CachedNetworkImage(
                                width: 35,
                                height: 35,
                                imageUrl: Global.currentUser?.imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              )
                            : Container(),
                      )),
                  title: Text(""),
                  activeIcon: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: ColorFiltered(
                        colorFilter: true
                            ? ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              )
                            : ColorFilter.mode(
                                Colors.grey,
                                BlendMode.saturation,
                              ),
                        child: CachedNetworkImage(
                          width: 35,
                          height: 35,
                          imageUrl: Global.currentUser?.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      )))
              : BottomNavigationBarItem(
                  icon: Icon(Icons.person, size: iconSize),
                  title: Text(""),
                )
        ],
        onTap: (index) {
          if (index == 0) {
            baseFeedEnum = BaseFeedEnum.MY_FEED;
            tabs[0] = FeedBase(
              baseFeedEnum: baseFeedEnum,
              isFriendRequest: widget.isFriendRequest,
              onSelectedOptionFriendRequest: onSelectOptionFriendRequest,
              onSelectedFeedNotification: onSelectedFeedNotification,
              postId: widget.postId,
            );
          }
          setState(() {
            i = index;
          });
          //Analytics tracking code
          if (index == 2) {
            analytics.setCurrentScreen(
                screenName: "messages_all",
                screenClassOverride: "messages_all");

            amplitudeAnalytics.logEvent("messages_all_page");
          }
        },
      ),
    );
  }

  void _getUser() async {
    try {
      Global.currentUser = await MyHttp.getUserDetails();
      if (Global.currentUser.imageUrl != null &&
          Global.currentUser.imageUrl != "na") {
        Global.hasProfileImg = true;
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  _getUnreadChat() async {
    try {
      var res = await MyHttp.get("/chat/unread/all");
      if (res.statusCode == 200) {
        var jsonData = jsonDecode(res.body);
        print(jsonData);
        if (jsonData["numberOfChats"] != null) {
          Global.unreadChatsCount = jsonData["numberOfChats"];
          setState(() {});
        } else {
          Global.unreadChatsCount = 0;
          setState(() {});
        }
        _setBadger();
      } else {
        print(res.statusCode);
      }
    } catch (e) {
      print("Err $e");
    }
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
        _setBadger();
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
        _setBadger();
        print(jsonData);
      }
      setState(() {});
    } catch (e) {}
  }

  void _setBadger() {
    FlutterAppBadger.updateBadgeCount(Global.unreadChatsCount +
        Global.unreadFeedNotificationCount +
        Global.unreadFriendRequestCount);
  }
}
