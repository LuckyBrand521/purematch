import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'dart:convert';
import 'package:pure_match/pages/settings/admin_tools/pending_user_navigator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

class PendingUsers extends StatefulWidget {
  @override
  _PendingUsersState createState() => _PendingUsersState();
}

class _PendingUsersState extends State<PendingUsers> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  var json;
  var calledBefore = false;
  List<dynamic> users;
  String filter = "";
  final searchBarController = TextEditingController();

  Future<Map<String, dynamic>> _getUsers() async {
    var res = await MyHttp.get("admin/pending");
    var json = jsonDecode(res.body);

    if (!calledBefore) {
      users = json["users"] as List<dynamic>;
      print(json["users"]);
      calledBefore = true;
    }
    return json;
  }

  String _getName(List list, int index) {
    return list[index]["first_name"] + " " + list[index]["last_name"];
  }

  String _getFirstName(List list, int index) {
    return list[index]["first_name"];
  }

  String _getImage(List list, int index) {
    return list[index]["ProfilePictureId"];
  }

  String _getDate(List list, int index) {
    String date = list[index]["createdAt"].substring(0, 10);
    String year = date.substring(0, 4);
    String month = date.substring(5, 7);
    String day = date.substring(8, 10);
    return " $month/$day/$year";
  }

  Widget _getList() {
    if (users != null && users.length != 0) {
      List<Widget> column = [];
      for (int i = 0; i < users.length; i++) {
        if (_getName(users, i)
            .toLowerCase()
            .startsWith(filter.trim().toLowerCase())) {
          column.add(ListTile(
            contentPadding: EdgeInsets.only(right: 0),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: _getImage(users, i) == null
                  ? Image(
                      image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
                    )
                  : Image(
                      image: NetworkImage(
                        _getImage(users, i),
                      ),
                    ),
            ),
            title: Text(
              _getName(users, i),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                color: AppColors.greyColor,
              ),
            ),
            subtitle: Text(
              "Registered on" + _getDate(users, i),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                color: AppColors.greyColor,
              ),
            ),
            onTap: () {
              int id = users[i]["id"];
              String name = _getFirstName(users, i);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PendingUserNavigator(id: id, name: name)));
            },
          ));
        }
      }
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: column);
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Text(
          "No Pending Users",
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: AppColors.greyColor),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUsers(),
      builder: (context, snapshot) {
        //Initializing amplitude analytics api key
        amplitudeAnalytics.init(apiKey);

        if (snapshot.hasData) {
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
                      //Analytics tracking code
                      analytics.setCurrentScreen(
                          screenName: "settings",
                          screenClassOverride: "settings");
                      amplitudeAnalytics.logEvent("settings_page");
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                      child: Image(
                        image:
                            AssetImage("assets/images/Pure_Match_Draft_5.png"),
                      ),
                    ),
                  )
                ],
                title: Text(
                  "Pending Users",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Avenir Next'),
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
                    analytics.setCurrentScreen(
                        screenName: ("settings"),
                        screenClassOverride: "settings");
                    amplitudeAnalytics.logEvent("settings_page");
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                    child: Image(
                      image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
                    ),
                  ),
                ),
                title: Text(
                  "Pending Users",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Avenir Next'),
                ),
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
              ),
            ),
            body: SafeArea(
              child: Scaffold(
                  backgroundColor: AppColors.adminBlackBackground,
                  body: Column(
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: TextField(
                          cursorColor: Colors.white,
                          onChanged: (String f) {
                            setState(() {
                              filter = f;
                            });
                          },
                          style: TextStyle(color: AppColors.adminSBHintText),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 20,
                                color: AppColors.adminSBHintText,
                              ),
                              hintText: "Search",
                              hintStyle: TextStyle(
                                color: AppColors.adminSBHintText,
                              ),
                              fillColor: AppColors.searchBarColor,
                              filled: true,
                              focusedBorder: new OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.transparent, width: 0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  )),
                              enabledBorder: new OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.transparent, width: 0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  )),
                              border: new OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 0),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(10.0),
                                ),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      filter.trim().isNotEmpty == true
                          ? _getList()
                          : Expanded(
                              child: users == null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        "No Pending Users",
                                        style: TextStyle(
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: AppColors.greyColor),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: users.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          contentPadding:
                                              EdgeInsets.only(right: 0),
                                          onTap: () {
                                            int id = users[index]["id"];
                                            String name =
                                                _getFirstName(users, index);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PendingUserNavigator(
                                                            id: id,
                                                            name: name)));
                                          },
                                          leading: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: _getImage(users, index) ==
                                                    null
                                                ? Image(
                                                    image: AssetImage(
                                                        "assets/images/Pure_Match_Draft_5.png"),
                                                  )
                                                : Image(
                                                    image: NetworkImage(
                                                      _getImage(users, index),
                                                    ),
                                                  ),
                                          ),
                                          title: Text(
                                            _getName(users, index),
                                            style: TextStyle(
                                              color: AppColors.greyColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Registered on" +
                                                _getDate(users, index),
                                            style: TextStyle(
                                              color: AppColors.greyColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                    ],
                  )),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
