import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/pages/settings/admin_tools/ban_users_base.dart';
import 'package:pure_match/pages/settings/admin_tools/admin_chat_base.dart';
import 'package:pure_match/pages/settings/admin_tools/manage_admins.dart';
import 'package:pure_match/pages/settings/admin_tools/pending_users.dart';
import 'package:amplitude_flutter/amplitude.dart';

class AdminNavigator extends StatefulWidget {
  final int index;
  const AdminNavigator({Key key, @required this.index}) : super(key: key);
  @override
  _AdminNavigatorState createState() => _AdminNavigatorState();
}

class _AdminNavigatorState extends State<AdminNavigator> {
  int i;
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  final List<Widget> tabs = [
    ManageAdmin(),
    BanUsers(),
    AdminChat(),
    PendingUsers()
  ];

  @override
  void initState() {
    super.initState();
    i = widget.index;
    //Initializing amplitude api key
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    String current_page = "";
    if (i == 0) {
      current_page = "manage_admin";
    } else if (i == 1) {
      current_page = "ban_users_queue";
    } else if (i == 2) {
      current_page = "admin_chat_inquires";
    } else if (i == 3) {
      current_page = "pending_users";
    }
    analytics.setCurrentScreen(
        screenName: current_page, screenClassOverride: current_page);
    amplitudeAnalytics.logEvent(current_page + '_page');
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = 40;

    return Scaffold(
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
          // Analytics tracking code
          String current_page = "";
          if (i == 0) {
            current_page = "manage_admin";
          } else if (i == 1) {
            current_page = "ban_users_queue";
          } else if (i == 2) {
            current_page = "admin_chat_inquires";
          } else if (i == 3) {
            current_page = "pending_users";
          }
          analytics.setCurrentScreen(
              screenName: current_page, screenClassOverride: current_page);
          amplitudeAnalytics.logEvent(current_page + '_page');
        },
      ),
    );
  }
}
