import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/models/group_user.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/messaging/group_chat_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

import '../AppColors.dart';

class AddGroupMember extends StatefulWidget {
  String title;
  int chatId;
  AddGroupMember({this.title, this.chatId});
  @override
  _AddGroupMemberState createState() => _AddGroupMemberState();
}

class _AddGroupMemberState extends State<AddGroupMember> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  List<GroupUser> _alreadyaddedUsers = [];
  List<GroupUser> _groupUsers = [];

  List<dynamic> groupMembers = [];
  List<int> chosenMembers = [];
  List<int> chosenMemberIds = [];
  List<String> names = [];
  String filter = "";

  @override
  void initState() {
    _getMembers();
    //Analytics code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "add_group_member",
        screenClassOverride: "add_group_member");
    amplitudeAnalytics.logEvent("add_group_member_page");

    // TODO: implement initState
    super.initState();
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
          this._alreadyaddedUsers.add(u);
        }
      }
      print("****");
      print(_alreadyaddedUsers);
      _getnewGroupMembers();

      setState(() {});
    } catch (e) {
      print("Get friends error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.blueColor,
          title: Text(widget.title, style: TextStyle(color: Colors.white)),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <
            Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: AppColors.redColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Avenir Next'),
                ),
              ),
              Text(
                "Add Group Members",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Avenir Next'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _addNewMember(widget.chatId);
                },
                child: Text(
                  "Done",
                  style: TextStyle(
                      color: chosenMembers.length > 0
                          ? AppColors.blueColor
                          : AppColors.offWhiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Avenir Next'),
                ),
              ),
            ],
          ),
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
          (this.chosenMembers.isNotEmpty)
              ? Row(children: _getChosenList())
              : Container(),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: this._groupUsers.length,
                itemBuilder: (c, i) {
                  var u = this._groupUsers[i];

                  if (filter.trim().isNotEmpty) {
                    if (u.u.fullName.startsWith(filter.trim()) == false) {
                      return Container();
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.white,
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
                            u.u.first_name ?? "",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                          (u.selected)
                              ? MaterialButton(
                                  height: 35,
                                  minWidth: 35,
                                  onPressed: () {
                                    setState(() {
                                      if (u.selected) {
                                        this.chosenMembers.remove(i);
                                        names.remove(u.u.first_name);
                                      } else {
                                        this.chosenMembers.add(i);
                                        names.add(u.u.first_name);
                                        print(names);
                                      }
                                      u.selected = !u.selected;
                                      print(
                                          "Chosend length: ${chosenMembers.length}");
                                    });
                                  },
                                  color: AppColors.blueColor,
                                  textColor: Colors.white,
                                  padding: EdgeInsets.all(16),
                                  shape: CircleBorder(),
                                )
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (u.selected) {
                                        this.chosenMembers.remove(i);
                                        names.remove(u.u.first_name);
                                        chosenMemberIds.remove(u.u.id);
                                      } else {
                                        this.chosenMembers.add(i);
                                        names.add(u.u.first_name);
                                        chosenMemberIds.add(u.u.id);
                                      }
                                      u.selected = !u.selected;
                                      print(
                                          "Chosend length: ${chosenMembers.length}");
                                    });
                                  },
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100)),
                                        border: Border.all(
                                            width: 3,
                                            color: Colors.black26,
                                            style: BorderStyle.solid)),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ]));
  }

  void _getnewGroupMembers() async {
    try {
      //   var res = await MyHttp.get("chat/${widget.chatId}/search-friends");
      var res = await MyHttp.get("chat/users/list");
      print(res.statusCode);
      print(res.body);
      var body = json.decode(res.body);
      var friends = body["users"] as List<dynamic>;
      if (friends != null && friends.length > 0) {
        for (int i = 0; i < friends.length; i++) {
          var friend = friends[i];
          var u = GroupUser(User.fromJson(friend));
          if (_alreadyaddedUsers.contains(u) == false) {
            _groupUsers.add(u);
          }
        }
      }
      setState(() {});
    } catch (e) {
      print("Get friends error $e");
    }
  }

  void _addNewMember(int chatId) async {
    try {
      var data = {"userIds": chosenMemberIds};

      var res = await MyHttp.put("/chat/${chatId}/add", data);
      print(res.statusCode);
      print(res.body);
      if (res.statusCode == 200) {
        //      Navigator.of(context).pop();
        // Analytics code
        analytics
            .logEvent(name: "added_group_member", parameters: <String, dynamic>{
          'group_name': widget.title,
          'chat_id': widget.chatId.toString(),
          'user_ids': data['userIds']
        });

        amplitudeAnalytics.logEvent("added_group_member", eventProperties: {
          'group_name': widget.title,
          'chat_id': widget.chatId.toString(),
          'user_ids': data['userIds']
        });

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => GroupChatPage(
                      chatId: widget.chatId,
                      status: "Active",
                      newUser: _groupUsers[chosenMembers[0]].u.first_name,
                      memberAdded: true,
                      names: names,
                    )));
      } else {
        print("unable to add ${res.statusCode}");
      }

      setState(() {});
    } catch (e) {
      print("Get friends error $e");
    }
  }

  List<Widget> _getChosenList() {
    List<Widget> row = [];
    row.add(SizedBox(
      width: 20,
    ));
    for (int i = 0; i < chosenMembers.length; i++) {
      row.add(SizedBox(
        height: 90,
        width: 60,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 50,
                  width: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: _groupUsers[chosenMembers[i]].u.imageUrl == null
                        ? Image(
                            image: AssetImage("assets/images/logo.png"),
                          )
                        : Image(
                            image: NetworkImage(
                              _groupUsers[chosenMembers[i]].u.imageUrl,
                            ),
                          ),
                  ),
                ),
                Align(
                  alignment: Alignment(4.5, -4),
                  child: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        chosenMemberIds.remove(_groupUsers[i]);
                        chosenMembers.remove(_groupUsers[i]);
                      }),
                ),
              ],
            ),
            FittedBox(
              child: Text(
                _groupUsers[chosenMembers[i]].u.first_name,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Avenir Next'),
              ),
            ),
          ],
        ),
      ));
      row.add(SizedBox(
        width: 5,
      ));
    }
    return row;
  }
}
