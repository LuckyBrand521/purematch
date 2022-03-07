import 'dart:io';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/loading.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/settings/admin_tools/add_admin.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'dart:convert';
import 'package:amplitude_flutter/amplitude.dart';

class ManageAdmin extends StatefulWidget {
  @override
  _ManageAdminState createState() => _ManageAdminState();
}

class _ManageAdminState extends State<ManageAdmin> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  var json;
  var calledBefore = false;
  List<dynamic> admins;
  List<dynamic> moderators;
  List<dynamic> coaches;
  String filter = "";
  String error = "";
  bool loading = false;
  void _getAdmins() async {
    if (this.mounted) {
      setState(() {
        loading = true;
        error = "";
      });
    }
    try {
      var res = await MyHttp.get("admin");
      if (res.statusCode == 200) {
        var json = jsonDecode(res.body);
        admins = json["admins"] as List<dynamic>;
        moderators = json["mods"] as List<dynamic>;
        coaches = json["coaches"] as List<dynamic>;
        calledBefore = true;
        if (this.mounted) {
          setState(() {});
        }
      } else {
        if (this.mounted) {
          setState(() {
            error = "Error: Status code is ${res.statusCode}";
          });
        }
      }
    } catch (e, stackTrace) {
      print("_getAdmins Stack Trace:" + stackTrace.toString());
      print("_getAdmins Error:" + e.toString());
      if (this.mounted) {
        setState(() {
          error = "$e";
        });
      }
    }
    if (this.mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  String _getName(List list, int index) {
    return list[index]["first_name"] + " " + list[index]["last_name"];
  }

  String _getImage(List list, int index) {
    return list[index]["ProfilePictureId"];
  }

  String _getRoleAndName(List list, int index) {
    return list[index]["role"] + " - " + list[index]["first_name"];
  }

  //NEED A PROPER VALUE FROM API
  // String _getDate(List list, int index) {
  //   return list[index]["createdAt"];
  // }

  // Widget _getSearches() {
  //   List column = <Widget>[];
  //   for (int i = 0; i < admins.length; i++) {
  //     if (_getName(admins, i)
  //         .toLowerCase()
  //         .startsWith(filter.trim().toLowerCase())) {
  //       column.add(ListTile(
  //         contentPadding: EdgeInsets.only(right: 0),
  //         leading: ClipRRect(
  //           borderRadius: BorderRadius.circular(100.0),
  //           child: _getImage(admins, i) == null
  //               ? Image(
  //                   image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
  //                 )
  //               : Image(
  //                   image: NetworkImage(
  //                     _getImage(admins, i),
  //                   ),
  //                 ),
  //         ),
  //         trailing: IconButton(
  //           onPressed: () {},
  //           icon: Icon(
  //             Icons.more_horiz,
  //             size: 40,
  //             color: Colors.white,
  //           ),
  //         ),
  //         title: Text(
  //           _getName(admins, i),
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w500,
  //             fontStyle: FontStyle.normal,
  //             color: AppColors.greyColor,
  //           ),
  //         ),
  //         subtitle: Text(
  //           "User joined",
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w400,
  //             fontStyle: FontStyle.normal,
  //             color: AppColors.greyColor,
  //           ),
  //         ),
  //       ));
  //     }
  //   }
  //   for (int i = 0; i < moderators.length; i++) {
  //     if (_getName(moderators, i)
  //         .toLowerCase()
  //         .startsWith(filter.trim().toLowerCase())) {
  //       column.add(ListTile(
  //         contentPadding: EdgeInsets.only(right: 0),
  //         leading: ClipRRect(
  //           borderRadius: BorderRadius.circular(100.0),
  //           child: _getImage(moderators, i) == null
  //               ? Image(
  //                   image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
  //                 )
  //               : Image(
  //                   image: NetworkImage(
  //                     _getImage(moderators, i),
  //                   ),
  //                 ),
  //         ),
  //         trailing: IconButton(
  //           onPressed: () {},
  //           icon: Icon(
  //             Icons.more_horiz,
  //             size: 40,
  //             color: Colors.white,
  //           ),
  //         ),
  //         title: Text(
  //           _getName(moderators, i),
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w500,
  //             fontStyle: FontStyle.normal,
  //             color: AppColors.greyColor,
  //           ),
  //         ),
  //         subtitle: Text(
  //           "User joined",
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w400,
  //             fontStyle: FontStyle.normal,
  //             color: AppColors.greyColor,
  //           ),
  //         ),
  //       ));
  //     }
  //   }
  //   for (int i = 0; i < coaches.length; i++) {
  //     if (_getName(coaches, i)
  //         .toLowerCase()
  //         .startsWith(filter.trim().toLowerCase())) {
  //       column.add(ListTile(
  //         contentPadding: EdgeInsets.only(right: 0),
  //         leading: ClipRRect(
  //           borderRadius: BorderRadius.circular(100.0),
  //           child: _getImage(coaches, i) == null
  //               ? Image(
  //                   image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
  //                 )
  //               : Image(
  //                   image: NetworkImage(
  //                     _getImage(coaches, i),
  //                   ),
  //                 ),
  //         ),
  //         trailing: IconButton(
  //           onPressed: () {},
  //           icon: Icon(
  //             Icons.more_horiz,
  //             size: 40,
  //             color: Colors.white,
  //           ),
  //         ),
  //         title: Text(
  //           _getName(coaches, i),
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w500,
  //             fontStyle: FontStyle.normal,
  //             color: AppColors.greyColor,
  //           ),
  //         ),
  //         subtitle: Text(
  //           "User joined",
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w400,
  //             fontStyle: FontStyle.normal,
  //             color: AppColors.greyColor,
  //           ),
  //         ),
  //       ));
  //     }
  //   }
  //   if (column.length == 0) {
  //     return Container();
  //   } else {
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: column,
  //     );
  //   }
  // }

  void assignAlert(
      BuildContext context, dynamic user, int index, bool isRemove) {
    String titleTxt = "";
    String contentTxt = "";
    if (isRemove) {
      titleTxt = "Remove this user";
      contentTxt = "Are you sure you want to remove this user?";
    } else {
      if (index == 1) {
        if (user["role"] == "Admin") {
          // "Assign as Moderator"
          titleTxt = "Assign as Moderator";
          contentTxt =
              "Are you sure you want to give this user Moderator privileges?";
        } else {
          // "Assign as Admin"
          titleTxt = "Assign as Admin";
          contentTxt =
              "Are you sure you want to give this user Admin privileges?";
        }
      } else if (index == 2) {
        if (user["role"] == "Admin" || user["role"] == "Moderator") {
          // "Assign as Coach"
          titleTxt = "Assign as Coach";
          contentTxt =
              "Are you sure you want to give this user Coach privileges?";
        } else {
          // "Assign as Moderator"
          titleTxt = "Assign as Moderator";
          contentTxt =
              "Are you sure you want to give this user Moderator privileges?";
        }
      }
    }

    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(titleTxt + "?"),
              content: Text(
                contentTxt,
                style: TextStyle(height: 1.5),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (isRemove) {
                      _removeUser(user);
                    } else {
                      _updateUser(user, index);
                    }
                  },
                  child: Text(
                    titleTxt,
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  ),
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                )
              ],
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(titleTxt + "?"),
              content: Text(
                contentTxt,
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (isRemove) {
                      _removeUser(user);
                    } else {
                      _updateUser(user, index);
                    }
                  },
                  child: Text(
                    titleTxt,
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                )
              ],
            );
          });
    }
  }

  void _updateUser(dynamic user, int index) async {
    Map map = Map<String, Object>();
    if (index == 1) {
      if (user["role"] == "Admin") {
        // "Assign as Moderator"
        map.putIfAbsent("role", () => "Moderator");
      } else {
        // "Assign as Admin"
        map.putIfAbsent("role", () => "Admin");
      }
    } else if (index == 2) {
      if (user["role"] == "Admin" || user["role"] == "Moderator") {
        // "Assign as Coach"
        map.putIfAbsent("role", () => "Coach");
      } else {
        // "Assign as Moderator"
        map.putIfAbsent("role", () => "Moderator");
      }
    }
    map.putIfAbsent("userId", () => user["id"]);
    var res = await MyHttp.put("admin/assign/admin", map);

    if (res.statusCode == 200 || res.statusCode == 201) {
      // var jsonData = jsonDecode(res.body);
      if (this.mounted) {
        setState(() {
          _getAdmins();
        });
      }
    }
  }

  _removeUser(dynamic user) async {
    Map map = Map<String, Object>();
    map.putIfAbsent("userId", () => user["id"]);
    String url = "admin/remove/${user["id"]}";
    var res = await MyHttp.put(url, null);
    if (res.statusCode == 200 || res.statusCode == 201) {
      // var jsonData = jsonDecode(res.body);
      if (this.mounted) {
        setState(() {
          _getAdmins();
        });
      }
    }
  }

  Widget _getLists(List list) {
    List column = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      column.add(ListTile(
        contentPadding: EdgeInsets.only(right: 0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: _getImage(list, i) == null
              ? Image(
                  image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
                )
              : Image(
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    _getImage(list, i),
                  ),
                ),
        ),
        trailing: IconButton(
          onPressed: () {
            print("3 dots clicked");
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                      title: null,
                      message: Text(
                        _getRoleAndName(list, i),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyColor1,
                            fontSize: 13),
                      ),
                      // "Assign as Admin"    "Assign as Moderator"   "Assign as Coach"
                      cancelButton: CupertinoActionSheetAction(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.communityProfileOptionsBlueColor,
                              fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      actions: <Widget>[
                        CupertinoActionSheetAction(
                          child: Text(
                            (list[i]["role"] == "Admin")
                                ? "Assign as Moderator"
                                : "Assign as Admin",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color:
                                    AppColors.communityProfileOptionsBlueColor,
                                fontSize: 24),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            assignAlert(context, list[i], 1, false);
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text(
                            (list[i]["role"] == "Admin" ||
                                    list[i]["role"] == "Moderator")
                                ? "Assign as Coach"
                                : "Assign as Moderator",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color:
                                    AppColors.communityProfileOptionsBlueColor,
                                fontSize: 24),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            assignAlert(context, list[i], 2, false);
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text(
                            "Remove",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color:
                                    AppColors.communityProfileOptionsRedColor,
                                fontSize: 24),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            assignAlert(context, list[i], 0, true);
                          },
                        ),
                      ],
                    ));
          },
          icon: Icon(
            Icons.more_horiz,
            size: 40,
            color: Colors.white,
          ),
        ),
        title: Text(
          _getName(list, i),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            color: AppColors.greyColor,
          ),
        ),
        subtitle: Text(
          "User joined",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            color: AppColors.greyColor,
          ),
        ),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: column,
    );
  }

  @override
  void initState() {
    this._getAdmins();
    super.initState();
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: AppColors.adminBlackHeader,
      //bottomNavBar: HomePage(),
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: AppColors.adminBlackHeader,
          elevation: 0.0,
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                child: Image(
                  image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
                ),
              ),
            )
          ],
          //doesnt have a trailing image
          title: Text(
            "Manage Admins",
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                fontFamily: 'Avenir Next'),
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          leading: PlatformIconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          automaticallyImplyMiddle: false,
          backgroundColor: AppColors.adminBlackHeader,
          trailing: MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
              child: Image(
                image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
              ),
            ),
          ),
          title: Text(
            "Manage Admins",
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
          body: (this.loading)
              ? Loading.showLoading()
              : (this.error.isNotEmpty)
                  ? Center(
                      child: Text(
                      this.error,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ))
                  : SingleChildScrollView(
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                cursorColor: Colors.white,
                                onChanged: (String f) {
                                  if (this.mounted) {
                                    setState(() {});
                                  }
                                },
                                style:
                                    TextStyle(color: AppColors.adminSBHintText),
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
                                            color: Colors.transparent,
                                            width: 0),
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        )),
                                    enabledBorder: new OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 0),
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
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Admins",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      fontStyle: FontStyle.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddAdmin(
                                                          role: Role.Admin)))
                                          .then((value) => _getAdmins());
                                    },
                                    icon: Icon(Icons.add_circle),
                                    iconSize: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              admins.length == 0
                                  ? Expanded(
                                      child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        "No Admins",
                                        style: TextStyle(
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: AppColors.greyColor),
                                      ),
                                    ))
                                  : _getLists(admins),
                              admins.length == 0
                                  ? SizedBox(
                                      height: 20,
                                    )
                                  : SizedBox(
                                      height: 0,
                                    ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Moderators",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      fontStyle: FontStyle.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => AddAdmin(
                                                  role: Role.Moderator))).then(
                                          (value) => _getAdmins());
                                    },
                                    icon: Icon(Icons.add_circle),
                                    iconSize: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              moderators.length == 0
                                  ? Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          "No Moderators",
                                          style: TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              color: AppColors.greyColor),
                                        ),
                                      ))
                                  : _getLists(moderators),
                              moderators.length == 0
                                  ? SizedBox(
                                      height: 20,
                                    )
                                  : SizedBox(
                                      height: 0,
                                    ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Coaches",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      fontStyle: FontStyle.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddAdmin(
                                                          role: Role.Coach)))
                                          .then((value) => _getAdmins());
                                    },
                                    icon: Icon(Icons.add_circle),
                                    iconSize: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              coaches.length == 0
                                  ? Expanded(
                                      flex: 10,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          "No Coaches",
                                          style: TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              color: AppColors.greyColor),
                                        ),
                                      ),
                                    )
                                  : _getLists(coaches),
                            ],
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
