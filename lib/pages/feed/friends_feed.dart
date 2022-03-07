import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/loading.dart';
import 'package:pure_match/models/my_friends.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/community_profile/community_profile.dart';

import '../MyHttp.dart';

enum FriendType { FRIENDS, FRIEND_REQUEST }

class FriendsFeed extends StatefulWidget {
  final FriendType friendsType;

  const FriendsFeed({Key key, this.friendsType}) : super(key: key);
  @override
  _FriendsFeedState createState() => _FriendsFeedState();
}

class _FriendsFeedState extends State<FriendsFeed> {
  bool _loading = false;
  List<MyFriends> _friends = [];
  MyFriends frd;

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  void initState() {
    _getfriends();
    // TODO: implement initState
    super.initState();

    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyColor,
      body: SafeArea(
        child: (this._loading) ? Loading.showLoading() : FriendsList(),
      ),
    );
  }

  void _getfriends() async {
    setState(() {
      _loading = true;
    });
    try {
      var res = await MyHttp.get("friends/my-friends");
      if (res.statusCode == 200 || res.statusCode == 201) {
        var jsonData = jsonDecode(res.body);
        var friend = jsonData["friends"];
        print(friend);
        if (friend != null) {
          for (var p in friend) {
            frd = MyFriends.fromJson(p);
            // _friends.add(friend);
            _friends.add(frd);
          }
        }
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void _unfriend(MyFriends friends) async {
    try {
      var data = {};
      var res = await MyHttp.post("/friends/unfriend/${friends.id}", data);
      if (res.statusCode == 200 || res.statusCode == 201) {
        //Analytics code
        analytics.logEvent(
            name: "unfriend",
            parameters: <String, dynamic>{"friend_id": friends.id});
        amplitudeAnalytics
            .logEvent('unfirend', eventProperties: {"friend_id": friends.id});

        _friends.remove(friends);
        _warningUser(context, "Friendship Ended!",
            "User Has been removed from your friends");
      }
      print(res.statusCode);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Widget FriendsList() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: (_friends.length == 0)
              ? Center(
                  child: Text(
                  "No Friends.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ))
              : ListView.builder(
                  itemCount: _friends.length,
                  itemBuilder: (c, i) {
                    var u = this._friends[i];
                    return InkWell(
                      onTap: () {
                        print("${u.id}");
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CommunityProfile(
                                  userId: u.id,
                                )));
                      },
                      child: FriendListTile(u),
                    );
                  }),
        )
      ],
    );
  }

  Widget FriendListTile(MyFriends friends) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: (friends.ProfilePictureId != null &&
                        friends.ProfilePictureId.isNotEmpty &&
                        friends.ProfilePictureId != "na")
                    ? CachedNetworkImage(
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        imageUrl: friends.ProfilePictureId,
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )
                    : Icon(Icons.person, size: 60)),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Global.getFullName(friends.first_name, friends.last_name),
                  style: TextStyle(
                      fontSize: AppConfig.fontsizeForSmallDevice(context, 16),
                      fontWeight: FontWeight.w500),
                ),
                Visibility(
                  visible: (friends.mutualConnections > 0),
                  child: Text(
                    (friends.mutualConnections > 1)
                        ? friends.mutualConnections.toString() +
                            " mutual Connections"
                        : friends.mutualConnections.toString() +
                            " mutual Connection",
                    style: TextStyle(
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 10),
                        fontWeight: FontWeight.w200),
                  ),
                )
              ],
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: AppColors.offWhiteColor,
                size: 35,
              ),
              onPressed: () {
                _alertUser(
                    context,
                    "Are you sure you want to Unfriend?",
                    Global.getFullName(friends.first_name, friends.last_name) +
                        " will be removed from your friends",
                    "Unfriend",
                    friends);
              },
            )
          ],
        ),
      ),
    );
  }

  void _alertUser(BuildContext context, String title, String content,
      String button, MyFriends friends) {
    showDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(content,
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w300, height: 1.5)),
        material: (_, __) => MaterialAlertDialogData(
          elevation: 1.0,
          actions: <Widget>[
            TextButton(
                child: Text(button,
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsRedColor,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  Navigator.of(context).pop();
                  _unfriend(friends);
                  // Update user model is friend request sent successfully
                }),
            TextButton(
                child: Text("Cancel",
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsBlueColor,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  // Update user model is friend request sent successfully
                  Navigator.of(context).pop();
                }),
          ],
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border(
              top: BorderSide(color: Colors.black26, width: 1
                  // width: 3.0 --> you can set a custom width too!
                  ),
            )),
            child: CupertinoButton(
              child: Text(button,
                  style: TextStyle(
                      color: AppColors.communityProfileOptionsRedColor,
                      fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
                _unfriend(friends);
              },
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border(
              top: BorderSide(color: Colors.black26, width: 1
                  // width: 3.0 --> you can set a custom width too!
                  ),
            )),
            child: CupertinoButton(
              child: Text("Cancel",
                  style: TextStyle(
                      color: AppColors.communityProfileOptionsBlueColor,
                      fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {
      print(value);
    });
  }

  void _warningUser(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(content,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
        material: (_, __) => MaterialAlertDialogData(
          elevation: 1.0,
          actions: <Widget>[
            TextButton(
                child: Text("Ok",
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsBlueColor,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  // Update user model is friend request sent successfully
                  Navigator.of(context).pop();
                }),
          ],
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
          CupertinoButton(
            child: Text("Ok",
                style: TextStyle(
                    color: AppColors.communityProfileOptionsBlueColor,
                    fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {
      print(value);
    });
  }
}

//class Friends {
//  int id;
//  String first_name;
//  String last_name;
//  String ProfilePictureId;
//
//  Friends(this.id, this.first_name, this.last_name, this.ProfilePictureId);
//
//  Friends.fromJson(Map<String,dynamic>json){
//    Friends(
//      this.id=json["id"]??1,
//      this.first_name=json["first_name"]??"New",
//      this.last_name=json["last_name"]??" User",
//      this.ProfilePictureId=json["ProfilePictureId"],
//
//    );
//  }
//
//
//
//}
