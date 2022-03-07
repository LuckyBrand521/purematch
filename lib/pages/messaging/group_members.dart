import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/models/group_user.dart';
import 'package:pure_match/models/user.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import '../AppColors.dart';
import '../MyHttp.dart';

class GroupMembers extends StatefulWidget {
  final int chatId;

  const GroupMembers({Key key, @required this.chatId}) : super(key: key);
  @override
  _GroupMembersState createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String filter = "";
  List<GroupUser> _groupUsers = [];

  @override
  void initState() {
    _getMembers();
    // TODO: implement initState
    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);

    analytics.setCurrentScreen(
        screenName: "group_members", screenClassOverride: "group_members");

    amplitudeAnalytics.logEvent("group_members_page");

    super.initState();
  }

  void _removeMembers(int id) async {
    try {
      print(widget.chatId);
      print(id);
      var data = {};
      var res = await MyHttp.put("chat/${widget.chatId}/remove/$id", data);
      if (res.statusCode == 200) {
        var body = jsonDecode(res.body);
        print(body);
        // Analytics code
        analytics.logEvent(
            name: "removed_group_member",
            parameters: <String, dynamic>{
              'chat_id': widget.chatId.toString(),
              'user_id': id
            });

        amplitudeAnalytics.logEvent("removed_group_member", eventProperties: {
          'chat_id': widget.chatId.toString(),
          'user_id': id
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _getMembers() async {
    try {
      print("${widget.chatId}");
      var res = await MyHttp.get("chat/${widget.chatId}/members");
      print(res.statusCode);
      print(res.body);
      var body = json.decode(res.body);
      var friends = body["users"] as List<dynamic>;
      if (friends != null && friends.length > 0) {
        for (int i = 0; i < friends.length; i++) {
          var friend = friends[i];
          var u = GroupUser(User.fromJson(friend));
          this._groupUsers.add(u);
        }
        setState(() {});
      }
    } catch (e) {
      print("Get friends error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.blueColor,
        title: Text(
          "Group Members",
          style: TextStyle(color: Colors.white),
        ),
        //Todo analytics implement back button code that takes you from group member to group chat to messages
      ),
      body: SafeArea(
          child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          TextField(
            cursorColor: Colors.black,
            onChanged: (String f) {
              setState(() {
                filter = f;
              });
            },
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 50),
                prefixIcon: Icon(
                  Icons.search,
                  size: 24,
                  color: AppColors.blackColor,
                ),
                suffixIcon: InkWell(
                    child: Icon(
                  Icons.mic,
                  size: 24,
                  color: AppColors.blackColor,
                )),
                hintText: "Search",
                fillColor: AppColors.greyColor,
                filled: true,
                focusedBorder: new OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(10.0),
                    )),
                enabledBorder: new OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(50.0),
                    )),
                border: new OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(50.0),
                  ),
                )),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              child: ListView.builder(
                  itemCount: this._groupUsers.length,
                  itemBuilder: (c, i) {
                    var u = this._groupUsers[i];
                    if (filter.trim().isNotEmpty) {
                      if (u.u.fullName
                              .toLowerCase()
                              .contains(filter.toLowerCase()) ==
                          false) {
                        return Container();
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: (u.selected)
                            ? AppColors.noButtonColor
                            : Colors.white,
                        height: 70,
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: <Widget>[
                            ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: CachedNetworkImage(
                                  imageUrl: u.u.imageUrl ??
                                      "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text(
                              u.u.fullName ?? "",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )),
                            InkWell(
                                onTap: () {
                                  _alertUser(
                                      context,
                                      "Remove ${u.u.first_name} from the group?",
                                      "${u.u.first_name} will no longer be able to partcipate or receive notifications",
                                      "${u.u.first_name}",
                                      i);
                                },
                                child: Text(
                                  "Remove",
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: AppColors.redColor,
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ],
      )),
    );
  }

  void _alertUser(
      BuildContext context, String title, String content, String name, int i) {
    showDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(content,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
        material: (_, __) => MaterialAlertDialogData(
          elevation: 1.0,
          actions: <Widget>[
            Row(
              children: [
                TextButton(
                    child: Text("Remove",
                        style: TextStyle(
                            color: AppColors.communityProfileOptionsRedColor,
                            fontWeight: FontWeight.w600)),
                    onPressed: () {
                      // Update user model is friend request sent successfully
                      _removeMembers(_groupUsers[i].u.id);
                      _groupUsers.remove(_groupUsers[i]);

                      setState(() {});
                      Navigator.of(context).pop();
                      _warningUser(context, "User Removed",
                          "${name} has been removed from the group");
                    }),
              ],
            ),
            TextButton(
                child: Text("Report User",
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsRedColor,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  // Update user model is friend request sent successfully
                  Navigator.of(context).pop();

                  //Analytics tracking code
                  analytics.logEvent(
                      name: "reported_user",
                      parameters: <String, dynamic>{
                        'chat_id': widget.chatId.toString(),
                        "user_id": _groupUsers[i].u.id
                      });

                  amplitudeAnalytics.logEvent("reported_user",
                      eventProperties: {
                        'chat_id': widget.chatId.toString(),
                        "user_id": _groupUsers[i].u.id
                      });

                  _warningUser(context, "You have left the group",
                      "You will no longer be able to participate or receive notifications");
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
          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border(
                  top: BorderSide(color: Colors.black26, width: 1
                      // width: 3.0 --> you can set a custom width too!
                      ),
                )),
                child: CupertinoButton(
                  child: Text("Remove",
                      style: TextStyle(
                          color: AppColors.communityProfileOptionsRedColor,
                          fontWeight: FontWeight.w600)),
                  onPressed: () {
                    _removeMembers(_groupUsers[i].u.id);
                    _groupUsers.remove(_groupUsers[i]);
                    setState(() {});
                    Navigator.of(context).pop();
                    _warningUser(context, "User Removed",
                        "${name} has been removed from the Group.");
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
                  child: Text("Report User",
                      style: TextStyle(
                          color: AppColors.communityProfileOptionsRedColor,
                          fontWeight: FontWeight.w600)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    //Analytics tracking code
                    analytics.logEvent(
                        name: "reported_group_member",
                        parameters: <String, dynamic>{
                          'chat_id': widget.chatId.toString(),
                          "user_id": _groupUsers[i].u.id
                        });

                    amplitudeAnalytics.logEvent("reported_group_member",
                        eventProperties: {
                          'chat_id': widget.chatId.toString(),
                          "user_id": _groupUsers[i].u.id
                        });

                    _warningUser(context, "You have left the group",
                        "You will no longer be able to participate or receive notifications");
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
            ],
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
                child: Text("Continue",
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
            child: Text("Continue",
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
