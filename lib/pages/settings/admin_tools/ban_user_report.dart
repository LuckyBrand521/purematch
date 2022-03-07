import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'dart:convert';
import 'package:pure_match/pages/settings/admin_tools/ban_user_body.dart';
import 'package:pure_match/pages/settings/admin_tools/send_warning_page1.dart';
import 'package:pure_match/pages/settings/admin_tools/admin_navigator.dart';
import 'package:amplitude_flutter/amplitude.dart';

class BannedUserReportPage extends StatefulWidget {
  final SubPage page;
  final Map<String, dynamic> userInfo;

  const BannedUserReportPage(
      {Key key, @required this.page, @required this.userInfo})
      : super(key: key);
  @override
  _BannedUserReportPageState createState() => _BannedUserReportPageState();
}

enum Choices { Warn, Ban }

class _BannedUserReportPageState extends State<BannedUserReportPage> {
  var info;
  var reportInfo;
  int userAge;
  List<Choices> choice = [Choices.Warn, Choices.Ban];

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String _title() {
    if (widget.page == SubPage.Queue) {
      String name = widget.userInfo["User"]["first_name"];
      return "Reported - $name";
    } else if (widget.page == SubPage.Warned) {
      String name = widget.userInfo["User"]["first_name"];
      return "Warned - $name";
    } else {
      String name = widget.userInfo["User"]["first_name"];
      return "Banned - $name";
    }
  }

  List<Widget> _getReports() {
    List<Widget> list = [];
    var items = reportInfo["ReportDates"];
    for (int i = 0; i < items.length; i++) {
      list.add(Text(items[i],
          style: TextStyle(
              color: AppColors.greyColor,
              fontSize: 16,
              fontStyle: FontStyle.normal,
              fontFamily: 'Avenir Next',
              fontWeight: FontWeight.w400)));
    }
    return list;
  }

  List<Widget> _getWarnings() {
    List<Widget> list = [];
    var items = reportInfo["WarningDates"];
    for (int i = 0; i < items.length; i++) {
      var reportDate =
          reportInfo["ReportDates"][reportInfo["ReportDates"].length - 1];
      String date =
          reportDate.substring(reportDate.length - 8, reportDate.length);
      list.add(Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Text(items[i],
            style: TextStyle(
                color: AppColors.greyColor,
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontFamily: 'Avenir Next',
                fontWeight: FontWeight.w400)),
      ));
      if (reportInfo["reports"][reportInfo["reports"].length - 1]["Post"] !=
          null) {
        list.add(SizedBox(
          height: 10,
        ));
        list.add(Container(
          color: Colors.white,
          child: ListTile(
            contentPadding: EdgeInsets.only(right: 0),
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: widget.userInfo["User"]["ProfilePictureId"] == null
                    ? Image(
                        image: AssetImage("assets/images/logo.png"),
                      )
                    : Image(
                        image: NetworkImage(
                          widget.userInfo["User"]["ProfilePictureId"],
                        ),
                      ),
              ),
            ),
            title: Text(
              _getName(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                color: AppColors.blackColor,
              ),
            ),
            subtitle: Text(
              "Reported on $date",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                color: AppColors.blackColor,
              ),
            ),
          ),
        ));
        list.add(Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              reportInfo["reports"][reportInfo["reports"].length - 1]["Post"]
                  ["text"],
              style: TextStyle(
                fontSize: 16,
                fontFamily: "Avenir Next",
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                color: AppColors.blackColor,
              ),
            ),
          ),
        ));
        list.add(SizedBox(
          height: 10,
        ));
      }
    }
    return list;
  }

  String _getName() {
    return widget.userInfo["User"]["first_name"] +
        " " +
        widget.userInfo["User"]["last_name"];
  }

  void _userBannedApiCall() async {
    int index = reportInfo["reports"].length;
    int reportId = reportInfo["reports"][index - 1]["id"];
    int id = widget.userInfo["UserId"];
    var res = await MyHttp.post("admin/ban/$id", {"reportId": reportId});
    print(res);
    //Analytics tracking code
    analytics.logEvent(name: "banned_user", parameters: <String, dynamic>{
      "reported_by": reportId.toString(),
      "user_id": id.toString()
    });

    amplitudeAnalytics.logEvent("banned_user", eventProperties: {
      "reported_by": reportId.toString(),
      "user_id": id.toString()
    });
  }

  void _userUnbannedApiCall() async {
    int id = widget.userInfo["UserId"];
    var res = await MyHttp.put("admin/unban/$id", {});
    // Analytics tracking code
    int index = reportInfo["reports"].length;
    analytics.logEvent(name: "unbanned_user", parameters: <String, dynamic>{
      "reported_by": reportInfo["reports"][index - 1]["id"].toString(),
      "user_id": id.toString()
    });

    amplitudeAnalytics.logEvent("unbanned_user", eventProperties: {
      "reported_by": reportInfo["reports"][index - 1]["id"].toString(),
      "user_id": id.toString()
    });

    print(res);
    var json = jsonDecode(res.body);
    print("AAAAAAAAAAAAAAAAA $json");
  }

  Future<Map<String, dynamic>> _getStatus() async {
    int id = widget.userInfo["UserId"];
    var res = await MyHttp.get("users/user/$id");
    var res2 = await MyHttp.get("users/uploads");
    var json = jsonDecode(res.body);
    info = json["user"] as Map<String, dynamic>;
    userAge = json["age"];
    print("===============================$info");
    print(res.body);
    print(res2.body);
    return json["user"];
  }

  Future<Map<String, dynamic>> _getReportInfo() async {
    int id = widget.userInfo["UserId"];
    var res = await MyHttp.get("admin/watched/$id");
    //var res2 = await MyHttp.get("users/uploads");
    var json = jsonDecode(res.body);
    print(json);
    reportInfo = json as Map<String, dynamic>;
    print(res.body);
    //print(res2.body);
    return json;
  }

  void unBanAlertAndroid() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Confirm Unban"),
            content: Text("Are you sure you want to unban this user?"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  _userUnbannedApiCall();
                  Navigator.of(context).pop();
                  userUnbannedAlertAndroid();
                },
                child: Text(
                  "Unban User",
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

  void banAlertAndroid() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Confirm Ban"),
            content: Text("Are you sure you want to ban this user?"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  _userBannedApiCall();
                  Navigator.of(context).pop();
                  userBannedAlertAndroid();
                },
                child: Text(
                  "Ban User",
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

  void userUnbannedAlertAndroid() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("User Unbanned"),
            content: Text("This user may access Pure Match again."),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminNavigator(
                                index: 1,
                              )));
                },
                child: Text(
                  "Close",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                ),
              )
            ],
          );
        });
  }

  void userBannedAlertAndroid() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("User Banned"),
            content:
                Text("This user is now permanently banned from Pure Match."),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminNavigator(
                                index: 1,
                              )));
                },
                child: Text(
                  "Close",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                ),
              )
            ],
          );
        });
  }

  void userUnbannedAlert() {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("User Unbanned"),
            content: Text("This user may access Pure Match again."),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminNavigator(
                                index: 1,
                              )));
                },
                child: Text(
                  "Close",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                ),
              )
            ],
          );
        });
  }

  void userBannedAlert() {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("User Banned"),
            content:
                Text("This user is now permanently banned from Pure Match."),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminNavigator(
                                index: 1,
                              )));
                },
                child: Text(
                  "Close",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                ),
              )
            ],
          );
        });
  }

  void unbanAlert() {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("Confirm Unban"),
            content: Text("Are you sure you want to unban this user?"),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  _userUnbannedApiCall();
                  Navigator.of(context).pop();
                  userUnbannedAlert();
                },
                child: Text(
                  "Unban User",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();

                  //Analytics tracking code
                  analytics.setCurrentScreen(
                      screenName: "ban_user_queue",
                      screenClassOverride: "ban_user_queue");
                  amplitudeAnalytics.logEvent("ban_user_queue_page");
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

  void banAlert() {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("Confirm Ban"),
            content: Text("Are you sure you want to ban this user?"),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  _userBannedApiCall();
                  Navigator.of(context).pop();
                  userBannedAlert();
                },
                child: Text(
                  "Ban User",
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
  }

  void _actionSheetAndroid(Choices choice) {
    // analytics variable that will be used in the code
    int reportedBy = 0;
    if (widget.page != SubPage.Banned) {
      if (choice == Choices.Warn) {
        int index = reportInfo["reports"].length;
        int reportId = reportInfo["reports"][index - 1]["id"];

        //Analytics variable assignment
        reportedBy = reportId;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SendWarningPageOne(
                      userInfo: widget.userInfo,
                      reportId: reportId,
                    )));
        //Analytics tracking code
        analytics.setCurrentScreen(
            screenName: "send_warning_page1",
            screenClassOverride: "send_warning_page1");
        amplitudeAnalytics.logEvent("send_warning_page1");
      } else {
        banAlertAndroid();
      }
    } else {
      unBanAlertAndroid();
    }
  }

  void actionSheet(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          if (widget.page != SubPage.Banned) {
            return CupertinoActionSheet(
              title: Text(_title()),
              cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  onPressed: () {
                    int index = reportInfo["reports"].length;
                    int reportId = reportInfo["reports"][index - 1]["id"];
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SendWarningPageOne(
                                  userInfo: widget.userInfo,
                                  reportId: reportId,
                                )));
                    //analytics code
                    analytics.setCurrentScreen(
                        screenName: "warned_user",
                        screenClassOverride: "warned_user");
                    amplitudeAnalytics.logEvent("warned_user_page");
                  },
                  child: Text("Warn User"),
                ),
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    banAlert();
                  },
                  child: Text(
                    "Ban User",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          } else {
            return CupertinoActionSheet(
              title: Text(_title()),
              cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    unbanAlert();
                  },
                  child: Text(
                    "Unban User",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          }
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getStatus();
    _getReportInfo();

    //Initializing amplitude analytics api key
    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "ban_user_report", screenClassOverride: "ban_user_report");
    amplitudeAnalytics.logEvent("ban_user_report_page");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getStatus(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return PlatformScaffold(
            backgroundColor: AppColors.adminBlackHeader,
            appBar: PlatformAppBar(
              material: (_, __) => MaterialAppBarData(
                backgroundColor: AppColors.adminBlackHeader,
                elevation: 0.0,
                leading: MaterialButton(
                  onPressed: () {},
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);

                      //analytics code
                      analytics.setCurrentScreen(
                          screenName: "ban_user_queue",
                          screenClassOverride: "ban_user_queue");
                      amplitudeAnalytics.logEvent("ban_user_queue_page");
                    },
                  ),
                ),
                actions: <Widget>[
                  widget.page != SubPage.Banned
                      ? PopupMenuButton(
                          icon: Icon(Icons.more_horiz),
                          onSelected: _actionSheetAndroid,
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<Choices>(
                                value: Choices.Warn,
                                child: Text("Warn User"),
                              ),
                              PopupMenuItem<Choices>(
                                value: Choices.Ban,
                                child: Text("Ban User"),
                              )
                            ];
                          },
                        )
                      : PopupMenuButton(
                          icon: Icon(Icons.more_horiz),
                          onSelected: _actionSheetAndroid,
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<Choices>(
                                value: Choices.Ban,
                                child: Text("Unban User"),
                              )
                            ];
                          },
                        )
                ],
                title: Text(
                  _title(),
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Avenir Next'),
                ),
              ),
              cupertino: (_, __) => CupertinoNavigationBarData(
                automaticallyImplyLeading: false,
                automaticallyImplyMiddle: false,
                backgroundColor: AppColors.adminBlackHeader,
                leading: MaterialButton(
                  onPressed: () {},
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      //analytics code
                      analytics.setCurrentScreen(
                          screenName: "ban_user_queue",
                          screenClassOverride: "ban_user_queue");
                      amplitudeAnalytics.logEvent("ban_user_queue_page");
                    },
                  ),
                ),
                trailing: MaterialButton(
                  onPressed: () {},
                  child: IconButton(
                    onPressed: () {
                      actionSheet(context);
                    },
                    icon: Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(
                  _title(),
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
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 130,
                        width: 200,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: widget.userInfo["User"]
                                        ["ProfilePictureId"] ==
                                    null
                                ? Image(
                                    image: AssetImage(
                                        "assets/images/Pure_Match_Draft_5.png"),
                                  )
                                : Image(
                                    image: NetworkImage(
                                      widget.userInfo["User"]
                                          ["ProfilePictureId"],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _getName(),
                              style: TextStyle(
                                  color: AppColors.greyColor,
                                  fontSize: 20,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Avenir Next',
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              ", ",
                              style: TextStyle(
                                  color: AppColors.greyColor,
                                  fontSize: 20,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Avenir Next',
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              userAge.toString(),
                              style: TextStyle(
                                  color: AppColors.greyColor,
                                  fontSize: 20,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Avenir Next',
                                  fontWeight: FontWeight.w500),
                            ),
                          ]),
                      Center(
                        child: Text(
                          info["location"] is String
                              ? info["location"]
                              : info["location"].toString(),
                          style: TextStyle(
                              color: AppColors.greyColor,
                              fontSize: 20,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Avenir Next',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          widget.page == SubPage.Queue
                              ? "Reported For:"
                              : "Warned For:",
                          style: TextStyle(
                              color: AppColors.greyColor,
                              fontSize: 20,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Avenir Next',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          reportInfo["ReportedFor"][0],
                          style: TextStyle(
                              color: AppColors.greyColor,
                              fontSize: 16,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Avenir Next',
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Times Reported: ",
                              style: TextStyle(
                                  color: AppColors.greyColor,
                                  fontSize: 20,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Avenir Next',
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              reportInfo["TimesReported"].toString(),
                              style: TextStyle(
                                  color: AppColors.greyColor,
                                  fontSize: 20,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Avenir Next',
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _getReports(),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Warnings: ",
                              style: TextStyle(
                                  color: AppColors.greyColor,
                                  fontSize: 20,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Avenir Next',
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              reportInfo["Warnings"].toString(),
                              style: TextStyle(
                                  color: AppColors.greyColor,
                                  fontSize: 20,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Avenir Next',
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: reportInfo["WarningDates"].length > 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _getWarnings(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
