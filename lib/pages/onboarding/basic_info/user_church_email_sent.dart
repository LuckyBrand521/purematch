import 'package:flutter/material.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';

import '../../MyHttp.dart';

class UserChurchEmailSent extends StatefulWidget {
  final bool seekingChurch;

  const UserChurchEmailSent({Key key, this.seekingChurch}) : super(key: key);
  @override
  _UserChurchEmailSentState createState() => _UserChurchEmailSentState();
}

class _UserChurchEmailSentState extends State<UserChurchEmailSent> {
  @override
  Future<void> _verifyChurch() async {
    var res = await MyHttp.post(
        "/church-verify", {"undecided": this.widget.seekingChurch});
    if (res.statusCode == 200) {
      print("User updated");
      print(res.body);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserChurchEmailSent()));
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {});
    }
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return new WillPopScope(
      child: PlatformScaffold(
        backgroundColor: AppColors.blueColor,
        // appBar: PlatformAppBar(
        //   material: (_, __) => MaterialAppBarData(
        //     backgroundColor: AppColors.blueColor,
        //     elevation: 0.0,
        //   ),
        //   cupertino: (_, __) => CupertinoNavigationBarData(
        //     brightness: Brightness.dark,
        //     automaticallyImplyLeading: false,
        //     automaticallyImplyMiddle: false,
        //     backgroundColor: AppColors.blueColor,
        //     border: Border(bottom: BorderSide.none),
        //     padding: EdgeInsetsDirectional.only(start: 10.0),
        //   ),
        // ),
        body: SafeArea(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: AppConfig.heightForSmallDevice(context, 70),
                  ),
                  Text("Please Check your email",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: AppConfig.fontsizeForSmallDevice(context, 40),
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700)),
                  SizedBox(
                    height: AppConfig.heightForSmallDevice(context, 40),
                  ),
                  Text(
                      "An email on next steps has been sent to you from the Pure Match Team.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: AppConfig.fontsizeForSmallDevice(context, 28),
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: AppConfig.heightForSmallDevice(context, 40),
                  ),
                  Text("Didn't receive an email?Check your junk mail,or",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: AppConfig.fontsizeForSmallDevice(context, 28),
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w600)),
                  Material(
                    color: AppColors.blueColor,
                    child: InkWell(
                      onTap: () {
                        this._verifyChurch();
                      },
                      child: Text("click here to send it again.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  AppConfig.fontsizeForSmallDevice(context, 28),
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ), 
      onWillPop: () async => false);

  }
}
