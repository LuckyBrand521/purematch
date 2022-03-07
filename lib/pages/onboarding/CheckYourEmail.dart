import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pure_match/common/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppColors.dart';

class CheckYourEmail extends StatefulWidget {
  @override
  _CheckYourEmailState createState() => _CheckYourEmailState();
}

class _CheckYourEmailState extends State<CheckYourEmail> {
  String userEmail = "your email";
  int resent = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Global.setOnboardingId(29);
    getEmail();
  }

  Future<void> getEmail() async {
    // 3397070723
    var sp = await SharedPreferences.getInstance();
    userEmail = sp.getString("email") ?? "purematchapp@gmail.com";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        // appBar: PlatformAppBar(
        //   material: (_, __) => MaterialAppBarData(
        //     backgroundColor: AppColors.yellowColor,
        //     elevation: 0.0,
        //   ),
        //   cupertino: (_, __) => CupertinoNavigationBarData(
        //     brightness: Brightness.dark,
        //     automaticallyImplyLeading: false,
        //     automaticallyImplyMiddle: false,
        //     backgroundColor: AppColors.yellowColor,
        //     border: Border(bottom: BorderSide.none),
        //     padding: EdgeInsetsDirectional.only(start: 10.0),
        //   ),
        // ),
        body: new WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: AppColors.yellowColor,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil().setHeight(40),
                  ),
                  Text(
                    "Please Check Your Email",
                    maxLines: 2,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 48),
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(20),
                  ),
                  Text(
                    "An email has been sent to\n" +
                        userEmail +
                        "\nfrom the Pure Match Team.",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 28),
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(30),
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: new TextSpan(
                      children: [
                        new TextSpan(
                          text:
                              'Didn’t receive an email?\nCheck your junk mail,\nor ',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize:
                                  AppConfig.fontsizeForSmallDevice(context, 28),
                              color: Colors.white),
                        ),
                        new TextSpan(
                          text: 'click here',
                          style: new TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize:
                                AppConfig.fontsizeForSmallDevice(context, 28),
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                resent++;
                              });
                              // launch(
                              //     'https://docs.flutter.io/flutter/services/UrlLauncher-class.html');
                            },
                        ),
                        new TextSpan(
                          text: ' to send it again.',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize:
                                AppConfig.fontsizeForSmallDevice(context, 28),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  (resent > 0)
                      ? Text(
                          "Email Resent $resent time(s)",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize:
                                AppConfig.fontsizeForSmallDevice(context, 28),
                            color: Colors.white,
                          ),
                        )
                      : Text(""),
                  // Text(
                  //   "Didn’t receive an email?\nCheck your junk mail,\nor click here to send it again..",
                  //   style: TextStyle(
                  //       fontWeight: FontWeight.w600,
                  //       fontSize: AppConfig.fontsizeForSmallDevice(context, 28),
                  //       color: Colors.white),
                  //   textAlign: TextAlign.center,
                  // ),
                ],
              ),
            ),
          ),
        )
    );
  }
}
