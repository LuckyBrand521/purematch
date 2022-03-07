import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'dart:convert';
import 'package:pure_match/pages/settings/admin_tools/send_warning_page2.dart';
import 'package:amplitude_flutter/amplitude.dart';

class SendWarningPageOne extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  final int reportId;

  const SendWarningPageOne(
      {Key key, @required this.userInfo, @required this.reportId})
      : super(key: key);
  @override
  _SendWarningPageOneState createState() => _SendWarningPageOneState();
}

class _SendWarningPageOneState extends State<SendWarningPageOne> {
  var info;
  int userAge;
  bool button1 = false;
  bool button2 = false;
  bool button3 = false;
  bool button4 = false;

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String _getName() {
    return widget.userInfo["User"]["first_name"] +
        " " +
        widget.userInfo["User"]["last_name"];
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getStatus();

    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getStatus(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return PlatformScaffold(
            backgroundColor: AppColors.adminBlackHeader,
            //bottomNavBar: HomePage(),
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
                      //Analytics tracking code
                      analytics.setCurrentScreen(
                          screenName: "reported_user",
                          screenClassOverride: "reported_user");
                      amplitudeAnalytics.logEvent("reported_user_page");
                    },
                  ),
                ),
                title: Text(
                  "Send Warning",
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

                      //Analytics tracking code
                      analytics.setCurrentScreen(
                          screenName: "reported_user",
                          screenClassOverride: "reported_user");
                      amplitudeAnalytics.logEvent("reported_user_page");
                    },
                  ),
                ),
                title: Text(
                  "Send Warning",
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 130,
                      width: 200,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: widget.userInfo["User"]["ProfilePictureId"] ==
                                  null
                              ? Image(
                                  image: AssetImage(
                                      "assets/images/Pure_Match_Draft_5.png"),
                                )
                              : Image(
                                  image: NetworkImage(
                                    widget.userInfo["User"]["ProfilePictureId"],
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
                        "Choose a Warning Reason:",
                        style: TextStyle(
                            color: AppColors.greyColor,
                            fontSize: 20,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'Avenir Next',
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            button1 = !button1;
                          });
                        },
                        color: button1 == true
                            ? AppColors.blueColor
                            : AppColors.greyColor,
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        textColor: button1 == true
                            ? Colors.white
                            : AppColors.blackColor,
                        child: Text(
                          "Fake/Inappropriate picture(s)",
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: button1 == true
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            button2 = !button2;
                          });
                        },
                        color: button2 == true
                            ? AppColors.blueColor
                            : AppColors.greyColor,
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        textColor: button2 == true
                            ? Colors.white
                            : AppColors.blackColor,
                        child: Text(
                          "Harassment or threats",
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: button2 == true
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            button3 = !button3;
                          });
                        },
                        color: button3 == true
                            ? AppColors.blueColor
                            : AppColors.greyColor,
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        textColor: button3 == true
                            ? Colors.white
                            : AppColors.blackColor,
                        child: Text(
                          "Spam",
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: button3 == true
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            button4 = !button4;
                          });
                        },
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        textColor: button4 == true
                            ? Colors.white
                            : AppColors.blackColor,
                        color: button4 == true
                            ? AppColors.blueColor
                            : AppColors.greyColor,
                        child: Text(
                          "Other",
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: button4 == true
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                      child: PlatformButton(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        color: button1 || button2 || button3 || button4 == true
                            ? AppColors.blueColor
                            : AppColors.greyColor,
                        onPressed: () {
                          if (button1 ||
                              button2 ||
                              button3 ||
                              button4 == true) {
                            List<String> choosen = [];
                            if (button1) {
                              choosen.add("Fake/Inappropriate picture(s)");
                            }
                            if (button2) {
                              choosen.add("Harassment or threats");
                            }
                            if (button3) {
                              choosen.add("Spam");
                            }
                            if (button4) {
                              choosen.add("Other");
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SendWarningPageTwo(
                                          userInfo: widget.userInfo,
                                          reportId: widget.reportId,
                                          selectedComplaints: choosen,
                                        )));
                          }
                        },
                        materialFlat: (_, __) => MaterialFlatButtonData(
                          child: Text(
                            "Continue",
                            style: TextStyle(
                                fontSize: 20,
                                color: button1 ||
                                        button2 ||
                                        button3 ||
                                        button4 == true
                                    ? Colors.white
                                    : AppColors.blackColor,
                                fontWeight: button1 ||
                                        button2 ||
                                        button3 ||
                                        button4 == true
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                fontStyle: FontStyle.normal),
                          ),
                        ),
                        cupertino: (_, __) => CupertinoButtonData(
                          child: Text(
                            "Continue",
                            style: TextStyle(
                                fontSize: 20,
                                color: button1 ||
                                        button2 ||
                                        button3 ||
                                        button4 == true
                                    ? Colors.white
                                    : AppColors.blackColor,
                                fontWeight: button1 ||
                                        button2 ||
                                        button3 ||
                                        button4 == true
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                fontStyle: FontStyle.normal),
                          ),
                        ),
                      ),
                    ),
                  ],
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
