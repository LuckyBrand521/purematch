import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'dart:convert';

import 'package:pure_match/pages/settings/admin_tools/ban_user_report.dart';

enum SubPage { Queue, Warned, Banned }

class BannedPage extends StatefulWidget {
  final SubPage page;

  const BannedPage({Key key, @required this.page}) : super(key: key);
  @override
  _BannedPageState createState() => _BannedPageState();
}

class _BannedPageState extends State<BannedPage>
    with SingleTickerProviderStateMixin {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  TabController _tabController;
  var users;
  static var warned;
  static var banned;
  static var queue;
  var searchList;
  var searchBarController = TextEditingController();
  String filter = "";
  int pageNum;
  Map<int, List<dynamic>> map = {1: queue, 2: warned, 3: banned};

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    _getUsers();
    //Initializing amplitude analytics  api key
    amplitudeAnalytics.init(apiKey);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  String _getName(List list, int index) {
    return list[index]["User"]["first_name"] +
        " " +
        list[index]["User"]["last_name"];
  }

  String _getImage(List list, int index) {
    String profileImg = list[index]["User"]["ProfilePictureId"] ?? "";
    print("imgLink=${profileImg}");
    return profileImg;
  }

  String _getDate(List list, int index) {
    String prefix = "";
    String date = "";
    if (widget.page == SubPage.Queue) {
      prefix = "Reported on";
      date = list[index]["UserReports"][list[index]["UserReports"].length - 1]
              ["createdAt"]
          .substring(0, 10);
    } else if (widget.page == SubPage.Warned) {
      prefix = "Warned on";
      date = list[index]["UserWarnings"][list[index]["UserWarnings"].length - 1]
              ["createdAt"]
          .substring(0, 10);
    } else {
      prefix = "Banned on";
      date = list[index]["UserReports"][list[index]["UserReports"].length - 1]
              ["updatedAt"]
          .substring(0, 10);
    }
    String year = date.substring(0, 4);
    String month = date.substring(5, 7);
    String day = date.substring(8, 10);
    return "$prefix $month/$day/$year";
  }

  Widget _getList() {
    if (searchList != null && searchList.length != 0) {
      List<Widget> column = [];
      for (int i = 0; i < searchList.length; i++) {
        if (_getName(searchList, i)
            .toLowerCase()
            .startsWith(filter.trim().toLowerCase())) {
          column.add(ListTile(
            contentPadding: EdgeInsets.only(right: 0),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: _getImage(searchList, i) == ""
                  ? Image(
                      image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
                    )
                  : Image(
                      image: NetworkImage(
                        _getImage(searchList, i),
                      ),
                    ),
            ),
            title: Text(
              _getName(searchList, i),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                color: AppColors.greyColor,
              ),
            ),
            subtitle: Text(
              _getDate(searchList, i),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                color: AppColors.greyColor,
              ),
            ),
            onTap: () {
              SubPage sub;
              if (pageNum == 1) {
                sub = SubPage.Queue;
              } else if (pageNum == 2) {
                sub = SubPage.Warned;
              } else {
                sub = SubPage.Banned;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BannedUserReportPage(
                    page: sub,
                    userInfo: map[pageNum][i],
                  ),
                ),
              );
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
          "No Users in Queue",
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: AppColors.greyColor),
        ),
      );
    }
  }

  Future<List<dynamic>> _getQueue() async {
    var res = await MyHttp.get("admin/watched");
    var json = jsonDecode(res.body);
    var users = json["queue"] as List<dynamic>;
    queue = users;
    searchList = users;
    map[1] = queue;
    return users;
  }

  // void _getSearch() async {
  //   var res;
  //   if (widget.page == SubPage.Queue) {
  //     res = await MyHttp.post("admin/search-queue", {"searchQuery": filter});
  //     var json = jsonDecode(res.body);
  //     var users = json["queue"] as List<dynamic>;
  //     searchList = users;
  //   } else if (widget.page == SubPage.Warned) {
  //     res = await MyHttp.post("admin/search-warned", {"searchQuery": filter});
  //     var json = jsonDecode(res.body);
  //     var users = json["warned"] as List<dynamic>;
  //     searchList = users;
  //   } else {
  //     res = await MyHttp.post("admin/search-banned", {"searchQuery": filter});
  //     var json = jsonDecode(res.body);
  //     var users = json["queue"] as List<dynamic>;
  //     searchList = users;
  //   }
  // }

  Future<List<dynamic>> _getWarned() async {
    var res = await MyHttp.get("admin/warned");
    var json = jsonDecode(res.body);
    var users = json["warned"] as List<dynamic>;
    warned = users;
    searchList = users;
    map[2] = warned;
    return users;
  }

  Future<List<dynamic>> _getBanned() async {
    var res = await MyHttp.get("admin/banned");
    var json = jsonDecode(res.body);
    var users = json["queue"] as List<dynamic>;
    banned = users;
    searchList = users;
    map[3] = banned;
    return users;
  }

  Future<List<dynamic>> _getUsers() async {
    if (widget.page == SubPage.Queue) {
      pageNum = 1;
      return await _getQueue();
    } else if (widget.page == SubPage.Warned) {
      pageNum = 2;
      return await _getWarned();
    } else {
      pageNum = 3;
      return await _getBanned();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 5,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: TextField(
                    cursorColor: Colors.white,
                    controller: searchBarController,
                    onChanged: (String f) {
                      setState(() {
                        filter = f;
                      });
                    },
                    style: TextStyle(color: AppColors.adminSBHintText),
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 20),
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
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            )),
                        enabledBorder: new OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            )),
                        border: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.transparent, width: 0),
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
                        child: ListView.builder(
                          itemCount: map[pageNum].length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              contentPadding: EdgeInsets.only(right: 0),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: _getImage(map[pageNum], index) == ""
                                    ? Image(
                                        image: AssetImage(
                                            "assets/images/Pure_Match_Draft_5.png"),
                                      )
                                    : Image(
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          _getImage(map[pageNum], index),
                                        ),
                                      ),
                              ),
                              title: Text(
                                _getName(map[pageNum], index),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  color: AppColors.greyColor,
                                ),
                              ),
                              subtitle: Text(
                                _getDate(map[pageNum], index),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  color: AppColors.greyColor,
                                ),
                              ),
                              onTap: () {
                                SubPage sub;
                                if (pageNum == 1) {
                                  sub = SubPage.Queue;
                                } else if (pageNum == 2) {
                                  sub = SubPage.Warned;
                                } else {
                                  sub = SubPage.Banned;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BannedUserReportPage(
                                      page: sub,
                                      userInfo: map[pageNum][index],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ]);
        } else {
          return Container(
            child: Center(
                child: Text(
              "This is only Accessible to Admins",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
              ),
              textAlign: TextAlign.center,
            )),
          );
        }
      },
    );
  }
}
