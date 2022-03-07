import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/login/confirm_reactivation_account.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes.dart';

class ReactivateAccount extends StatefulWidget {
  final email;
  final password;
  final id;
  const ReactivateAccount(
    int this.id,
    String this.email,
    String this.password,
  );

  @override
  _ReactivateAccountState createState() => _ReactivateAccountState();
}

class _ReactivateAccountState extends State<ReactivateAccount> {
  User _user;
  String _email;
  String _password;
  var profileImg;
  void _getUserDetails() async {
    _user = await MyHttp.getUserDetails(userId: widget.id);
    setState(() {
      profileImg = _user.imageUrl;
    });
  }

  void _reactivate() async {
    try {
      var output = {
        "status": "active",
      };
      var res = await MyHttp.put("users/account/reactivate", output);
      print("this is the status code for the reactivate>>>>>");
      print(res.statusCode);
      print(res.body);
    } catch (e) {
      print("this reactivate is not working");
    }
  }

  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: AppColors.blueColor,
      //bottomNavBar: HomePage(),
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: AppColors.blueColor,
          elevation: 0.0,
          leading: MaterialButton(
            onPressed: () {},
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
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
          backgroundColor: AppColors.blueColor,
          leading: MaterialButton(
            onPressed: () {},
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.white,
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
          backgroundColor: AppColors.blueColor,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: Container()),
                Text(
                  "This account has been deactivated.",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
                  "Would you like to reactivate it now?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Expanded(child: Container()),
                Container(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 10),
                    child: PlatformButton(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      color: AppColors.matchBrowseMatchReactivateMatching,
                      onPressed: () {
                        _reactivate();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ConfirmReactivation(
                                widget.id, widget.email, widget.password)));
                      },
                      child: Text(
                        "Reactivate My Account",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
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
                Container(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 10),
                    child: PlatformButton(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      color: Colors.white,
                      onPressed: () async {
                        var sp = await SharedPreferences.getInstance();
                        sp.remove("id");
                        sp.remove("token");
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.redColor,
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
