import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'dart:io' show Platform;
import 'package:pure_match/pages/MyHttp.dart';
import 'dart:convert';
import 'package:pure_match/pages/settings/admin_tools/admin_navigator.dart';

class SendWarningPageTwo extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  final int reportId;
  final List<String> selectedComplaints;
  const SendWarningPageTwo(
      {Key key,
      @required this.userInfo,
      @required this.reportId,
      @required this.selectedComplaints})
      : super(key: key);
  @override
  _SendWarningPageTwoState createState() => _SendWarningPageTwoState();
}

class _SendWarningPageTwoState extends State<SendWarningPageTwo> {
  var info;
  int userAge;
  bool buttonDisabled = true;
  String complaint;
  int _charCount = 0;
  final _controller = TextEditingController();
  String _getName() {
    return widget.userInfo["User"]["first_name"] +
        " " +
        widget.userInfo["User"]["last_name"];
  }

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  void _sendWarningApiCall() async {
    int id = widget.userInfo["UserId"];
    var res = await MyHttp.post("admin/warn/$id", {
      "Message": complaint,
      "reasons": widget.selectedComplaints,
      "reportId": widget.reportId
    });
    print(res);
    //Analytics tracking code
    analytics.logEvent(name: "warned_user", parameters: <String, dynamic>{
      "reported_by": widget.reportId.toString(),
      "user_id": id.toString(),
      "reason": widget.selectedComplaints[0]
    });

    amplitudeAnalytics.logEvent("warned_user", eventProperties: {
      "reported_by": widget.reportId.toString(),
      "user_id": id.toString(),
      "reason": widget.selectedComplaints[0]
    });
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
    _controller.text =
        "You have been reported as violating our policies for __________. Your case is under review. Depending on the severity of the offense, this may lead to account suspension or a permanent ban from our services. Please {review our policies} to ensure you understand our terms of service, or {reach out to us} if you believe this is in error.";
    //Analytics tracking code
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "send_warning_page2",
        screenClassOverride: "send_warning_page2");
    amplitudeAnalytics.logEvent("send_warning_page2");
  }

  void userWarnedAlert() {
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            int count = widget.userInfo["UserReports"].length + 1;
            String times = count.toString();
            return CupertinoAlertDialog(
              title: Text("User Warned"),
              content: Text(
                  "You have issued a warning. This user now has $times warnings."),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    //Analytics tracking code
                    analytics.setCurrentScreen(
                        screenName: "ban_user_queue",
                        screenClassOverride: "ban_user_queue");
                    amplitudeAnalytics.logEvent("ban_user_queue_page");

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
    } else {
      showDialog(
          context: context,
          builder: (context) {
            int count = widget.userInfo["UserReports"].length + 1;
            String times = count.toString();
            return AlertDialog(
              title: Text("User Warned"),
              content: Text(
                  "You have issued a warning. This user now has $times warnings"),
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
  }

  @override
  Widget build(BuildContext context) {
    var borderSideProperty =
        BorderSide(color: AppColors.noExplaintationBorderColor, width: 1.5);
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
                          screenName: "send_warning_page1",
                          screenClassOverride: "send_warning_page1");
                      amplitudeAnalytics.logEvent("send_warning_page1");
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
                          screenName: "send_warning_page1",
                          screenClassOverride: "send_warning_page1");
                      amplitudeAnalytics.logEvent("send_warning_page1");
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
                        "Warning Message: ",
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
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: PlatformTextField(
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        maxLength: 300,
                        maxLines: 15,
                        controller: _controller,
                        style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            color: AppColors.blackColor),
                        onChanged: (String text) {
                          complaint = text;
                          setState(() {
                            _charCount = text.length;
                            buttonDisabled = text.length > 300 ? false : true;
                            buttonDisabled = text.length > 0 ? false : true;
                          });
                        },
                        material: (_, __) => MaterialTextFieldData(
                          decoration: InputDecoration(
                            hintText: "Type here...",
                            hintStyle: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w400,
                                color: AppColors.blackColor),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: borderSideProperty),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: borderSideProperty),
                          ),
                        ),
                        cupertino: (_, __) => CupertinoTextFieldData(
                          placeholder: "Type here...",
                          placeholderStyle: TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400,
                              color: AppColors.blackColor),
                          keyboardAppearance: Brightness.light,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(_charCount.toString() + "/300",
                          style: TextStyle(
                              fontSize: 18.0, color: AppColors.blueColor)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                      child: PlatformButton(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        color: AppColors.redColor,
                        onPressed: () {},
                        materialFlat: (_, __) => MaterialFlatButtonData(
                          onPressed: () {
                            _sendWarningApiCall();
                            userWarnedAlert();
                          },
                          child: Text(
                            "Send Warning",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal),
                          ),
                        ),
                        cupertino: (_, __) => CupertinoButtonData(
                          onPressed: () {
                            _sendWarningApiCall();
                            userWarnedAlert();
                          },
                          child: Text(
                            "Send Warning",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
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
