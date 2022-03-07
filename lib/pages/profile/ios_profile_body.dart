import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/pages/profile/edit_match_settings.dart';
import 'package:pure_match/pages/own_profile/my_profile.dart';

class iOSProfileBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _iOSProfileBodyState();
  }
}

class _iOSProfileBodyState extends State<iOSProfileBody> {
  Map<int, Widget> map = new Map();
  List<Widget> childWidgets = [];
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    loadCupertinoTabs();
    loadChildWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: <Widget>[
        ConstrainedBox(
            constraints: BoxConstraints.expand(height: 32.0),
            child: CupertinoSlidingSegmentedControl(
              onValueChanged: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
              groupValue: selectedIndex,
              //selectedColor, unselected color, padding etc.
              children: map,
            )),
        Expanded(child: getChildWidget()),
      ],
    )));
  }

  void loadCupertinoTabs() {
    map = new Map();
    map[0] = Text("Profile");
    map[1] = Text("MatchSettings");
  }

  void loadChildWidgets() {
    childWidgets = [MyProfile(), EditMatchSettings()];
  }

  Widget getChildWidget() => childWidgets[selectedIndex];
}
