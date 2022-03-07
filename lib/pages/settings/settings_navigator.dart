import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/feed/feed_base.dart';
import 'package:pure_match/pages/feed/feed_base_enum.dart';
import 'package:pure_match/pages/match/browse_match.dart';
import 'package:pure_match/pages/own_profile/my_profile.dart';
import 'package:pure_match/pages/settings/settings_main.dart';

class SettingsNavigator extends StatefulWidget {
  int tabIndex;
  // bool ownProfileSaved;
  final BaseFeedEnum baseFeedEnum;
  SettingsNavigator({tabIndex, this.baseFeedEnum}) {
    this.tabIndex = tabIndex ?? 0;
    // this.ownProfileSaved = ownProfileSaved ?? false;
  }

  @override
  _SettingsNavigatorState createState() => _SettingsNavigatorState();
}

class _SettingsNavigatorState extends State<SettingsNavigator> {
  int i;
  List<dynamic> tabs;

  BaseFeedEnum baseFeedEnum = BaseFeedEnum.MY_FEED;

  @override
  void initState() {
    i = widget.tabIndex;
    baseFeedEnum = widget.baseFeedEnum ?? BaseFeedEnum.MY_FEED;
    tabs = [
      FeedBase(
        baseFeedEnum: baseFeedEnum,
        isFriendRequest: false,
      ),
      BrowseMatch(),
      MainSettings(),
      MyProfile()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = 32;

    return Scaffold(
      body: tabs[i],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.greyColor,
        fixedColor: AppColors.blueColor,
        currentIndex: i,
        iconSize: 24,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.album,
              size: iconSize,
            ),
            title: Text(""),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: iconSize),
            title: Text(""),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble, size: iconSize),
            title: Text(""),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: iconSize),
            title: Text(""),
          )
        ],
        onTap: (index) {
          setState(() {
            i = index;
          });
        },
      ),
    );
  }
}
