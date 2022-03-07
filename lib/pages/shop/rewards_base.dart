import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/pages/shop/awards.dart';
import 'package:pure_match/pages/shop/shop.dart';
import 'package:amplitude_flutter/amplitude.dart';

class RewardsBase extends StatefulWidget {
  bool isShop;
  RewardsBase({isShop}) {
    this.isShop = isShop ?? false;
  }
  @override
  _RewardsBaseState createState() => _RewardsBaseState();
}

class _RewardsBaseState extends State<RewardsBase>
    with SingleTickerProviderStateMixin {
  //Analytics tracking code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");

  TabController _tabController;
  Map<int, Widget> map = new Map();
  List<Widget> childWidgets = [];
  int selectedIndex = 0;

  void loadCupertinoTabs() {
    map = new Map();
    map[0] = Text(
      "Awards",
      style: TextStyle(fontWeight: FontWeight.w700),
    );
    map[1] = Text(
      "Shop",
      style: TextStyle(fontWeight: FontWeight.w700),
    );
  }

  void onSelectSpendMyGems(index) {
    selectedIndex = index;
    setState(() {});
  }

  void loadChildWidgets() {
    childWidgets = [
      Awards(
          rewardspages: RewardsPages.AWARDS,
          onSelectSpendMyPureGems: onSelectSpendMyGems),
      Shop(
        rewardspages: RewardsPages.SHOPS,
      )
    ];
  }

  Widget getChildWidget() {
    print("*************** $selectedIndex");
    return childWidgets[selectedIndex];
  }

  @override
  void initState() {
    loadCupertinoTabs();
    loadChildWidgets();
    if (widget.isShop) {
      selectedIndex = 1;
    }
    _tabController = TabController(length: childWidgets.length, vsync: this);

    // listener for tracking tab navigation
    amplitudeAnalytics.init(apiKey);
    _tabController.addListener(() {
      // Analytics tracking code
      if (_tabController.index == 0) {
        analytics.setCurrentScreen(
            screenName: "rewards_awards",
            screenClassOverride: "rewards_awards");
        amplitudeAnalytics.logEvent("rewards_awards_page");
      } else if (_tabController.index == 1) {
        analytics.setCurrentScreen(
            screenName: "rewards_shop", screenClassOverride: "rewards_shop");

        amplitudeAnalytics.logEvent("rewards_shop_page");
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyColor,
      appBar: AppBar(
        backgroundColor: AppColors.matchBrowseMatchReactivateMatching,
        title: Text(
          "Rewards",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
        ),
        centerTitle: (Platform.isIOS) ? true : false,
        bottom: (Platform.isAndroid)
            ? TabBar(
                indicatorColor: Colors.white,
                isScrollable: false,
                controller: _tabController,
                tabs: <Widget>[
                  Tab(
                    text: "Awards",
                  ),
                  Tab(
                    text: "Shop",
                  ),
                ],
              )
            : PreferredSize(
                child: Container(),
                preferredSize: const Size.fromHeight(0.0),
              ),
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
                          print(value);
                          setState(() {
                            selectedIndex = value;
                          });
                          //Analytics code
                          if (selectedIndex == 0) {
                            analytics.setCurrentScreen(
                                screenName: "rewards_awards",
                                screenClassOverride: "rewards_awards");
                            amplitudeAnalytics.logEvent("rewards_awards_page");
                          } else {
                            analytics.setCurrentScreen(
                                screenName: "rewards_shop",
                                screenClassOverride: "rewards_shop");
                            amplitudeAnalytics.logEvent("rewards_shop_page");
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
}
