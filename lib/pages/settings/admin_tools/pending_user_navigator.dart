import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/settings/admin_tools/ban_users_base.dart';
import 'package:pure_match/pages/settings/admin_tools/admin_chat_base.dart';
import 'package:pure_match/pages/settings/admin_tools/manage_admins.dart';
import 'package:pure_match/pages/settings/admin_tools/pending_user_info.dart';

class PendingUserNavigator extends StatefulWidget {
  final int id;
  final String name;
  const PendingUserNavigator({Key key, @required this.id, @required this.name})
      : super(key: key);
  @override
  _PendingUserNavigatorState createState() => _PendingUserNavigatorState();
}

class _PendingUserNavigatorState extends State<PendingUserNavigator> {
  int i = 3;
  List<Widget> tabs;

  //Analytics tracking code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabs = [
      ManageAdmin(),
      BanUsers(),
      AdminChat(),
      PendingUsersInfo(
        id: widget.id,
        name: widget.name,
      )
    ];
    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "pending_user", screenClassOverride: "pending_user");
    amplitudeAnalytics.logEvent("pending_user_page");
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = 40;
    final materialTheme =
        new ThemeData(fontFamily: 'Avenir Next', primaryColor: Colors.black);
    return MaterialApp(
      theme: materialTheme,
      home: Scaffold(
        body: tabs[i],
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0.0,
          backgroundColor: AppColors.adminBlackHeader,
          fixedColor: Colors.white,
          unselectedItemColor: AppColors.offWhiteColor,
          currentIndex: i,
          iconSize: 24,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                i == 0 ? Icons.person : Icons.person_outline,
                size: iconSize,
              ),
              title: Text(""),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.block, size: iconSize),
              title: Text(""),
            ),
            BottomNavigationBarItem(
              icon: Icon(i == 2 ? Icons.chat_bubble : Icons.chat_bubble_outline,
                  size: iconSize),
              title: Text(""),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline, size: iconSize),
              title: Text(""),
            )
          ],
          onTap: (index) {
            setState(() {
              i = index;
            });
          },
        ),
      ),
    );
  }
}
