import 'dart:io';
import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/profile.dart';
import 'package:pure_match/common/reason_to_report.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/messaging/chat_page.dart';
import 'package:pure_match/pages/messaging/unmatched_profile.dart';
import 'package:amplitude_flutter/amplitude.dart';

class ChatBasePage extends StatefulWidget {
  final int userId;
  final int chatId;
  final String otherUserName;
  final String
      status; // this is the chat status if the user is allowed to chat or not.

  const ChatBasePage(
      {Key key,
      this.userId,
      this.chatId,
      this.otherUserName,
      this.status = null})
      : super(key: key);
  @override
  _ChatBasePageState createState() => _ChatBasePageState();
}

class _ChatBasePageState extends State<ChatBasePage>
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

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    loadCupertinoTabs();
    loadChildWidgets();
    // this is the listener to hide the keyboard if we switch tabs
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    _tabController.addListener(() {
      // Analytics tracking code
      if (_tabController.index == 0) {
        analytics.setCurrentScreen(
            screenName: "chat_user", screenClassOverride: "chat_user");
        amplitudeAnalytics.logEvent("chat_user_page");
      } else if (_tabController.index == 1) {
        analytics.setCurrentScreen(
            screenName: "chat_profile", screenClassOverride: "chat_profile");
        amplitudeAnalytics.logEvent("chat_profile_page");
      }

      int i = _tabController.previousIndex;
      if (i == 0) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("this is personal chat page");
    return PlatformScaffold(
      appBar: PlatformAppBar(
        backgroundColor: AppColors.blueColor,
        cupertino: (_, __) =>
            CupertinoNavigationBarData(brightness: Brightness.dark),
        material: (_, __) => MaterialAppBarData(
            bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              child: Text("Chat"),
            ),
            Tab(
              child: Text("Profile"),
            )
          ],
        )),
        title: Text(
          widget.otherUserName,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        trailingActions: <Widget>[
          Material(
            color: AppColors.blueColor,
            child: IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (Platform.isAndroid) {
                    _showModalBottomSheet(context);
                  } else {
                    _showModalActionSheet(context);
                  }
                }),
          )
        ],
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
                      constraints: BoxConstraints.expand(height: 32.0),
                      child: CupertinoSlidingSegmentedControl(
                        onValueChanged: (value) {
                          setState(() {
                            selectedIndex = value;
                          });
                          //Analytic tracking code
                          if (selectedIndex == 0) {
                            analytics.setCurrentScreen(
                                screenName: "chat_user",
                                screenClassOverride: "chat_user");
                            amplitudeAnalytics.logEvent("chat_user_page");
                          } else {
                            analytics.setCurrentScreen(
                                screenName: "chat_profile",
                                screenClassOverride: "chat_profile");
                            amplitudeAnalytics.logEvent("chat_profile_page");
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
    );
  }

  void loadCupertinoTabs() {
    map = new Map();
    map[0] = Text("Chat");
    map[1] = Text("Profile");
  }

  void loadChildWidgets() {
    childWidgets = [
      ChatPage(
        chatId: widget.chatId,
        otherUserId: widget.userId,
        status: widget.status,
      ),
      Profile(
              userId: widget.userId,
              isEditable: false,
              themeColor: AppColors.pinkColor)
          .getFullProfile()
    ];
  }

  Widget getChildWidget() => childWidgets[selectedIndex];

  void _showModalBottomSheet(BuildContext context) {
    List<Widget> actions = new List<Widget>();

    // actions.add(ListTile(
    //   title: Text("Unmatch",
    //       style:
    //       TextStyle(color: AppColors.redColor)),
    //   onTap: () {
    //     Navigator.of(context).pop();
    //     Navigator.push(
    //         context,  MaterialPageRoute(
    //         builder: (context) => UnmatchedProfile(otherUserId:widget.userId ,)));
    //
    //   },
    // ));
    actions.add(ListTile(
      title: Text("Report", style: TextStyle(color: AppColors.redColor)),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReasonReport(
                      otherUserId: widget.userId,
                    )));
      },
    ));

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(child: new Wrap(children: actions));
        });
  }

  void _showModalActionSheet(BuildContext context) {
    List<CupertinoActionSheetAction> actionSheetActions =
        new List<CupertinoActionSheetAction>();

    actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Unmatch", style: TextStyle(color: AppColors.redColor)),
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UnmatchedProfile(
                        otherUserId: widget.userId,
                      )));
        }));
    actionSheetActions.add(CupertinoActionSheetAction(
      child: Text("Report", style: TextStyle(color: AppColors.redColor)),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReasonReport(
                      otherUserId: widget.userId,
                    )));
      },
    ));

    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
              title: Text(widget.otherUserName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromRGBO(143, 143, 143, 1),
                  )),
              actions: actionSheetActions,
              cancelButton: CupertinoActionSheetAction(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: AppColors.communityProfileOptionsBlueColor),
                ),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ));
        });
  }
}
