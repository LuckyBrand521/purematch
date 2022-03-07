import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/models/group_user.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/messaging/chat_base_page.dart';
import 'package:pure_match/pages/messaging/group_chat_page.dart';
import 'package:pure_match/pages/messaging/message_page.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/settings/settings_main.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'dart:convert';
import '../../routes.dart';

class MessageBasePage extends StatefulWidget {
  // final int chatId;
  // For message PN
  int userId;
  int chatId;
  String status;
  String otherUserName;
  String messageType;
  // For message PN end
  final Function(int) onChangedUnreadChatCount;
  MessageBasePage(
      {Key key,
      this.onChangedUnreadChatCount,
      this.userId,
      this.chatId,
      this.status,
      this.otherUserName,
      this.messageType})
      : super(key: key);

  @override
  _MessageBasePageState createState() => _MessageBasePageState();
}

class _MessageBasePageState extends State<MessageBasePage>
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
  String filter = "";

  int i = 0;
  List<GroupUser> _groupUsers = [];

  List<dynamic> groupMembers = [];
  List<int> chosenMembers = [];
  List<int> chosenMemberIds = [];
  List<String> names = [];

//  void _getGroupMembers() async {
//    var res = await MyHttp.get("chat/users/list");
//    var json = jsonDecode(res.body);
//    groupMembers = json["users"];
//    print("=============================this is $groupMembers");
//  }

  void _createGroupChat() async {
    print(chosenMemberIds);
    try {
      var data = {"userIds": chosenMemberIds};
      var res = await MyHttp.post("/chat/group-chat", data);

      if (res.statusCode == 201) {
        var body = jsonDecode(res.body);
        print(body);
        var chatId = body["newChat"]["id"];
        var title = body["newChat"]["group_name"];
        //Analytics code
        analytics.logEvent(
            name: "created_group_chat",
            parameters: <String, dynamic>{
              'group_name': title,
              'chat_id': chatId
            });

        amplitudeAnalytics.logEvent("created_group_chat",
            eventProperties: {'group_name': title, 'chat_id': chatId});

        var status = body["newChat"]["status"];
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GroupChatPage(
                      newGroup: true,
                      names: names,
                      chatId: chatId,
                      title: title,
                      status: status,
                    )));
      } else {
        print(res.statusCode);
      }
    } catch (e) {
      print(e);
    }
  }

  void _createChat(GroupUser user) async {
    try {
      var data = {"userId": user.u.id};
      var res = await MyHttp.post("/chat/", data);
      if (res.statusCode == 200) {
        var body = jsonDecode(res.body);
        var chatId = body["chat"]["id"];
        var status = body["chat"]["status"];
        print(body);
        print(chatId);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatBasePage(
                      userId: user.u.id,
                      chatId: chatId,
                      otherUserName: user.u.fullName,
                      status: status,
                    )));
      }
    } catch (e) {
      print(e);
    }
  }

  void _getGroupMembers() async {
    try {
      var res = await MyHttp.get("chat/users/list");
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
        if (this.mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print("Get friends error $e");
    }
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
          this._groupUsers.add(u);
        }
      }
    } catch (e) {
      print("Get friends error $e");
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);

    // Analytics event tracking code
    amplitudeAnalytics.init(apiKey);

    _tabController.addListener(() {
      if (_tabController.index == 0) {
        analytics.setCurrentScreen(
            screenName: "messages_all", screenClassOverride: "messages_all");
        amplitudeAnalytics.logEvent("messages_all_page");
      } else if (_tabController.index == 1) {
        analytics.setCurrentScreen(
            screenName: "messages_matches",
            screenClassOverride: "messages_matches");
        amplitudeAnalytics.logEvent("messages_matches_page");
      } else if (_tabController.index == 2) {
        analytics.setCurrentScreen(
            screenName: "messages_friends",
            screenClassOverride: "messages_friends");
        amplitudeAnalytics.logEvent("messages_friends_page");
      }
    });

    loadCupertinoTabs();
    loadChildWidgets();
    super.initState();

    _getGroupMembers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> _getChosenList(StateSetter mySetState) {
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
                    child: _groupUsers[chosenMembers[i]].u.imageUrl == null ||
                            _groupUsers[chosenMembers[i]].u.imageUrl == "na"
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
                        mySetState(() {
                          for (var j = 0; j < _groupUsers.length; j++) {
                            var v = _groupUsers[j];
                            var u1 = chosenMemberIds[i];
                            if (v.u.id == u1) {
                              chosenMemberIds.removeAt(i);
                              chosenMembers.removeAt(i);
                              names.removeAt(i);
                              if (v.selected) {
                                v.selected = false;
                              }
                              break;
                            }
                          }
                        });
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

//  Widget _getSearchList() {
//    print("get search list called2");
//    if (groupMembers.isNotEmpty) {
//      List<Widget> column = [];
//      column.add(Divider(
//        thickness: 2,
//        height: 3,
//        color: AppColors.greyColor,
//      ));
//      for (int i = 0; i < groupMembers.length; i++) {
//        if (groupMembers[i]["first_name"]
//            .toLowerCase()
//            .startsWith(filter.trim().toLowerCase())) {
//          column.add(ListTile(
//            title: Text(
//              groupMembers[i]["first_name"],
//              style: TextStyle(
//                  fontSize: 18,
//                  fontWeight: FontWeight.w600,
//                  fontFamily: 'Avenir Next'),
//            ),
//            leading: ClipRRect(
//              borderRadius: BorderRadius.circular(100.0),
//              child: groupMembers[i]["ProfilePictureId"] == null
//                  ? Image(
//                image: AssetImage("assets/images/logo.png"),
//              )
//                  : Image(
//                image: NetworkImage(
//                  groupMembers[i]["ProfilePictureId"],
//                ),
//              ),
//            ),
//            trailing: Icon(Icons.add_circle),
//            onTap: () {
//              if (!chosenMembers.contains(i)) {
//                chosenMembers.add(i);
//                names.add(groupMembers[i]["first_name"]);
//                print("hello");
//                print(chosenMembers);
//
//              }
//              setState(() {
//                _getChosenList();
//              });
//            },
//          ));
//          column.add(Divider(
//            thickness: 2,
//            height: 3,
//            color: AppColors.greyColor,
//          ));
//        }
//      }
//      return Column(
//        crossAxisAlignment: CrossAxisAlignment.stretch,
//        children: column,
//      );
//    } else {
//      return Container();
//    }
//  }
//
//  Widget _getList() {
//    if (groupMembers.isNotEmpty) {
//      List<Widget> column = [];
//      column.add(Divider(
//        thickness: 2,
//        height: 3,
//        color: AppColors.greyColor,
//      ));
//      for (int i = 0; i < groupMembers.length; i++) {
//        column.add(ListTile(
//          title: Text(
//            groupMembers[i]["first_name"],
//            style: TextStyle(
//                fontSize: 18,
//                fontWeight: FontWeight.w600,
//                fontFamily: 'Avenir Next'),
//          ),
//          leading: ClipRRect(
//            borderRadius: BorderRadius.circular(100.0),
//            child: groupMembers[i]["ProfilePictureId"] == null
//                ? Image(
//              image: AssetImage("assets/images/logo.png"),
//            )
//                : Image(
//              image: NetworkImage(
//                groupMembers[i]["ProfilePictureId"],
//              ),
//            ),
//          ),
//          trailing: Icon(Icons.add_circle),
//          onTap: () {
//            setState(() {
//              if (!chosenMembers.contains(i)) {
//                chosenMembers.add(i);
//              }
//            });
//          },
//        ));
//        column.add(Divider(
//          thickness: 2,
//          height: 3,
//          color: AppColors.greyColor,
//        ));
//      }
//      return Column(
//        crossAxisAlignment: CrossAxisAlignment.stretch,
//        children: column,
//      );
//    } else {
//      return Container();
//    }
//  }
  var screenHeight;
  var screenWidth;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    print("message_base_page Selected index $selectedIndex");
    //this.afterBuild();

    return PlatformScaffold(
        appBar: PlatformAppBar(
          backgroundColor: AppColors.blueColor,
          automaticallyImplyLeading: false,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PlatformIconButton(
                onPressed: () => _createGroup(),
                icon: Image.asset("assets/images/edit-pen.png"),
                padding: EdgeInsets.only(left: 0, right: 10, top: 8, bottom: 8),
              )
            ],
          ),
          cupertino: (_, __) =>
              CupertinoNavigationBarData(brightness: Brightness.dark),
          material: (_, __) => MaterialAppBarData(
            leading: MaterialButton(
              onPressed: () {},
              child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Image.asset("assets/images/edit-pen.png"),
                  color: Colors.white,
                  onPressed: () => _createGroup()),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Tab(
                  child: Text("All"),
                ),
                Tab(
                  child: Text("Matches"),
                ),
                Tab(
                  child: Text("Friends"),
                )
              ],
            ),
          ),
          title: Text(
            "Messages",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
          ),
          trailingActions: <Widget>[
            PlatformButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MainSettings()));
              },
              child: Image.asset(
                "assets/images/setting_logo.png",
                width: 30,
                height: 30,
              ),
              color: AppColors.blueColor,
              padding: EdgeInsets.all(0),
            ),
          ],
        ),
        body: Material(
          child: SafeArea(
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
                                    screenName: "messages_all",
                                    screenClassOverride: "messages_all");
                                amplitudeAnalytics
                                    .logEvent("messages_all_page");
                              } else if (selectedIndex == 1) {
                                analytics.setCurrentScreen(
                                    screenName: "messages_matches",
                                    screenClassOverride: "messages_matches");
                                amplitudeAnalytics
                                    .logEvent("messages_matches_page");
                              } else if (selectedIndex == 2) {
                                analytics.setCurrentScreen(
                                    screenName: "messages_friends",
                                    screenClassOverride: "messages_friends");
                                amplitudeAnalytics
                                    .logEvent("messages_friends_page");
                              }
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
        ));
  }

  void loadCupertinoTabs() {
    map = new Map();
    map[0] = Text("All");
    map[1] = Text("Matches");
    map[2] = Text("Friends");
  }

  void loadChildWidgets() {
    if (widget.messageType == null || widget.messageType.length == 0) {
      childWidgets = [
        MessagePage(
          messageOf: MessageOf.All,
          key: UniqueKey(),
          onChangedUnreadChatCount: widget.onChangedUnreadChatCount,
        ),
        MessagePage(
          messageOf: MessageOf.Matches,
          key: UniqueKey(),
          onChangedUnreadChatCount: widget.onChangedUnreadChatCount,
        ),
        MessagePage(
          messageOf: MessageOf.Friends,
          key: UniqueKey(),
          onChangedUnreadChatCount: widget.onChangedUnreadChatCount,
        ),
      ];
    } else {
      childWidgets = [
        MessagePage(
          messageOf: MessageOf.All,
          key: UniqueKey(),
          onChangedUnreadChatCount: widget.onChangedUnreadChatCount,
          userId: widget.userId,
          chatId: widget.chatId,
          status: widget.status,
          otherUserName: widget.otherUserName,
          messageType: widget.messageType,
        ),
        MessagePage(
          messageOf: MessageOf.Matches,
          key: UniqueKey(),
          onChangedUnreadChatCount: widget.onChangedUnreadChatCount,
          userId: widget.userId,
          chatId: widget.chatId,
          status: widget.status,
          otherUserName: widget.otherUserName,
          messageType: widget.messageType,
        ),
        MessagePage(
          messageOf: MessageOf.Friends,
          key: UniqueKey(),
          onChangedUnreadChatCount: widget.onChangedUnreadChatCount,
          userId: widget.userId,
          chatId: widget.chatId,
          status: widget.status,
          otherUserName: widget.otherUserName,
          messageType: widget.messageType,
        ),
      ];
    }
  }

  void _createGroup() {
    showModalBottomSheet(
      elevation: 3,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      context: context,
      builder: (context) => Container(
        height: screenHeight * 0.85,
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter mySetState) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
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
                      "Choose People",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Avenir Next'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (chosenMembers.length < 2) {
                          _createChat(_groupUsers[chosenMembers[i]]);
                        } else {
                          _createGroupChat();
                        }
                        //TODO: if list:choosemembers length is 1 it will go to chatBasepage
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
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
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            )),
                        enabledBorder: new OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(50.0),
                            )),
                        border: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.transparent, width: 0),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(50.0),
                          ),
                        )),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                (this.chosenMembers.isNotEmpty)
                    ? Container(
                        height: 90,
                        child: Row(children: _getChosenList(mySetState)))
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
                                  child: (u.u.imageUrl != null &&
                                          u.u.imageUrl.isNotEmpty &&
                                          u.u.imageUrl != "na")
                                      ? CachedNetworkImage(
                                          imageUrl: u.u.imageUrl,
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )
                                      : Icon(Icons.person, size: 70),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: Text(
                                  u.u.first_name ?? "",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                                (u.selected)
                                    ? MaterialButton(
                                        height: 35,
                                        minWidth: 35,
                                        onPressed: () {
                                          mySetState(() {
                                            if (u.selected) {
                                              this.chosenMembers.remove(i);
                                              chosenMemberIds.remove(u.u.id);
                                              names.remove(u.u.first_name);

                                              //Analytics code
                                              analytics.logEvent(
                                                  name: "removed_group_member",
                                                  parameters: <String, dynamic>{
                                                    "user": u.u.id.toString()
                                                  });

                                              amplitudeAnalytics.logEvent(
                                                  "removed_group_member",
                                                  eventProperties: {
                                                    'user': u.u.id.toString()
                                                  });
                                            } else {
                                              this.chosenMembers.add(i);
                                              chosenMemberIds.add(u.u.id);
                                              names.add(u.u.first_name);
                                              print(names);

                                              //Analytics code
                                              analytics.logEvent(
                                                  name: "added_group_member",
                                                  parameters: <String, dynamic>{
                                                    "user": u.u.id.toString()
                                                  });

                                              amplitudeAnalytics.logEvent(
                                                  "added_group_member",
                                                  eventProperties: {
                                                    "user": u.u.id.toString()
                                                  });
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
                                          mySetState(() {
                                            if (u.selected) {
                                              this.chosenMembers.remove(i);
                                              chosenMemberIds.remove(u.u.id);
                                              names.remove(u.u.first_name);
                                            } else {
                                              this.chosenMembers.add(i);
                                              chosenMemberIds.add(u.u.id);
                                              names.add(u.u.first_name);
                                              print(names);
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
              ]);
//
        }),
//            filter.trim().isNotEmpty == true
//                ? _getSearchList()
//                : _getList(),
      ),
    );
  }

//  void _addMember() {
//    WidgetsBinding.instance.addPostFrameCallback((_) async {
//      showModalBottomSheet(
//        elevation: 3,
//        isScrollControlled: true,
//        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
//        context: context,
//        builder: (context) => Container(
//          height: screenHeight * 0.85,
//          child: StatefulBuilder(
//              builder: (BuildContext context, StateSetter mySetState) {
//            return Column(
//                crossAxisAlignment: CrossAxisAlignment.stretch,
//                children: <Widget>[
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                    children: <Widget>[
//                      FlatButton(
//                        onPressed: () {
//                          Navigator.of(context).pop();
//                        },
//                        child: Text(
//                          "Cancel",
//                          style: TextStyle(
//                              color: AppColors.redColor,
//                              fontSize: 14,
//                              fontWeight: FontWeight.w500,
//                              fontFamily: 'Avenir Next'),
//                        ),
//                      ),
//                      Text(
//                        "Add Group Members",
//                        style: TextStyle(
//                            color: Colors.black,
//                            fontSize: 18,
//                            fontWeight: FontWeight.w600,
//                            fontFamily: 'Avenir Next'),
//                      ),
//                      FlatButton(
//                        onPressed: () {
//                          Navigator.of(context).pop();
//                          _addNewMember(widget.chatId);
//
//                        },
//                        child: Text(
//                          "Done",
//                          style: TextStyle(
//                              color: chosenMembers.length > 0
//                                  ? AppColors.blueColor
//                                  : AppColors.offWhiteColor,
//                              fontSize: 14,
//                              fontWeight: FontWeight.w500,
//                              fontFamily: 'Avenir Next'),
//                        ),
//                      ),
//                    ],
//                  ),
//                  SizedBox(
//                    height: 10,
//                  ),
//                  TextField(
//                    cursorColor: Colors.black,
//                    onChanged: (String f) {
//                      setState(() {
//                        filter = f;
//                      });
//                    },
//                    decoration: InputDecoration(
//                        contentPadding:
//                            EdgeInsets.symmetric(vertical: 0, horizontal: 50),
//                        prefixIcon: Icon(
//                          Icons.search,
//                          size: 24,
//                          color: AppColors.blackColor,
//                        ),
//                        suffixIcon: InkWell(
//                            child: Icon(
//                          Icons.mic,
//                          size: 24,
//                          color: AppColors.blackColor,
//                        )),
//                        hintText: "Search",
//                        fillColor: AppColors.greyColor,
//                        filled: true,
//                        focusedBorder: new OutlineInputBorder(
//                            borderSide:
//                                BorderSide(color: Colors.transparent, width: 0),
//                            borderRadius: const BorderRadius.all(
//                              const Radius.circular(10.0),
//                            )),
//                        enabledBorder: new OutlineInputBorder(
//                            borderSide:
//                                BorderSide(color: Colors.transparent, width: 0),
//                            borderRadius: const BorderRadius.all(
//                              const Radius.circular(50.0),
//                            )),
//                        border: new OutlineInputBorder(
//                          borderSide:
//                              BorderSide(color: Colors.transparent, width: 0),
//                          borderRadius: const BorderRadius.all(
//                            const Radius.circular(50.0),
//                          ),
//                        )),
//                  ),
//                  SizedBox(
//                    height: 10,
//                  ),
//                  (this.chosenMembers.isNotEmpty)
//                      ? Row(children: _getChosenList())
//                      : Container(),
//                  SizedBox(
//                    height: 10,
//                  ),
//                  Expanded(
//                    child: ListView.builder(
//                        itemCount: this._groupUsers.length,
//                        itemBuilder: (c, i) {
//                          var u = this._groupUsers[i];
//
//                          if (filter.trim().isNotEmpty) {
//                            if (u.u.fullName.startsWith(filter.trim()) ==
//                                false) {
//                              return Container();
//                            }
//                          }
//                          return Padding(
//                            padding: const EdgeInsets.all(8.0),
//                            child: Container(
//                              color: Colors.white,
//                              height: 70,
//                              padding: EdgeInsets.all(10),
//                              child: Row(
//                                children: <Widget>[
//                                  ClipRRect(
//                                      borderRadius:
//                                          BorderRadius.circular(100.0),
//                                      child: CachedNetworkImage(
//                                        imageUrl: u.u.imageUrl ??
//                                            "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
//                                      )),
//                                  SizedBox(
//                                    width: 10,
//                                  ),
//                                  Expanded(
//                                      child: Text(
//                                    u.u.first_name ?? "",
//                                    style: TextStyle(
//                                        fontSize: 18,
//                                        fontWeight: FontWeight.bold),
//                                  )),
//                                  (u.selected)
//                                      ? MaterialButton(
//                                          height: 35,
//                                          minWidth: 35,
//                                          onPressed: () {
//                                            mySetState(() {
//                                              if (u.selected) {
//                                                this.chosenMembers.remove(i);
//                                                names.remove(u.u.first_name);
//                                              } else {
//                                                this.chosenMembers.add(i);
//                                                names.add(u.u.first_name);
//                                                print(names);
//                                              }
//                                              u.selected = !u.selected;
//                                              print(
//                                                  "Chosend length: ${chosenMembers.length}");
//                                            });
//                                          },
//                                          color: AppColors.blueColor,
//                                          textColor: Colors.white,
//                                          padding: EdgeInsets.all(16),
//                                          shape: CircleBorder(),
//                                        )
//                                      : InkWell(
//                                          onTap: () {
//                                            mySetState(() {
//                                              if (u.selected) {
//                                                this.chosenMembers.remove(i);
//                                                names.remove(u.u.first_name);
//                                                chosenMemberIds.remove(u.u.id);
//                                              } else {
//                                                this.chosenMembers.add(i);
//                                                names.add(u.u.first_name);
//                                                chosenMemberIds.add(u.u.id);
//                                              }
//                                              u.selected = !u.selected;
//                                              print(
//                                                  "Chosend length: ${chosenMembers.length}");
//                                            });
//                                          },
//                                          child: Container(
//                                            height: 35,
//                                            width: 35,
//                                            decoration: BoxDecoration(
//                                                borderRadius: BorderRadius.all(
//                                                    Radius.circular(100)),
//                                                border: Border.all(
//                                                    width: 3,
//                                                    color: Colors.black26,
//                                                    style: BorderStyle.solid)),
//                                          ),
//                                        ),
//                                ],
//                              ),
//                            ),
//                          );
//                        }),
//                  ),
//                ]);
////
//          }),
////            filter.trim().isNotEmpty == true
////                ? _getSearchList()
////                : _getList(),
//        ),
//      );
//    });
//  }

  void _logout() async {
    var sp = await SharedPreferences.getInstance();
    sp.remove("token");
    sp.remove("id");
    Routes.sailor.navigate("/main",
        navigationType: NavigationType.pushAndRemoveUntil,
        removeUntilPredicate: (Route<dynamic> route) => false);
  }

  Widget getChildWidget() {
    return childWidgets[selectedIndex];
  }
}
