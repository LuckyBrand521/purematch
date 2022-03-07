import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/common/feed_drawer.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/feed_notification.dart';

import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'feed_detail.dart';

class FeedNotification extends StatefulWidget {
  final Function(int) selectFeedNotification;
  FeedNotification({this.selectFeedNotification}) {}
  @override
  _FeedNotificationState createState() => _FeedNotificationState();
}

class _FeedNotificationState extends State<FeedNotification> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  List<FeedNotificationData> arrNotifications = [];

  void _getData() async {
    arrNotifications.clear();
    try {
      var res = await MyHttp.get("/users/feed-notifications");
      print(res.statusCode);
      print("NOTI");
      print(res.body);
      var body = json.decode(res.body);
      var notifications = body["notificationsArr"];
      for (var p in notifications) {
        FeedNotificationData frl = FeedNotificationData.fromJson(p);
        arrNotifications.add(frl);
      }
      print("Noti");
      if (this.mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Get dat aerr: $e");
    }
  }

  @override
  void initState() {
    this._getData();
    super.initState();
    //Analytics code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: 'notification', screenClassOverride: 'notification');
    amplitudeAnalytics.logEvent("notification_page");
  }

  String getSubString(String str, String subString) {
    final startIndex = str.indexOf(subString);
    return str.substring(startIndex + subString.length);
  }

  Future<void> readNotifiction(
      FeedNotificationData notification, int index) async {
    if (notification.isRead) {
      goNextView(notification);
      return;
    }
    List notificationIds = [notification.notification_id];
    final data = {"notification_ids": notificationIds};
    try {
      var res = await MyHttp.post("/users/read-notification", data);
      print(res.statusCode);
      if (res.statusCode == 200) {
        notification.isRead = true;
        this.arrNotifications.removeAt(index);
        this.arrNotifications.insert(index, notification);
        setState(() {});
        if (Global.unreadFeedNotificationCount > 0) {
          Global.unreadFeedNotificationCount =
              Global.unreadFeedNotificationCount - 1;
        } else {
          Global.unreadFeedNotificationCount = 0;
        }
        widget.selectFeedNotification(Global.unreadFeedNotificationCount);
        goNextView(notification);
      }
    } catch (e) {}
  }

  Future<void> _readAllNotifications() async {
    List notificationIds = [];
    for (int i = 0; i < arrNotifications.length; i++) {
      var notification = arrNotifications[i];
      if (notification.isRead == false) {
        notificationIds.add(notification.notification_id);
      }
    }
    if (notificationIds.length > 0) {
      final data = {"notification_ids": notificationIds};
      print("data=${data}");
      try {
        var res = await MyHttp.post("/users/read-notification", data);
        print(res.statusCode);
        if (res.statusCode == 200) {
          if (Global.unreadFeedNotificationCount > notificationIds.length) {
            Global.unreadFeedNotificationCount =
                Global.unreadFeedNotificationCount - notificationIds.length;
          } else {
            Global.unreadFeedNotificationCount = 0;
          }
          widget.selectFeedNotification(Global.unreadFeedNotificationCount);
          _getData();
        }
      } catch (e) {}
    }
  }

  goNextView(FeedNotificationData notification) {
    if (notification.type == "post") {
      print("like");
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => CommunityProfile(
      //               userId: notification.id,
      //             ))).then((value) => this._getData());
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FeedDetail(
                    postId: notification.subId,
                  ))).then((v) {
        this._getData();
      });
    } else if (notification.type == "comment") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FeedDetail(
                    postId: notification.id,
                  ))).then((v) {
        this._getData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: FeedDrawer(openPageType: DrawerPage.NOTIFICATION),
      appBar: AppBar(
        backgroundColor: AppColors.yellowColor,
        title: Text(
          "Notifications",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
        ),
      ),
      body: (this.arrNotifications == null || this.arrNotifications.length == 0)
          ? Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                    child: Text(
                  "No new notifications",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.offWhiteColor),
                )),
              ],
            )
          : RefreshIndicator(
              onRefresh: _readAllNotifications,
              child: Container(
                child: ListView.builder(
                    itemCount: arrNotifications.length,
                    itemBuilder: (c, i) {
                      var d = arrNotifications[i];
                      return Container(
                        child: InkWell(
                          onTap: () {
                            this.readNotifiction(d, i);
                          },
                          child: Container(
                            color: (d.isRead)
                                ? Colors.white
                                : AppColors.noButtonColor,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      border: Border.all(
                                        width: 2,
                                        color: (d.type == "Like")
                                            ? AppColors.redColor
                                            : AppColors
                                                .matchBrowseMatchReactivateMatching,
                                      ),
                                    ),
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: CachedNetworkImage(
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          imageUrl: d?.sender?.profilePicture ??
                                              "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 5,
                                        ),
                                        RichText(
                                          text: TextSpan(
                                              text: Global.getFullName(
                                                  d.sender.firstName,
                                                  d.sender.lastName),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.blackColor,
                                                  fontSize: 16),
                                              children: [
                                                TextSpan(
                                                    text: getSubString(
                                                        d.message, "Someone"),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: AppColors
                                                            .blackColor,
                                                        fontSize: 14))
                                              ]),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          d.createdAt ?? "Today at 3:30pm",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // (d?.sender?.profilePicture != null)
                                  //     ? CachedNetworkImage(
                                  //         width: 50,
                                  //         imageUrl: d?.sender?.profilePicture ??
                                  //             "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                  //         errorWidget: (context, url, error) =>
                                  //             Icon(Icons.error),
                                  //       )
                                  //     :
                                  Container()
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
    );
  }
}
