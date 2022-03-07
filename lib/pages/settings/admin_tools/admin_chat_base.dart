import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/settings/admin_tools/admin_chat_body.dart';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

class AdminChat extends StatefulWidget {
  @override
  _AdminChatState createState() => _AdminChatState();
}

class _AdminChatState extends State<AdminChat>
    with SingleTickerProviderStateMixin {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _tabController = TabController(vsync: this, length: 2);

    // Analytics event tracking code
    amplitudeAnalytics.init(apiKey);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        analytics.setCurrentScreen(screenName: "admin_chat_inquires");
        amplitudeAnalytics.logEvent("admin_chat_inquires_page");
      } else if (_tabController.index == 1) {
        analytics.setCurrentScreen(screenName: "admin_chat_warnings");
        amplitudeAnalytics.logEvent("admin_chat_warnings_page");
      }
    });
    loadChildWidgets();
  }

  void loadChildWidgets() {
    childWidgets = [
      ChatPage(
        page: SubPage.Inquiries,
        key: UniqueKey(),
      ),
      ChatPage(
        page: SubPage.Warnings,
        key: UniqueKey(),
      ),
    ];
  }

  Widget getChildWidget() => childWidgets[subpage];
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> childWidgets = [];
  final Map<int, Widget> map = {
    0: Text(
      "Inquiries",
      style: TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
      ),
    ),
    1: Text(
      "Warnings",
      style: TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
      ),
    ),
  };
  int subpage = 0;
  TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: AppColors.adminBlackHeader,
      //bottomNavBar: HomePage(),
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: AppColors.adminBlackHeader,
          elevation: 0.0,
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => SettingsNavigator(
                //               tabIndex: 2,
                //             )));
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                child: Image(
                  image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
                ),
              ),
            )
          ],
          title: Text(
            "Admin Chat",
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal),
          ),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                child: Text(
                  "Inquiries",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Warnings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
            controller: _tabController,
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          automaticallyImplyMiddle: false,
          backgroundColor: AppColors.adminBlackHeader,
          trailing: MaterialButton(
            onPressed: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => SettingsNavigator(
              //               tabIndex: 2,
              //             )));
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
              child: Image(
                image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
              ),
            ),
          ),
          title: Text(
            "Admin Chat",
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                fontFamily: "Avenir Next"),
          ),
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
        ),
      ),
      body: SafeArea(
        child: (Platform.isAndroid)
            ? TabBarView(
                controller: _tabController,
                children: childWidgets,
              )
            : Scaffold(
                backgroundColor: AppColors.adminBlackBackground,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    PlatformWidget(
                      cupertino: (_, __) => CupertinoSlidingSegmentedControl(
                        children: map,
                        onValueChanged: (int) {
                          setState(() {
                            subpage = int;
                          });
                          // Analytics event tracking code
                          if (subpage == 0) {
                            analytics.setCurrentScreen(
                                screenName: "admin_chat_inquires");
                            amplitudeAnalytics
                                .logEvent("admin_chat_inquires_page");
                          } else if (subpage == 1) {
                            analytics.setCurrentScreen(
                                screenName: "admin_chat_warnings");
                            amplitudeAnalytics
                                .logEvent("admin_chat_warnings_page");
                          }
                        },
                        groupValue: subpage,
                        thumbColor: Color.fromRGBO(99, 99, 102, 1),
                        backgroundColor: AppColors.searchBarColor,
                      ),
                    ),
                    Expanded(child: getChildWidget()),
                  ],
                ),
              ),
      ),
    );
  }
}
