import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/common/profile.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'dart:io' show Platform;

class PendingUsersInfo extends StatefulWidget {
  final int id;
  final String name;
  const PendingUsersInfo({Key key, @required this.id, @required this.name})
      : super(key: key);
  @override
  _PendingUsersInfoState createState() => _PendingUsersInfoState();
}

enum Choices { Accept, Decline }

class _PendingUsersInfoState extends State<PendingUsersInfo> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int id;
  List<Choices> choice = [Choices.Accept, Choices.Decline];
  String _title() {
    return "Pending: " + widget.name;
  }

  void approved() async {
    var res = await MyHttp.put("admin/approve/$id", {});
    print(res);
    //Analytics tracking code
    analytics.logEvent(
        name: "approved_user",
        parameters: <String, dynamic>{"user_id": id.toString()});
    amplitudeAnalytics
        .logEvent("approved_user", eventProperties: {"user_id": id.toString()});
  }

  void declined() async {
    var res = await MyHttp.put("admin/decline/$id", {});
    print(res);

    //Analytics tracking code
    analytics.logEvent(
        name: "declined_user",
        parameters: <String, dynamic>{"user_id": id.toString()});
    amplitudeAnalytics
        .logEvent("declined_user", eventProperties: {"user_id": id.toString()});
  }

  void approvedAlert() {
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("User Approved"),
              content: Text("This user may now access Pure Match."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Continue",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
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
              title: Text("User Approved"),
              content: Text("This user may now access Pure Match."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Continue",
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
  }

  void declinedAlert() {
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("User Declined"),
              content: Text("This user will not be able to access Pure Match."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    //Analytics tracking code
                    analytics.logEvent(
                        name: "declined_user",
                        parameters: <String, dynamic>{
                          "user_id": id.toString()
                        });
                    amplitudeAnalytics.logEvent("declined_user",
                        eventProperties: {"user_id": id.toString()});
                  },
                  child: Text(
                    "Continue",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
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
              title: Text("User Declined"),
              content: Text("This user will not be able to access Pure Match."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    //Analytics tracking code
                    analytics.logEvent(
                        name: "declined_user",
                        parameters: <String, dynamic>{
                          "user_id": id.toString()
                        });
                    amplitudeAnalytics.logEvent("declined_user",
                        eventProperties: {"user_id": id.toString()});
                  },
                  child: Text(
                    "Continue",
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
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;

    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
  }

  void _actionSheetAndroid(Choices choice) {
    if (choice == Choices.Accept) {
      approvedAlert();
      approved();
    } else {
      declinedAlert();
      declined();
    }
  }

  void actionSheet(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
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
                  Navigator.of(context).pop();
                  approvedAlert();
                  approved();
                },
                child: Text("Approve User"),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  declinedAlert();
                  declined();
                },
                child: Text(
                  "Decline User",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
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
                  Navigator.of(context).pop();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => AdminNavigator(
                  //       index: 3,
                  //     ),
                  //   ),
                  // );
                  //Analytics tracking code
                  analytics.setCurrentScreen(
                      screenName: "pending_users",
                      screenClassOverride: "pending_users");
                  amplitudeAnalytics.logEvent("pending_users_page");
                },
              ),
            ),
            title: Text(
              _title(),
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  fontFamily: 'Avenir Next'),
            ),
            actions: <Widget>[
              PopupMenuButton(
                icon: Icon(Icons.more_horiz),
                onSelected: _actionSheetAndroid,
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<Choices>(
                      value: Choices.Accept,
                      child: Text("Accept User"),
                    ),
                    PopupMenuItem<Choices>(
                      value: Choices.Decline,
                      child: Text("Decline User"),
                    )
                  ];
                },
              ),
            ],
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
            automaticallyImplyLeading: false,
            automaticallyImplyMiddle: false,
            backgroundColor: AppColors.adminBlackHeader,
            trailing: MaterialButton(
              onPressed: () {},
              child: IconButton(
                color: Colors.white,
                onPressed: () {
                  actionSheet(context);
                },
                icon: Icon(Icons.more_horiz),
              ),
            ),
            leading: MaterialButton(
              onPressed: () {},
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                color: Colors.white,
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => AdminNavigator(
                  //       index: 3,
                  //     ),
                  //   ),
                  // );
                  Navigator.of(context).pop();
                  //Analytics tracking code
                  analytics.setCurrentScreen(
                      screenName: "pending_users",
                      screenClassOverride: "pending_users");
                  amplitudeAnalytics.logEvent("pending_users_page");
                },
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
        backgroundColor: Colors.white,
        body: Scaffold(
          body: SafeArea(
              child: SingleChildScrollView(
            child: new Profile(
                    userId: widget.id,
                    isEditable: false,
                    themeColor: AppColors.adminBlackHeader)
                .getFullProfile(),
          )),
        ));
  }
}
