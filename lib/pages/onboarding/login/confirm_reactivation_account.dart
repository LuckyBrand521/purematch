import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/myfirebase.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/login/reactivate_account.dart';
import 'package:pure_match/pages/onboarding/login/welcome_back.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes.dart';

class ConfirmReactivation extends StatefulWidget {
  final email;
  final password;
  final id;
  const ConfirmReactivation(
    int this.id,
    String this.email,
    String this.password,
  );
  @override
  _ConfirmReactivationState createState() => _ConfirmReactivationState();
}

class _ConfirmReactivationState extends State<ConfirmReactivation> {
  User _user;
  bool _loading = false;
  String error = "";
  var profileImg;
  void _getUserDetails() async {
    _user = await MyHttp.getUserDetails(userId: widget.id);
    setState(() {
      profileImg = _user.imageUrl;
    });
  }

  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }

  Future<void> _verifyAccountDetails() async {
    setState(() {
      _loading = true;
    });
    var res = await MyHttp.post(
        "login", {"email": widget.email, "password": widget.password});
    var body = json.decode(res.body);
    if (res.statusCode == 200) {
      print("User verified");
      print(res.body);

      bool status = body["success"];
      if (status == true) {
        String token = body["token"];
        int id = body["Id"];
        // bool newUser = body["newUser"];
        var sp = await SharedPreferences.getInstance();
        await sp.setInt("id", id);
        await sp.setString("token", token);
        _loading = false;
        if (sp.containsKey("loggedIn")) {
          var tokenReq = await MyFirebase.sendFCMToken("users/fcm-token");
          if (tokenReq != null) {
            print("FCm token send response:::::::::");
            print(tokenReq.statusCode);
            print(tokenReq.body);
          }
        }
        Global.currentUser = null;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WelcomeBack(
                      isFromLogin: true,
                    )));
      } else {
        setState(() {
          error = body["message"];
        });
      }
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");

      setState(() {
        error = body["message"];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Colors.white,
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: MaterialButton(
            onPressed: () {},
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.black,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          brightness: Brightness.dark,
          automaticallyImplyLeading: false,
          automaticallyImplyMiddle: false,
          backgroundColor: Colors.white,
          leading: MaterialButton(
            onPressed: () {},
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.black,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
        ),
      ),
      body: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Account Reactivated!",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                (profileImg != null && profileImg != "")
                    ? Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(profileImg),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Privacy Settings Reset",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  "Your privacy settings have been reset to the default.  Please customize them again in your Settings.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.redColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "To get to your settings, tap the Pure Match logo in the upper right corner of the app.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 25,
                ),
                Expanded(
                  child: Container(),
                ),
                Container(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 10),
                    child: PlatformButton(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      color: AppColors.matchBrowseMatchReactivateMatching,
                      onPressed: () {
                        _verifyAccountDetails();
                      },
                      child: Text(
                        "Continue to Pure Match",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      materialFlat: (_, __) => MaterialFlatButtonData(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      cupertino: (_, __) => CupertinoButtonData(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
