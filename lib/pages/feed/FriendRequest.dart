import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/loading.dart';
import 'package:pure_match/models/friend_request_list.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/community_profile/community_profile.dart';
import 'package:pure_match/pages/feed/friends_feed.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

import '../MyHttp.dart';

class FriendsRequest extends StatefulWidget {
  final FriendType friendsType;
  final Function(int) selectFriendOption;
  const FriendsRequest({Key key, this.friendsType, this.selectFriendOption})
      : super(key: key);
  @override
  _FriendsRequestState createState() => _FriendsRequestState();
}

class _FriendsRequestState extends State<FriendsRequest> {
  bool _loading = false;
  FriendRequestList frl;
  List<FriendRequestList> friendrequest = [];
  List<FriendRequestList> acceptedFriendRequest = [];
  List<FriendRequestList> declineFriendRequest = [];

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  void initState() {
    _getfriendRequest();
    // TODO: implement initState
    super.initState();
  }

  void _getfriendRequest() async {
    setState(() {
      _loading = true;
    });
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
        print(friendrequest);
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {}
  }

  void _acceptfriendRequest(FriendRequestList friendRequestList) async {
    try {
      var data = {};

      var res =
          await MyHttp.post("friends/add/${friendRequestList.senderId}", data);
      if (res.statusCode == 200 || res.statusCode == 201) {
        //Analytics code
        analytics.logEvent(
            name: "accepted_friend_request",
            parameters: <String, dynamic>{
              "sender_id": friendRequestList.senderId,
              "receiver_id": friendRequestList.id
            });
        amplitudeAnalytics.logEvent('accepted_friend_request',
            eventProperties: {
              "sender_id": friendRequestList.senderId,
              "receiver_id": friendRequestList.id
            });

        var jsonData = jsonDecode(res.body);
        acceptedFriendRequest.add(friendRequestList);
        print(jsonData);
        if (Global.unreadFriendRequestCount > 0) {
          Global.unreadFriendRequestCount = Global.unreadFriendRequestCount - 1;
        } else {
          Global.unreadFriendRequestCount = 0;
        }
        widget.selectFriendOption(1);
        setState(() {});
      }
      print(res.statusCode);
    } catch (e) {}
  }

  void _declinefriendRequest(FriendRequestList friendRequestList) async {
    try {
      var data = {"friendRequestId": friendRequestList.id};

      var res = await MyHttp.put("friends/decline/", data);
      if (res.statusCode == 200 || res.statusCode == 201) {
        //Analytics code
        analytics.logEvent(
            name: "declined_friend_request",
            parameters: <String, dynamic>{
              "sender_id": friendRequestList.senderId,
              "other_id": friendRequestList.id
            });
        amplitudeAnalytics.logEvent('declined_friend_request',
            eventProperties: {
              "sender_id": friendRequestList.senderId,
              "other_id": friendRequestList.id
            });

        var jsonData = jsonDecode(res.body);
        declineFriendRequest.add(friendRequestList);
        print(jsonData);
        if (Global.unreadFriendRequestCount > 0) {
          Global.unreadFriendRequestCount = Global.unreadFriendRequestCount - 1;
        } else {
          Global.unreadFriendRequestCount = 0;
        }
        widget.selectFriendOption(0);
        setState(() {});
      }
      print(res.statusCode);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyColor,
      body:
          SafeArea(child: (this._loading) ? Loading.showLoading() : Friends()),
    );
  }

  Widget Friends() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: (friendrequest.isEmpty)
              ? Center(
                  child: Text(
                  "No Friend Request.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ))
              : ListView.builder(
                  itemCount: friendrequest.length,
                  itemBuilder: (c, i) {
                    var u = this.friendrequest[i];
                    return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CommunityProfile(
                                    userId: u.senderId,
                                  )));
                        },
                        child: FriendRequestTile(u));
                  }),
        )
      ],
    );
  }

  Widget FriendRequestTile(FriendRequestList fr) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: <Widget>[
            (fr.sender.profilePicture != null &&
                    fr.sender.profilePicture.isNotEmpty &&
                    fr.sender.profilePicture != "na")
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: CachedNetworkImage(
                      width:
                          AppConfig.heightWithDForSmallDevice(context, 60, 20),
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 60, 20),
                      imageUrl: fr.sender.profilePicture,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ))
                : Icon(Icons.person,
                    size: (AppConfig.fullWidth(context) >= 375) ? 60 : 40),
            SizedBox(
              width: AppConfig.heightWithDForSmallDevice(context, 10, 5),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    Global.getFullName(fr.sender.firstName, fr.sender.lastName),
                    style: TextStyle(
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 16),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Visibility(
                  visible: (fr.mutualConnections > 0),
                  child: Text(
                    (fr.mutualConnections > 1)
                        ? fr.mutualConnections.toString() +
                            " mutual Connections"
                        : fr.mutualConnections.toString() +
                            " mutual Connection",
                    style: TextStyle(
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 10),
                        fontWeight: FontWeight.w200),
                  ),
                )
              ],
            ),
            Spacer(),
            Visibility(
              visible: acceptedFriendRequest.contains(fr) != true &&
                  declineFriendRequest.contains(fr) != true,
              child: Row(
                children: <Widget>[
                  Container(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 30, 10),
                    width: AppConfig.heightWithDForSmallDevice(context, 80, 15),
                    color: AppColors.matchBrowseMatchReactivateMatching,
                    child: TextButton(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: FittedBox(
                            child: Text(
                          "Accept",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  AppConfig.fontsizeForSmallDevice(context, 16),
                              fontWeight: FontWeight.w600),
                        )),
                      ),
                      onPressed: () {
                        _acceptfriendRequest(fr);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Visibility(
                        visible: declineFriendRequest.contains(fr) != true &&
                            acceptedFriendRequest.contains(fr) != true,
                        child: Container(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 30, 10),
                          width: AppConfig.heightWithDForSmallDevice(
                              context, 80, 15),
                          color: AppColors.greyColor,
                          child: TextButton(
                            child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: FittedBox(
                                  child: Text(
                                    "Decline",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            (AppConfig.fullHeight(context) >=
                                                    667)
                                                ? 15
                                                : 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )),
                            onPressed: () {
                              _declinefriendRequest(fr);
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Visibility(
              visible: acceptedFriendRequest.contains(fr) == true,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      "Request Accepted.",
                      style: TextStyle(
                        color: AppColors.matchBrowseMatchReactivateMatching,
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 15, 3),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Visibility(
              visible: declineFriendRequest.contains(fr) == true,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      "Request Declined",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 15, 3),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
